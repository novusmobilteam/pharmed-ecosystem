// pharmed-client/lib/core/hardware/fingerprint/secugen/secugen_worker.dart
//
// [SWREQ-FP-052]
// SecuGen FDx SDK'sını sahiplenen uzun ömürlü worker isolate.
// Yapı BioMini worker'ı ile aynıdır (bkz. biomini_worker.dart); farklar:
//
//   * İptal: SDK'da süren SGFPM_GetImageEx'i durduran bir fonksiyon YOK. Okuma,
//     [_sliceMs] uzunluğunda dilimlere bölünür; her dilim arasında ana isolate'in
//     native bellekte tuttuğu iptal bayrağına bakılır. İptal gecikmesi ≤ 1 dilim.
//   * Kalite: GetImageEx'in eşiği yalnızca parmağın sensörü kaplama oranıdır.
//     Sırt kalitesi SGFPM_GetImageQuality ile ayrıca ölçülür (0–100; kılavuz:
//     doğrulama ≥40, kayıt ≥50) ve FingerprintCapture.quality olarak döner.
//   * Parmak sorgusu: SDK'da IsFingerOn karşılığı yok. Tek kare alınıp kalitesine
//     bakılır (sezgisel; sahada doğrulanmalı).
//
// Sınıf: Class B

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'secugen_bindings.dart';
import 'secugen_settings.dart';

/// SDK'da karşılığı olmayan, worker'ın ürettiği durumlar (SGFDxErrorCode ile çakışmaz).
abstract final class SecuGenLocalStatus {
  static const libraryLoadFailed = -91001;
  static const noScanner = -91002;
  static const notOpen = -91003;
  static const invalidTemplate = -91004;
  static const workerException = -91005;
  static const cancelled = -91006;
}

// ── İstekler ─────────────────────────────────────────────────────────────

sealed class SecuGenRequest {
  const SecuGenRequest(this.id);
  final int id;
}

final class SecuGenOpenRequest extends SecuGenRequest {
  const SecuGenOpenRequest(super.id, {required this.dllPath, required this.settings, required this.cancelFlagAddress});
  final String dllPath;
  final SecuGenSettings settings;

  /// Ana isolate'in calloc ile ayırdığı Int32; 1 → bekleyen okumayı bırak.
  final int cancelFlagAddress;
}

final class SecuGenCaptureRequest extends SecuGenRequest {
  const SecuGenCaptureRequest(super.id, {required this.timeoutMs, required this.includeImage});
  final int timeoutMs;
  final bool includeImage;
}

final class SecuGenFingerOnRequest extends SecuGenRequest {
  const SecuGenFingerOnRequest(super.id);
}

final class SecuGenCloseRequest extends SecuGenRequest {
  const SecuGenCloseRequest(super.id);
}

// ── Yanıtlar ─────────────────────────────────────────────────────────────

final class SecuGenDeviceInfo {
  const SecuGenDeviceInfo({
    required this.devName,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageDpi,
    required this.livenessActive,
    this.serial,
    this.firmware,
  });

  final int devName;
  final int imageWidth;
  final int imageHeight;
  final int imageDpi;
  final bool livenessActive;
  final String? serial;
  final String? firmware;
}

final class SecuGenCaptureData {
  const SecuGenCaptureData({required this.template, required this.quality, this.image});
  final Uint8List template;
  final int quality;
  final FingerprintImage? image;
}

final class SecuGenResponse {
  const SecuGenResponse._(this.id, {required this.status, this.stage, this.detail, this.payload});

  const SecuGenResponse.ok(int id, Object? payload) : this._(id, status: Sg.errNone, payload: payload);

  const SecuGenResponse.failure(int id, {required int status, required String stage, String? detail})
    : this._(id, status: status, stage: stage, detail: detail);

  final int id;

  /// [Sg.errNone], bir SGFDxErrorCode ya da [SecuGenLocalStatus] değeri.
  final int status;
  final String? stage;
  final String? detail;
  final Object? payload;

