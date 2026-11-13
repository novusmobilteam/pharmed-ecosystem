// pharmed-client/lib/core/hardware/fingerprint/secugen_fingerprint_scanner.dart
//
// [SWREQ-FP-053] [IEC 62304 §5.5]
// SecuGen (U10 / Hamster Pro 10 ve diğer USB modelleri) — IFingerprintScanner uygulaması.
//
// Yapı BioMiniFingerprintScanner ile aynıdır: SDK uzun ömürlü bir worker isolate'te,
// bu sınıf ana isolate'te istek/yanıt ve loglamayı yönetir. Farklar:
//   * İptal: SDK'da abort yok; ana isolate native bellekteki bir bayrağı 1 yapar,
//     worker okuma dilimleri arasında bunu görüp 'cancelled' döner (≤ 1 sn).
//   * Canlılık: Kılavuza göre yalnızca U20 ailesinde var. U10'da livenessActive=false
//     ve açılışta uyarı loglanır.
//   * Kalite ölçeği: SGFPM_GetImageQuality (0–100; doğrulama ≥40, kayıt ≥50).
//
// KVKK: Şablon ve görüntü loglanmaz.
//
// Sınıf: Class B

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'secugen/secugen_bindings.dart';
import 'secugen/secugen_settings.dart';
import 'secugen/secugen_worker.dart';

class SecuGenFingerprintScanner implements IFingerprintScanner {
  SecuGenFingerprintScanner({this.settings = const SecuGenSettings(), String? dllPath})
    : dllPath = dllPath ?? resolveSecuGenDllPath();

  static const vendor = 'secugen';

  static const _unit = 'SW-UNIT-FP';
  static const _swreqOpen = 'SWREQ-FP-060';
  static const _swreqCapture = 'SWREQ-FP-061';
  static const _swreqCancel = 'SWREQ-FP-062';
  static const _swreqClose = 'SWREQ-FP-063';

  final SecuGenSettings settings;
  final String dllPath;

  Isolate? _isolate;
  ReceivePort? _inbox;
  SendPort? _worker;
  Future<void>? _starting;
  final _pending = <int, Completer<SecuGenResponse>>{};
  int _nextId = 0;

  /// Worker'ın okuma dilimleri arasında okuduğu iptal bayrağı (native, süreç geneli).
  Pointer<Int32> _cancelFlag = nullptr;

  SecuGenDeviceInfo? _device;
  Future<Result<FingerprintScannerInfo>>? _opening;

  bool _capturing = false;
  bool _cancelRequested = false;

  @override
  bool get isOpen => _device != null;

  // ── open ───────────────────────────────────────────────────────────────

