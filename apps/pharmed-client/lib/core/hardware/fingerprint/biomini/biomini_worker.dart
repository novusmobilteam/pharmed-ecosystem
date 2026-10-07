// pharmed-client/lib/core/hardware/fingerprint/biomini/biomini_worker.dart
//
// [SWREQ-FP-012]
// BioMini SDK'sını sahiplenen uzun ömürlü worker isolate.
//
// Neden ayrı isolate:
//   UFS_CaptureSingleImage(OnDevice) parmak gelene ya da timeout dolana kadar
//   çağıran thread'i BLOKLAR. Ana isolate'te çağrılırsa UI donar.
//
// Neden her çağrıda Isolate.run değil de tek, kalıcı bir isolate:
//   SDK durumu (UFS_Init, scanner handle) süreç geneli ve stateful'dur; init,
//   handle alma ve capture hep aynı thread'de kalırsa thread'e bağlı durum
//   ihtimaline karşı güvendeyiz ve her okumada yeniden init maliyeti olmaz.
//
// Protokol: ana isolate [BioMiniRequest] gönderir, worker her isteğe tam bir
// [BioMiniResponse] döner. İstekler sırayla işlenir (listen callback'i senkron).
// Worker loglamaz; ham SDK durumunu döner, yorum ve loglama ana isolate'te.
//
// Sınıf: Class B

import 'dart:ffi';
import 'dart:io' show sleep;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'biomini_bindings.dart';
import 'biomini_settings.dart';

/// SDK'da karşılığı olmayan, worker'ın kendi ürettiği durumlar.
/// UFS_STATUS değerleriyle çakışmamaları için çok negatif seçildi.
abstract final class BioMiniLocalStatus {
  /// DynamicLibrary.open veya sembol çözümleme başarısız.
  static const libraryLoadFailed = -90001;

  /// UFS_Init başarılı ama bağlı okuyucu yok.
  static const noScanner = -90002;

  /// Okuyucu açılmadan işlem istendi.
  static const notOpen = -90003;

  /// SDK OK döndü ama boş/taşan şablon verdi.
  static const invalidTemplate = -90004;

  /// Worker içinde beklenmeyen Dart istisnası.
  static const workerException = -90005;
}

// ─────────────────────────────────────────────────────────────────
// İstekler
// ─────────────────────────────────────────────────────────────────

sealed class BioMiniRequest {
  const BioMiniRequest(this.id);
  final int id;
}

final class BioMiniOpenRequest extends BioMiniRequest {
  const BioMiniOpenRequest(super.id, {required this.dllPath, required this.settings});
  final String dllPath;
  final BioMiniSettings settings;
}

final class BioMiniCaptureRequest extends BioMiniRequest {
  const BioMiniCaptureRequest(super.id, {required this.timeoutMs, required this.includeImage});
  final int timeoutMs;
  final bool includeImage;
}

final class BioMiniFingerOnRequest extends BioMiniRequest {
  const BioMiniFingerOnRequest(super.id);
}

final class BioMiniCloseRequest extends BioMiniRequest {
  const BioMiniCloseRequest(super.id);
}

// ─────────────────────────────────────────────────────────────────
// Yanıtlar
// ─────────────────────────────────────────────────────────────────

/// Açılan okuyucu. [handleAddress] ana isolate'in UFS_AbortCapturing
/// çağırabilmesi için taşınır (aynı süreç, aynı adres alanı).
final class BioMiniDeviceInfo {
  const BioMiniDeviceInfo({
    required this.handleAddress,
    required this.scannerType,
    this.serial,
    this.sdkVersion,
  });

  final int handleAddress;
  final int scannerType;
  final String? serial;
  final String? sdkVersion;
}

final class BioMiniCaptureData {
  const BioMiniCaptureData({required this.template, required this.quality, this.lfdScore, this.image});

  final Uint8List template;
  final int quality;
  final int? lfdScore;
  final FingerprintImage? image;
}

final class BioMiniResponse {
  const BioMiniResponse._(this.id, {required this.status, this.stage, this.sdkMessage, this.payload, this.lfdScore});

  const BioMiniResponse.ok(int id, Object? payload) : this._(id, status: Ufs.ok, payload: payload);

  const BioMiniResponse.failure(int id, {required int status, required String stage, String? sdkMessage, int? lfdScore})
    : this._(id, status: status, stage: stage, sdkMessage: sdkMessage, lfdScore: lfdScore);

  final int id;