  bool get isOk => status == Sg.errNone;
}

// ── Isolate giriş noktası ────────────────────────────────────────────────

void secuGenWorkerMain(SendPort mainPort) {
  final inbox = ReceivePort('secugen-worker');
  final worker = _SecuGenWorker();
  mainPort.send(inbox.sendPort);

  inbox.listen((Object? message) {
    final request = message! as SecuGenRequest;
    SecuGenResponse response;
    try {
      response = worker.handle(request);
    } catch (e) {
      response = SecuGenResponse.failure(
        request.id,
        status: SecuGenLocalStatus.workerException,
        stage: 'worker',
        detail: e.toString(),
      );
    }
    mainPort.send(response);
    if (request is SecuGenCloseRequest) inbox.close();
  });
}

class _SecuGenWorker {
  /// GetImageEx dilim süresi. Kısa → iptal hızlı ama sensör sık yeniden başlar.
  static const _sliceMs = 1000;

  /// Parmak sorgusunda bu kalitenin üstü "parmak var" sayılır (sezgisel).
  static const _fingerPresentQuality = 10;

  SecuGenBindings? _b;
  SecuGenSettings _settings = const SecuGenSettings();
  HSGFPM _h = nullptr;
  bool _deviceOpen = false;
  Pointer<Int32> _cancelFlag = nullptr;

  int _width = 0;
  int _height = 0;
  int _dpi = 500;
  int _maxTemplateSize = 0;

  SecuGenResponse handle(SecuGenRequest request) => switch (request) {
    final SecuGenOpenRequest r => _open(r),
    final SecuGenCaptureRequest r => _capture(r),
    final SecuGenFingerOnRequest r => _isFingerOn(r),
    final SecuGenCloseRequest r => _close(r),
  };

  // ── open ───────────────────────────────────────────────────────────────