  @override
  Future<Result<FingerprintScannerInfo>> open() {
    final device = _device;
    if (device != null) return Future.value(Result.ok(_infoOf(device)));
    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  Future<Result<FingerprintScannerInfo>> _open() async {
    final started = await _ensureWorker();
    if (started != null) return Result.error(started);

    final res = await _send(
      (id) => SecuGenOpenRequest(id, dllPath: dllPath, settings: settings, cancelFlagAddress: _cancelFlag.address),
    );
    if (!res.isOk) return _failure(res, swreq: _swreqOpen, message: 'SecuGen okuyucu açılamadı');

    final device = res.payload! as SecuGenDeviceInfo;
    _device = device;
    final info = _infoOf(device);

    MedLogger.info(
      unit: _unit,
      swreq: _swreqOpen,
      message: 'Parmak izi okuyucu açıldı',
      context: {
        'vendor': vendor,
        'model': info.model,
        'devName': device.devName,
        'serial': info.serial,
        'firmware': device.firmware,
        'image': '${device.imageWidth}x${device.imageHeight}@${device.imageDpi}',
        'livenessActive': device.livenessActive,
        'settings': settings.toString(),
      },
    );
    if (!device.livenessActive) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreqOpen,
        message: 'Canlılık kontrolü (sahte parmak tespiti) bu okuyucuda etkin değil',
        context: {'model': info.model, 'requested': settings.liveness},
      );
    }
    return Result.ok(info);
  }

  // ── capture ────────────────────────────────────────────────────────────

  @override
  Future<Result<FingerprintCapture>> capture({
    Duration timeout = const Duration(seconds: 10),
    int minQuality = 30,
    bool includeImage = false,
  }) async {
    if (_device == null) {
      return _localFailure(FingerprintFailureReason.notOpen, _swreqCapture, 'Okuyucu açılmadan okuma istendi');
    }
    if (_capturing) {
      return _localFailure(FingerprintFailureReason.busy, _swreqCapture, 'Önceki okuma sürerken yeni okuma istendi');
    }
    if (timeout <= Duration.zero) {
      return _localFailure(FingerprintFailureReason.unexpected, _swreqCapture, 'Geçersiz timeout: $timeout');
    }

    _capturing = true;
    _cancelRequested = false;
    _cancelFlag.value = 0; // worker yalnızca okur; sıfırlama burada (yarış yok)
    try {
      final res = await _send(
        (id) => SecuGenCaptureRequest(id, timeoutMs: timeout.inMilliseconds, includeImage: includeImage),
      );

      if (!res.isOk) {
        if (_cancelRequested || res.status == SecuGenLocalStatus.cancelled) {
          return _localFailure(FingerprintFailureReason.cancelled, _swreqCapture, 'Okuma iptal edildi', log: false);
        }
        return _failure(res, swreq: _swreqCapture, message: 'Parmak izi okunamadı');
      }

      final data = res.payload! as SecuGenCaptureData;
      final context = {
        'vendor': vendor,
        'quality': data.quality,
        'minQuality': minQuality,
        'templateSize': data.template.length,
      };

      if (data.quality < minQuality) {
        MedLogger.warn(unit: _unit, swreq: _swreqCapture, message: 'Görüntü kalitesi eşiğin altında', context: context);
        return Result.error(
          FingerprintException(message: 'Parmak izi kalitesi yetersiz', reason: FingerprintFailureReason.lowQuality),
        );
      }

      MedLogger.info(unit: _unit, swreq: _swreqCapture, message: 'Parmak izi okundu', context: context);
      return Result.ok(
        FingerprintCapture(
          template: data.template,
          format: settings.templateFormat,
          quality: data.quality,
          lfdScore: null, // SecuGen SDK canlılık skoru döndürmez
          capturedAt: DateTime.now(),
          image: data.image,
        ),
      );
    } finally {
      _capturing = false;
      _cancelRequested = false;
    }
  }

  @override
  Future<void> cancelCapture() async {
    if (!_capturing || _cancelRequested || _cancelFlag == nullptr) return;
    _cancelRequested = true;
    _cancelFlag.value = 1;
    MedLogger.info(unit: _unit, swreq: _swreqCancel, message: 'Parmak izi okuma iptali istendi', context: {'vendor': vendor});
  }

  // ── isFingerOn ─────────────────────────────────────────────────────────

  @override
  Future<Result<bool>> isFingerOn() async {
    if (_device == null) {
      return _localFailure(FingerprintFailureReason.notOpen, _swreqCapture, 'Okuyucu açılmadan sorgu istendi');
    }
    if (_capturing) {
      return _localFailure(FingerprintFailureReason.busy, _swreqCapture, 'Okuma sürerken parmak sorgusu', log: false);
    }
    final res = await _send(SecuGenFingerOnRequest.new);
    if (!res.isOk) return _failure(res, swreq: _swreqCapture, message: 'Parmak durumu okunamadı');
    return Result.ok(res.payload! as bool);
  }

  // ── close ──────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    if (_capturing) await cancelCapture();

    if (_worker != null) {
      final res = await _send(SecuGenCloseRequest.new).timeout(
        const Duration(seconds: 15),
        onTimeout: () => const SecuGenResponse.failure(
          -1,
          status: SecuGenLocalStatus.workerException,
          stage: 'close-timeout',
        ),
      );
      if (!res.isOk) {
        MedLogger.warn(
          unit: _unit,
          swreq: _swreqClose,
          message: 'SecuGen okuyucu temiz kapatılamadı',
          context: {'status': res.status, 'stage': res.stage},
        );
      }
    }
    _shutdownWorker();
    MedLogger.info(unit: _unit, swreq: _swreqClose, message: 'Parmak izi okuyucu kapatıldı', context: {'vendor': vendor});
  }

  // ── worker yönetimi ────────────────────────────────────────────────────

  Future<AppException?> _ensureWorker() async {
    if (_worker != null) return null;
    try {
      await (_starting ??= _startWorker());
      return null;
    } catch (e) {
      _shutdownWorker();
      MedLogger.error(
        unit: _unit,
        swreq: _swreqOpen,
        message: 'SecuGen worker isolate başlatılamadı',
        context: {'error': e.toString()},
      );
      return FingerprintException(
        message: 'Parmak izi okuyucu başlatılamadı',
        reason: FingerprintFailureReason.unexpected,
        cause: e,
      );
    } finally {
      _starting = null;
    }
  }

  Future<void> _startWorker() async {
    if (_cancelFlag == nullptr) _cancelFlag = calloc<Int32>();

    final inbox = ReceivePort('secugen-main');
    final ready = Completer<SendPort>();
    _inbox = inbox;

    inbox.listen((Object? message) {
      switch (message) {
        case final SendPort port:
          if (!ready.isCompleted) ready.complete(port);
        case final SecuGenResponse response:
          _pending.remove(response.id)?.complete(response);
        case null:
          _onWorkerExit();
      }
    });

    _isolate = await Isolate.spawn(
      secuGenWorkerMain,
      inbox.sendPort,
      debugName: 'secugen-worker',
      onExit: inbox.sendPort,
      errorsAreFatal: true,
    );
    _worker = await ready.future.timeout(const Duration(seconds: 5));
  }

  void _onWorkerExit() {
    final hadPending = _pending.isNotEmpty;
    _failAllPending('worker-exit');
    _worker = null;
    _isolate = null;
    _device = null;
    _inbox?.close();
    _inbox = null;
    if (hadPending) {
      MedLogger.error(unit: _unit, swreq: _swreqCapture, message: 'SecuGen worker isolate işlem sırasında sonlandı');
    }
  }

  void _shutdownWorker() {
    _failAllPending('shutdown');
    final hadIsolate = _isolate != null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _worker = null;
    _inbox?.close();
    _inbox = null;
    _device = null;
    // Bayrak, worker native bir çağrıdayken hâlâ okunuyor olabilir; worker'ın kesin
    // bittiği bilinmiyorsa serbest bırakmak yerine sızdırmak güvenlidir (4 bayt).
    if (!hadIsolate && _cancelFlag != nullptr) {
      calloc.free(_cancelFlag);
      _cancelFlag = nullptr;
    }
  }

  void _failAllPending(String stage) {
    final pending = Map.of(_pending);
    _pending.clear();
    for (final entry in pending.entries) {
      entry.value.complete(
        SecuGenResponse.failure(entry.key, status: SecuGenLocalStatus.workerException, stage: stage),
      );
    }
  }

  Future<SecuGenResponse> _send(SecuGenRequest Function(int id) build) {
    final worker = _worker;
    final id = _nextId++;
    if (worker == null) {
      return Future.value(SecuGenResponse.failure(id, status: SecuGenLocalStatus.notOpen, stage: 'send'));
    }
    final completer = Completer<SecuGenResponse>();
    _pending[id] = completer;
    worker.send(build(id));
    return completer.future;
  }

  // ── hata eşleme ────────────────────────────────────────────────────────

  Result<T> _failure<T>(SecuGenResponse res, {required String swreq, required String message}) {
    final reason = reasonOf(res.status);

    if (reason == FingerprintFailureReason.deviceDisconnected ||
        reason == FingerprintFailureReason.deviceNotFound ||
        res.status == Sg.errFunctionFailed) {
      _device = null; // bir sonraki open() nesneyi baştan kursun
    }

    final context = {
      'vendor': vendor,
      'reason': reason.name,
      'status': res.status,
      'stage': res.stage,
      if (res.detail != null) 'detail': res.detail,
    };
    final expected = switch (reason) {
      FingerprintFailureReason.timeout ||
      FingerprintFailureReason.lowQuality ||
      FingerprintFailureReason.extractionFailed ||
      FingerprintFailureReason.fakeFinger => true,
      _ => false,
    };
    if (expected) {
      MedLogger.warn(unit: _unit, swreq: swreq, message: message, context: context);
    } else {
      MedLogger.error(unit: _unit, swreq: swreq, message: message, context: context);
    }
    return Result.error(FingerprintException(message: message, reason: reason, sdkStatus: res.status));
  }

  Result<T> _localFailure<T>(FingerprintFailureReason reason, String swreq, String message, {bool log = true}) {
    if (log) {
      MedLogger.warn(unit: _unit, swreq: swreq, message: message, context: {'vendor': vendor, 'reason': reason.name});
    }
    return Result.error(FingerprintException(message: message, reason: reason));
  }

  /// SGFDxErrorCode / [SecuGenLocalStatus] → [FingerprintFailureReason].
  static FingerprintFailureReason reasonOf(int status) => switch (status) {
    SecuGenLocalStatus.libraryLoadFailed ||
    Sg.errDllLoadFailed ||
    Sg.errDllLoadFailedAlgo ||
    Sg.errDllLoadFailedWsq => FingerprintFailureReason.libraryNotFound,
    SecuGenLocalStatus.noScanner ||
    Sg.errDllLoadFailedDrv || // cihaz sürücüsü yok
    Sg.errSysLoadFailed ||
    Sg.errInitializeFailed ||
    Sg.errDeviceNotFound ||
    Sg.errDrvLoadFailed ||
    Sg.errUnsupportedDev => FingerprintFailureReason.deviceNotFound,
    Sg.errLineDropped || Sg.errLackOfBandwidth => FingerprintFailureReason.deviceDisconnected,
    SecuGenLocalStatus.notOpen => FingerprintFailureReason.notOpen,
    Sg.errDevAlreadyOpen => FingerprintFailureReason.busy, // başka bir uygulama okuyucuyu tutuyor
    Sg.errTimeOut => FingerprintFailureReason.timeout,
    SecuGenLocalStatus.cancelled => FingerprintFailureReason.cancelled,
    Sg.errFakeFinger => FingerprintFailureReason.fakeFinger,
    Sg.errWrongImage ||
    Sg.errFeatNumber ||
    Sg.errExtractFail ||
    SecuGenLocalStatus.invalidTemplate => FingerprintFailureReason.extractionFailed,
    _ => FingerprintFailureReason.unexpected,
  };

  static FingerprintScannerInfo _infoOf(SecuGenDeviceInfo d) => FingerprintScannerInfo(
    vendor: vendor,
    model: secuGenModelName(d.devName),
    scannerType: d.devName,
    livenessActive: d.livenessActive,
    serial: d.serial,
    sdkVersion: 'FDx SDK Pro 4.3.1',
  );
}