  /// [Ufs.ok], bir UFS_STATUS hata kodu ya da [BioMiniLocalStatus] değeri.
  final int status;

  /// Hatanın oluştuğu adım: 'load', 'init', 'scannerNumber', 'capture', 'extract' ...
  final String? stage;

  /// UFS_GetErrorString çıktısı (log için).
  final String? sdkMessage;

  final Object? payload;

  /// Sahte parmak hatasında bile cihazın verdiği LFD skoru (log için).
  final int? lfdScore;

  bool get isOk => status == Ufs.ok;
}

// ─────────────────────────────────────────────────────────────────
// Isolate giriş noktası
// ─────────────────────────────────────────────────────────────────

/// `Isolate.spawn(bioMiniWorkerMain, mainPort)`. İlk mesaj olarak kendi
/// SendPort'unu gönderir, ardından [BioMiniCloseRequest] gelene kadar çalışır.
void bioMiniWorkerMain(SendPort mainPort) {
  final inbox = ReceivePort('biomini-worker');
  final worker = _BioMiniWorker();
  mainPort.send(inbox.sendPort);

  inbox.listen((Object? message) {
    final request = message! as BioMiniRequest;
    BioMiniResponse response;
    try {
      response = worker.handle(request);
    } catch (e) {
      response = BioMiniResponse.failure(
        request.id,
        status: BioMiniLocalStatus.workerException,
        stage: 'worker',
        sdkMessage: e.toString(),
      );
    }
    mainPort.send(response);
    if (request is BioMiniCloseRequest) inbox.close(); // isolate kendiliğinden biter
  });
}

class _BioMiniWorker {
  static const _stringBufferSize = 512;

  /// UFS_ExtractOnDevice tampon boyutu parametresi almaz; cihaz şablonu
  /// en fazla 1024 bayt üretir ama taşma riskine karşı tampon geniş tutulur.
  static const _templateBufferSize = 4096;

  BioMiniBindings? _b;
  BioMiniSettings _settings = const BioMiniSettings();
  HUFScanner _handle = nullptr;
  bool _initialized = false;

  BioMiniResponse handle(BioMiniRequest request) => switch (request) {
    final BioMiniOpenRequest r => _open(r),
    final BioMiniCaptureRequest r => _capture(r),
    final BioMiniFingerOnRequest r => _isFingerOn(r),
    final BioMiniCloseRequest r => _close(r),
  };

  // ── open ───────────────────────────────────────────────────────────────

  BioMiniResponse _open(BioMiniOpenRequest r) {
    _settings = r.settings;

    if (_b == null) {
      try {
        _b = BioMiniBindings(DynamicLibrary.open(r.dllPath));
      } catch (e) {
        return BioMiniResponse.failure(
          r.id,
          status: BioMiniLocalStatus.libraryLoadFailed,
          stage: 'load',
          sdkMessage: '${r.dllPath}: $e',
        );
      }
    }
    final b = _b!;

    // Daha önce init edildiyse (yeniden açma ya da hot restart: DLL süreçte
    // yüklü kalır) UFS_Update okuyucu listesini tazeler.
    var status = _initialized ? b.update() : b.init();
    if (status == Ufs.errAlreadyInitialized) status = b.update();
    if (status != Ufs.ok) return _fail(r.id, status, 'init');
    _initialized = true;
    _handle = nullptr;

    return using((arena) {
      final count = arena<Int32>();
      status = b.getScannerNumber(count);
      if (status != Ufs.ok) return _fail(r.id, status, 'scannerNumber');
      if (count.value < 1) {
        // Okuyucu Init'ten hemen önce takılmış / USB yeni enumerate edilmiş olabilir:
        // listeyi bir kez tazeleyip tekrar say. (Worker isolate'te bloklamak sorun değil.)
        sleep(const Duration(milliseconds: 500));
        status = b.update();
        if (status == Ufs.ok) status = b.getScannerNumber(count);
        if (status != Ufs.ok) return _fail(r.id, status, 'scannerNumber');
      }
      if (count.value < 1) {
        // Sürücü kurulu değilse Slim 2S Windows'ta HID / Windows Hello cihazı olarak
        // görünür; SDK HID cihazları desteklemez ve okuyucu sayısı 0 döner.
        return BioMiniResponse.failure(
          r.id,
          status: BioMiniLocalStatus.noScanner,
          stage: 'scannerNumber',
          sdkMessage: 'UFS_Init OK, UFS_GetScannerNumber=0 (Suprema sürücüsü kurulu mu?)',
        );
      }

      final pHandle = arena<HUFScanner>();
      status = b.getScannerHandle(0, pHandle);
      if (status != Ufs.ok || pHandle.value == nullptr) return _fail(r.id, status, 'scannerHandle');
      final h = pHandle.value;

      final applied = _applySettings(b, h, arena);
      if (applied != null) return _fail(r.id, applied.$1, applied.$2);

      final type = arena<Int32>();
      final typeStatus = b.getScannerType(h, type);

      _handle = h;
      return BioMiniResponse.ok(
        r.id,
        BioMiniDeviceInfo(
          handleAddress: h.address,
          scannerType: typeStatus == Ufs.ok ? type.value : -1,
          serial: _readStringParam(b, h, Ufs.paramSerial, arena),
          sdkVersion: _readStringParam(b, h, Ufs.paramSdkVersion, arena),
        ),
      );
    });
  }