  SecuGenResponse _open(SecuGenOpenRequest r) {
    _settings = r.settings;
    _cancelFlag = Pointer<Int32>.fromAddress(r.cancelFlagAddress);

    if (_b == null) {
      try {
        _b = SecuGenBindings(DynamicLibrary.open(r.dllPath));
      } catch (e) {
        return SecuGenResponse.failure(
          r.id,
          status: SecuGenLocalStatus.libraryLoadFailed,
          stage: 'load',
          detail: '${r.dllPath}: $e',
        );
      }
    }
    final b = _b!;

    // Yeniden açma (bağlantı koptuktan sonra): önceki nesneyi tamamen bırak.
    _release(b);

    return using((arena) {
      final pHandle = arena<HSGFPM>();
      var s = b.create(pHandle);
      if (s != Sg.errNone || pHandle.value == nullptr) return _fail(r.id, s, 'create');
      _h = pHandle.value;

      // SecuGen'in önerdiği akış: listele → ilk okuyucunun tipiyle Init → Open.
      // (Bkz. "How to Develop Applications Compatible with All SecuGen USB Readers")
      final nDevs = arena<Uint32>();
      final pList = arena<Pointer<Uint8>>();
      s = b.enumerateDevice(_h, nDevs, pList);
      if (s != Sg.errNone) return _failAndRelease(b, r.id, s, 'enumerate');
      if (nDevs.value < 1 || pList.value == nullptr) {
        _release(b);
        return SecuGenResponse.failure(
          r.id,
          status: SecuGenLocalStatus.noScanner,
          stage: 'enumerate',
          detail: 'SGFPM_EnumerateDevice: 0 okuyucu (SecuGen sürücüsü kurulu mu?)',
        );
      }
      // Liste SDK içinde ayrılıyor; serbest bırakma API'si yok (açılışta bir kez, küçük).
      final devName = readU32(pList.value, Sg.deviceListDevNameOffset);
      final listSerial = readAsciiSn(pList.value, Sg.deviceListSnOffset);

      s = b.init(_h, devName);
      if (s != Sg.errNone) return _failAndRelease(b, r.id, s, 'init');

      s = b.openDevice(_h, Sg.usbAutoDetect);
      if (s != Sg.errNone) return _failAndRelease(b, r.id, s, 'openDevice');
      _deviceOpen = true;

      final info = arena<Uint8>(Sg.deviceInfoSize);
      s = b.getDeviceInfo(_h, info);
      if (s != Sg.errNone) return _failAndRelease(b, r.id, s, 'deviceInfo');
      _width = readU32(info, Sg.deviceInfoWidthOffset);
      _height = readU32(info, Sg.deviceInfoHeightOffset);
      final dpi = readU32(info, Sg.deviceInfoDpiOffset);
      _dpi = dpi > 0 ? dpi : 500;
      if (_width <= 0 || _height <= 0 || _width * _height > 2000 * 2000) {
        return _failAndRelease(b, r.id, Sg.errInitializeFailed, 'deviceInfo:size');
      }

      s = b.setTemplateFormat(_h, _sdkTemplateFormat(_settings.templateFormat));
      if (s != Sg.errNone) return _failAndRelease(b, r.id, s, 'templateFormat');

      final maxSize = arena<Uint32>();
      s = b.getMaxTemplateSize(_h, maxSize);
      if (s != Sg.errNone || maxSize.value == 0) return _failAndRelease(b, r.id, s, 'maxTemplateSize');
      _maxTemplateSize = maxSize.value;

      // Opsiyonel özellikler: başarısızlık açılışı engellemez.
      if (_settings.smartCapture) b.enableSmartCapture(_h, true);

      var liveness = false;
      if (_settings.liveness && secuGenSupportsLiveness(devName)) {
        liveness = b.enableCheckOfFingerLiveness(_h, 1) == Sg.errNone;
        final level = _settings.fakeDetectionLevel;
        if (liveness && level != null) b.setFakeDetectionLevel(_h, level);
      }

      return SecuGenResponse.ok(
        r.id,
        SecuGenDeviceInfo(
          devName: devName,
          imageWidth: _width,
          imageHeight: _height,
          imageDpi: _dpi,
          livenessActive: liveness,
          serial: readAsciiSn(info, Sg.deviceInfoSnOffset) ?? listSerial,
          firmware: readU32(info, Sg.deviceInfoFwOffset).toRadixString(16),
        ),
      );
    });
  }

  // ── capture ────────────────────────────────────────────────────────────