  /// Başarısızsa (status, parametre adı) döner.
  (int, String)? _applySettings(BioMiniBindings b, HUFScanner h, Arena arena) {
    final value = arena<Int32>();

    int set(int param, int v) {
      value.value = v;
      return b.setParameter(h, param, value.cast());
    }

    // Okumadan önce parmağın kalkmış olmasını şart koş (0 = açık). Çıkıştan sonra
    // sensörde kalan parmakla anında yeniden giriş yapılmasını donanım seviyesinde önler.
    var s = set(Ufs.paramFingerCheck, 0);
    if (s != Ufs.ok) return (s, 'param:fingerCheck');

    s = set(Ufs.paramTemplateSize, Ufs.maxTemplateSize);
    if (s != Ufs.ok) return (s, 'param:templateSize');

    final format = _sdkTemplateType(_settings.templateFormat);
    if (_settings.captureMode == BioMiniCaptureMode.device) {
      s = b.setDeviceTemplateType(h, format);
      if (s != Ufs.ok) return (s, 'deviceTemplateType');

      s = set(Ufs.paramLfdLevelDev, _settings.lfdLevel);
      if (s != Ufs.ok) return (s, 'param:lfdLevelDev');

      final security = _settings.securityLevel;
      if (security != null) {
        s = set(Ufs.paramSecurityLevelDev, security);
        if (s != Ufs.ok) return (s, 'param:securityLevelDev');
      }
    } else {
      s = b.setTemplateType(h, format);
      if (s != Ufs.ok) return (s, 'templateType');
    }
    return null;
  }

  // ── capture ────────────────────────────────────────────────────────────

  BioMiniResponse _capture(BioMiniCaptureRequest r) {
    final b = _b;
    final h = _handle;
    if (b == null || h == nullptr) {
      return BioMiniResponse.failure(r.id, status: BioMiniLocalStatus.notOpen, stage: 'capture');
    }
    final onDevice = _settings.captureMode == BioMiniCaptureMode.device;

    return using((arena) {
      final value = arena<Int32>();

      value.value = r.timeoutMs;
      var status = b.setParameter(h, Ufs.paramTimeout, value.cast());
      if (status != Ufs.ok) return _fail(r.id, status, 'param:timeout');

      b.clearCaptureImageBuffer(h); // önceki okumanın görüntüsü kalmasın

      // ── BLOKLAR: parmak gelene, timeout dolana ya da AbortCapturing'e kadar ──
      status = onDevice ? b.captureSingleImageOnDevice(h) : b.captureSingleImage(h);

      int? lfdScore;
      if (onDevice && _settings.lfdLevel > 0) {
        if (b.getParameter(h, Ufs.paramLfdScoreDev, value.cast()) == Ufs.ok) lfdScore = value.value;
      }
      if (status != Ufs.ok) return _fail(r.id, status, 'capture', lfdScore: lfdScore);

      // Görüntü, üretici örneğindeki sırayla çıkarmadan ÖNCE alınır.
      final image = r.includeImage ? _readImage(b, h, onDevice, arena) : null;

      final buffer = arena<Uint8>(_templateBufferSize);
      final size = arena<Int32>();
      final quality = arena<Int32>();
      status = onDevice
          ? b.extractOnDevice(h, buffer, size, quality)
          : b.extractEx(h, Ufs.maxTemplateSize, buffer, size, quality);
      if (status != Ufs.ok) return _fail(r.id, status, 'extract', lfdScore: lfdScore);

      final length = size.value;
      final limit = onDevice ? _templateBufferSize : Ufs.maxTemplateSize;
      if (length <= 0 || length > limit) {
        return BioMiniResponse.failure(
          r.id,
          status: BioMiniLocalStatus.invalidTemplate,
          stage: 'extract',
          sdkMessage: 'templateSize=$length',
        );
      }

      return BioMiniResponse.ok(
        r.id,
        BioMiniCaptureData(
          // Kopya: arena kapanınca native bellek serbest kalır.
          template: Uint8List.fromList(buffer.asTypedList(length)),
          quality: quality.value,
          lfdScore: lfdScore,
          image: image,
        ),
      );
    });
  }

  FingerprintImage? _readImage(BioMiniBindings b, HUFScanner h, bool onDevice, Arena arena) {
    final w = arena<Int32>();
    final hgt = arena<Int32>();
    final res = arena<Int32>();
    if (b.getCaptureImageBufferInfo(h, w, hgt, res) != Ufs.ok) return null;

    final length = w.value * hgt.value;
    if (length <= 0 || length > 1024 * 1024) return null; // UFS_MAX_IMAGE_SIDE_LENGTH 1024

    final pixels = arena<Uint8>(length);
    final status = onDevice ? b.getCaptureImageBufferFromDevice(h, pixels) : b.getCaptureImageBuffer(h, pixels);
    if (status != Ufs.ok) return null; // görüntü opsiyonel; okuma başarısını etkilemez

    return FingerprintImage(
      width: w.value,
      height: hgt.value,
      resolutionDpi: res.value,
      pixels: Uint8List.fromList(pixels.asTypedList(length)),
    );
  }

  // ── isFingerOn / close ─────────────────────────────────────────────────

  BioMiniResponse _isFingerOn(BioMiniFingerOnRequest r) {
    final b = _b;
    final h = _handle;
    if (b == null || h == nullptr) {
      return BioMiniResponse.failure(r.id, status: BioMiniLocalStatus.notOpen, stage: 'isFingerOn');
    }
    return using((arena) {
      final on = arena<Int32>();
      final status = b.isFingerOn(h, on);
      if (status != Ufs.ok) return _fail(r.id, status, 'isFingerOn');
      return BioMiniResponse.ok(r.id, on.value != 0);
    });
  }

  BioMiniResponse _close(BioMiniCloseRequest r) {
    final b = _b;
    _handle = nullptr;
    if (b == null || !_initialized) return BioMiniResponse.ok(r.id, null);
    _initialized = false;
    final status = b.uninit();
    return status == Ufs.ok ? BioMiniResponse.ok(r.id, null) : _fail(r.id, status, 'uninit');
  }

  // ── yardımcılar ────────────────────────────────────────────────────────

  BioMiniResponse _fail(int id, int status, String stage, {int? lfdScore}) =>
      BioMiniResponse.failure(id, status: status, stage: stage, sdkMessage: _errorString(status), lfdScore: lfdScore);

  String? _errorString(int status) {
    final b = _b;
    if (b == null) return null;
    return using((arena) {
      final buf = arena<Uint8>(_stringBufferSize);
      if (b.getErrorString(status, buf) != Ufs.ok) return null;
      final s = readCString(buf, _stringBufferSize);
      return s.isEmpty ? null : s;
    });
  }

  /// Seri no / SDK sürümü gibi metin parametreleri. Tampon, SDK hangi tipi
  /// yazarsa yazsın taşmayacak kadar büyük ve sıfırlanmış (calloc) ayrılır.
  String? _readStringParam(BioMiniBindings b, HUFScanner h, int param, Arena arena) {
    final buf = arena<Uint8>(_stringBufferSize);
    if (b.getParameter(h, param, buf.cast()) != Ufs.ok) return null;
    final s = readCString(buf, _stringBufferSize);
    // Yazdırılabilir değilse (SDK sayı yazmış olabilir) yok say.
    return s.isNotEmpty && s.codeUnits.every((c) => c >= 0x20 && c < 0x7F) ? s : null;
  }

  static int _sdkTemplateType(FingerprintTemplateFormat f) => switch (f) {
    FingerprintTemplateFormat.suprema => Ufs.templateTypeSuprema,
    FingerprintTemplateFormat.iso19794_2 => Ufs.templateTypeIso19794_2,
    FingerprintTemplateFormat.ansi378 => Ufs.templateTypeAnsi378,
  };
}