  SecuGenResponse _capture(SecuGenCaptureRequest r) {
    final b = _b;
    if (b == null || !_deviceOpen) {
      return SecuGenResponse.failure(r.id, status: SecuGenLocalStatus.notOpen, stage: 'capture');
    }

    return using((arena) {
      final image = arena<Uint8>(_width * _height);

      // ── Dilimli bekleme: parmak gelene, süre dolana ya da iptale kadar ──
      final deadline = DateTime.now().add(Duration(milliseconds: r.timeoutMs));
      var status = Sg.errTimeOut;
      while (true) {
        if (_cancelFlag != nullptr && _cancelFlag.value != 0) {
          return SecuGenResponse.failure(r.id, status: SecuGenLocalStatus.cancelled, stage: 'capture');
        }
        final remaining = deadline.difference(DateTime.now()).inMilliseconds;
        if (remaining <= 0) break;
        final slice = remaining < _sliceMs ? remaining : _sliceMs;

        status = b.getImageEx(_h, image, slice, nullptr, _settings.captureAreaQuality);
        if (status != Sg.errTimeOut) break; // başarı ya da gerçek hata
      }
      if (status != Sg.errNone) return _fail(r.id, status, 'capture');

      // Sırt kalitesi (0–100).
      final quality = arena<Uint32>();
      var s = b.getImageQuality(_h, _width, _height, image, quality);
      if (s != Sg.errNone) return _fail(r.id, s, 'quality');

      // Şablon.
      final fingerInfo = arena<Uint8>(Sg.fingerInfoSize);
      ByteData.sublistView(fingerInfo.asTypedList(Sg.fingerInfoSize))
        ..setUint16(0, Sg.fingerUnknown, Endian.little) // FingerNumber
        ..setUint16(2, 0, Endian.little) // ViewNumber
        ..setUint16(4, Sg.impressionLivePlain, Endian.little) // ImpressionType
        ..setUint16(6, quality.value.clamp(0, 100), Endian.little); // ImageQuality

      final template = arena<Uint8>(_maxTemplateSize);
      s = b.createTemplate(_h, fingerInfo, image, template);
      if (s != Sg.errNone) return _fail(r.id, s, 'extract');

      final size = arena<Uint32>();
      s = b.getTemplateSize(_h, template, size);
      if (s != Sg.errNone) return _fail(r.id, s, 'templateSize');
      final length = size.value;
      if (length == 0 || length > _maxTemplateSize) {
        return SecuGenResponse.failure(
          r.id,
          status: SecuGenLocalStatus.invalidTemplate,
          stage: 'templateSize',
          detail: 'templateSize=$length max=$_maxTemplateSize',
        );
      }

      return SecuGenResponse.ok(
        r.id,
        SecuGenCaptureData(
          template: Uint8List.fromList(template.asTypedList(length)),
          quality: quality.value,
          image: r.includeImage
              ? FingerprintImage(
                  width: _width,
                  height: _height,
                  resolutionDpi: _dpi,
                  pixels: Uint8List.fromList(image.asTypedList(_width * _height)),
                )
              : null,
        ),
      );
    });
  }

  // ── isFingerOn (sezgisel) ──────────────────────────────────────────────

  SecuGenResponse _isFingerOn(SecuGenFingerOnRequest r) {
    final b = _b;
    if (b == null || !_deviceOpen) {
      return SecuGenResponse.failure(r.id, status: SecuGenLocalStatus.notOpen, stage: 'isFingerOn');
    }
    return using((arena) {
      final image = arena<Uint8>(_width * _height);
      var s = b.getImage(_h, image); // tek kare, kalite kontrolü yok
      if (s == Sg.errWrongImage) return SecuGenResponse.ok(r.id, false); // görüntü parmak değil
      if (s != Sg.errNone) return _fail(r.id, s, 'isFingerOn');
      final quality = arena<Uint32>();
      s = b.getImageQuality(_h, _width, _height, image, quality);
      if (s != Sg.errNone) return _fail(r.id, s, 'isFingerOn:quality');
      return SecuGenResponse.ok(r.id, quality.value >= _fingerPresentQuality);
    });
  }

  // ── close ──────────────────────────────────────────────────────────────

  SecuGenResponse _close(SecuGenCloseRequest r) {
    final b = _b;
    if (b != null) _release(b);
    return SecuGenResponse.ok(r.id, null);
  }

  void _release(SecuGenBindings b) {
    if (_h == nullptr) return;
    if (_deviceOpen) b.closeDevice(_h);
    b.terminate(_h);
    _h = nullptr;
    _deviceOpen = false;
  }

  // ── yardımcılar ────────────────────────────────────────────────────────

  SecuGenResponse _fail(int id, int status, String stage) =>
      SecuGenResponse.failure(id, status: status, stage: stage);

  SecuGenResponse _failAndRelease(SecuGenBindings b, int id, int status, String stage) {
    _release(b);
    return _fail(id, status, stage);
  }

  static int _sdkTemplateFormat(FingerprintTemplateFormat f) => switch (f) {
    FingerprintTemplateFormat.iso19794_2 => Sg.templateFormatIso19794,
    FingerprintTemplateFormat.ansi378 => Sg.templateFormatAnsi378,
    // "suprema" formatının SecuGen karşılığı yok; SecuGen'e özgü SG400 kullanılır.
    FingerprintTemplateFormat.suprema => Sg.templateFormatSg400,
  };
}
