// pharmed-client/lib/core/hardware/fingerprint/biomini_fingerprint_scanner.dart
//
// [SWREQ-FP-013] [IEC 62304 §5.5]
// Suprema/Xperix BioMini (Slim 2S) parmak izi okuyucu — IFingerprintScanner uygulaması.
//
// Yapı:
//   Ana isolate (bu sınıf)          Worker isolate (biomini_worker.dart)
//   ─────────────────────           ───────────────────────────────────
//   open()/capture()/... ─istek──▶  UFScanner.dll (UFS_* çağrıları, bloklayıcı)
//                        ◀─yanıt──
//   cancelCapture() ── UFS_AbortCapturing (doğrudan, ana isolate'ten)
//
//   Worker bir capture içinde bloklanmışken mesaj işleyemez; bu yüzden iptal,
//   ana isolate'te ayrı yüklenen UFS_AbortCapturing ile ve worker'dan alınan
//   handle adresiyle yapılır (aynı süreç, aynı DLL modülü).
//
// Canlılık (LFD): Slim 2S'te yalnızca cihaz üstü modda (BioMiniCaptureMode.device)
// çalışır. Sahte parmak → FingerprintFailureReason.fakeFinger.
//
// KVKK: Şablon ve görüntü loglanmaz; yalnızca boyut/kalite/skor loglanır.
//
// Sınıf: Class B

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'biomini/biomini_bindings.dart';
import 'biomini/biomini_settings.dart';
import 'biomini/biomini_worker.dart';

class BioMiniFingerprintScanner implements IFingerprintScanner {
  BioMiniFingerprintScanner({this.settings = const BioMiniSettings(), String? dllPath})
    : dllPath = dllPath ?? resolveBioMiniDllPath();

  static const vendor = 'suprema';

  static const _unit = 'SW-UNIT-FP';
  static const _swreqOpen = 'SWREQ-FP-020';
  static const _swreqCapture = 'SWREQ-FP-021';
  static const _swreqCancel = 'SWREQ-FP-022';
  static const _swreqClose = 'SWREQ-FP-023';

  final BioMiniSettings settings;
  final String dllPath;

  Isolate? _isolate;
  ReceivePort? _inbox;
  SendPort? _worker;
  Future<void>? _starting;
  final _pending = <int, Completer<BioMiniResponse>>{};
  int _nextId = 0;

  BioMiniDeviceInfo? _device;
  Future<Result<FingerprintScannerInfo>>? _opening;
  BioMiniAbortBinding? _abortBinding;

  bool _capturing = false;
  bool _cancelRequested = false;

  @override
  bool get isOpen => _device != null;

  // ── open ───────────────────────────────────────────────────────────────

  @override
  Future<Result<FingerprintScannerInfo>> open() {
    final device = _device;
    if (device != null) return Future.value(Result.ok(_infoOf(device)));
    // Eşzamanlı open() çağrıları tek bir açma işlemini paylaşır.
    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  Future<Result<FingerprintScannerInfo>> _open() async {
    final started = await _ensureWorker();
    if (started != null) return Result.error(started);

    final res = await _send((id) => BioMiniOpenRequest(id, dllPath: dllPath, settings: settings));
    if (!res.isOk) {
      return _failure(res, swreq: _swreqOpen, message: 'Parmak izi okuyucu açılamadı');
    }

    final device = res.payload! as BioMiniDeviceInfo;
    _device = device;
    final info = _infoOf(device);

    MedLogger.info(
      unit: _unit,
      swreq: _swreqOpen,
      message: 'Parmak izi okuyucu açıldı',
      context: {
        'vendor': vendor,
        'model': info.model,
        'scannerType': info.scannerType,
        'serial': info.serial,
        'sdkVersion': info.sdkVersion,
        'settings': settings.toString(),
      },
    );
    if (!settings.lfdActive) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreqOpen,
        message: 'Canlılık kontrolü (LFD) kapalı — sahte parmak tespit edilmeyecek',
        context: {'captureMode': settings.captureMode.name, 'lfdLevel': settings.lfdLevel},
      );
    }
    if (device.scannerType != Ufs.scannerTypeBms2s) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreqOpen,
        message: 'Beklenen okuyucu BioMini Slim 2S değil; ayarlar doğrulanmalı',
        context: {'scannerType': device.scannerType},
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
      // SDK'da 0 = sonsuz bekleme; iptal edilemeyen bir bekleme istemiyoruz.
      return _localFailure(FingerprintFailureReason.unexpected, _swreqCapture, 'Geçersiz timeout: $timeout');
    }

    _capturing = true;
    _cancelRequested = false;
    try {
      final res = await _send(
        (id) => BioMiniCaptureRequest(id, timeoutMs: timeout.inMilliseconds, includeImage: includeImage),
      );

      if (!res.isOk) {
        if (_cancelRequested) {
          return _localFailure(FingerprintFailureReason.cancelled, _swreqCapture, 'Okuma iptal edildi', log: false);
        }
        return _failure(res, swreq: _swreqCapture, message: 'Parmak izi okunamadı');
      }

      final data = res.payload! as BioMiniCaptureData;
      final context = {
        'quality': data.quality,
        'minQuality': minQuality,
        'lfdScore': data.lfdScore,
        'templateSize': data.template.length,
      };

      if (data.quality < minQuality) {
        MedLogger.warn(unit: _unit, swreq: _swreqCapture, message: 'Şablon kalitesi eşiğin altında', context: context);
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
          lfdScore: data.lfdScore,
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
    final device = _device;
    if (!_capturing || device == null || _cancelRequested) return;
    _cancelRequested = true;

    try {
      _abortBinding ??= BioMiniAbortBinding(DynamicLibrary.open(dllPath));
      final status = _abortBinding!.abortCapturing(Pointer<Void>.fromAddress(device.handleAddress));
      MedLogger.info(
        unit: _unit,
        swreq: _swreqCancel,
        message: 'Parmak izi okuma iptali istendi',
        context: {'status': status},
      );
    } catch (e) {
      // İptal edilemezse okuma en geç kendi timeout'unda biter ve
      // _cancelRequested sayesinde yine 'cancelled' olarak döner.
      MedLogger.warn(
        unit: _unit,
        swreq: _swreqCancel,
        message: 'UFS_AbortCapturing çağrılamadı; okuma timeout ile bitecek',
        context: {'error': e.toString()},
      );
    }
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
    final res = await _send(BioMiniFingerOnRequest.new);
    if (!res.isOk) return _failure(res, swreq: _swreqCapture, message: 'Parmak durumu okunamadı');
    return Result.ok(res.payload! as bool);
  }

  // ── close ──────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    if (_capturing) await cancelCapture();

    final worker = _worker;
    if (worker != null) {
      final res = await _send(BioMiniCloseRequest.new).timeout(
        const Duration(seconds: 15), // iptal çalışmazsa capture'ın timeout'unu bekler
        onTimeout: () =>
            const BioMiniResponse.failure(-1, status: BioMiniLocalStatus.workerException, stage: 'close-timeout'),
      );
      if (!res.isOk) {
        MedLogger.warn(
          unit: _unit,
          swreq: _swreqClose,
          message: 'Okuyucu temiz kapatılamadı',
          context: {'status': res.status, 'stage': res.stage, 'sdkMessage': res.sdkMessage},
        );
      }
    }
    _shutdownWorker();
    MedLogger.info(unit: _unit, swreq: _swreqClose, message: 'Parmak izi okuyucu kapatıldı');
  }

  // ── worker yönetimi ────────────────────────────────────────────────────

  /// Hata durumunda AppException, başarıda null.
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
        message: 'Parmak izi worker isolate başlatılamadı',
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
    final inbox = ReceivePort('biomini-main');
    final ready = Completer<SendPort>();
    _inbox = inbox;

    inbox.listen((Object? message) {
      switch (message) {
        case final SendPort port:
          if (!ready.isCompleted) ready.complete(port);
        case final BioMiniResponse response:
          _pending.remove(response.id)?.complete(response);
        case null:
          // onExit: worker beklenmedik biçimde (veya close sonrası) sonlandı.
          _onWorkerExit();
      }
    });

    _isolate = await Isolate.spawn(
      bioMiniWorkerMain,
      inbox.sendPort,
      debugName: 'biomini-worker',
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
      MedLogger.error(
        unit: _unit,
        swreq: _swreqCapture,
        message: 'Parmak izi worker isolate işlem sırasında sonlandı',
      );
    }
  }

  void _shutdownWorker() {
    _failAllPending('shutdown');
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _worker = null;
    _inbox?.close();
    _inbox = null;
    _device = null;
  }

  void _failAllPending(String stage) {
    final pending = Map.of(_pending);
    _pending.clear();
    for (final entry in pending.entries) {
      entry.value.complete(
        BioMiniResponse.failure(entry.key, status: BioMiniLocalStatus.workerException, stage: stage),
      );
    }
  }

  Future<BioMiniResponse> _send(BioMiniRequest Function(int id) build) {
    final worker = _worker;
    final id = _nextId++;
    if (worker == null) {
      return Future.value(BioMiniResponse.failure(id, status: BioMiniLocalStatus.notOpen, stage: 'send'));
    }
    final completer = Completer<BioMiniResponse>();
    _pending[id] = completer;
    worker.send(build(id));
    return completer.future;
  }

  // ── hata eşleme ────────────────────────────────────────────────────────

  Result<T> _failure<T>(BioMiniResponse res, {required String swreq, required String message}) {
    final reason = reasonOf(res.status);

    // Bağlantı kopmuş olabilir: bir sonraki open() UFS_Update ile yeniden bağlansın.
    if (reason == FingerprintFailureReason.deviceDisconnected ||
        reason == FingerprintFailureReason.deviceNotFound ||
        res.status == Ufs.error ||
        res.status == Ufs.errCaptureFailed) {
      _device = null;
    }

    final context = {
      'reason': reason.name,
      'status': res.status,
      'stage': res.stage,
      'sdkMessage': res.sdkMessage,
      if (res.lfdScore != null) 'lfdScore': res.lfdScore,
    };

    // Kullanıcı kaynaklı, beklenen durumlar warn; donanım/yazılım sorunları error.
    final expected = switch (reason) {
      FingerprintFailureReason.timeout ||
      FingerprintFailureReason.fingerOnSensor ||
      FingerprintFailureReason.lowQuality ||
      FingerprintFailureReason.extractionFailed ||
      FingerprintFailureReason.fakeFinger ||
      FingerprintFailureReason.sensorDirty => true,
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
    if (log) MedLogger.warn(unit: _unit, swreq: swreq, message: message, context: {'reason': reason.name});
    return Result.error(FingerprintException(message: message, reason: reason));
  }

  /// UFS_STATUS / [BioMiniLocalStatus] → [FingerprintFailureReason].
  static FingerprintFailureReason reasonOf(int status) => switch (status) {
    BioMiniLocalStatus.libraryLoadFailed || Ufs.errLoadScannerLibrary => FingerprintFailureReason.libraryNotFound,
    BioMiniLocalStatus.noScanner ||
    Ufs.errNoLicense || // SDK: "Device is not connected or License is not located"
    Ufs.errDeviceNumberExceed => FingerprintFailureReason.deviceNotFound,
    Ufs.errDeviceNotRespond || Ufs.errUsbTimeout || Ufs.errNotInitialized => FingerprintFailureReason.deviceDisconnected,
    BioMiniLocalStatus.notOpen => FingerprintFailureReason.notOpen,
    Ufs.errCaptureRunning => FingerprintFailureReason.busy,
    Ufs.errCaptureTimeout || Ufs.errTimeout => FingerprintFailureReason.timeout,
    Ufs.errFingerOnSensor => FingerprintFailureReason.fingerOnSensor,
    Ufs.errFakeFinger => FingerprintFailureReason.fakeFinger,
    Ufs.errNotGoodImage => FingerprintFailureReason.lowQuality,
    Ufs.errSensorDirty => FingerprintFailureReason.sensorDirty,
    Ufs.errExtractionFailed || BioMiniLocalStatus.invalidTemplate => FingerprintFailureReason.extractionFailed,
    >= -359 && <= -351 => FingerprintFailureReason.extractionFailed, // çekirdek bulunamadı / kaymış
    >= -405 && <= -401 => FingerprintFailureReason.extractionFailed, // parmak sensöre yanlış yerleşmiş
    _ => FingerprintFailureReason.unexpected,
  };

  FingerprintScannerInfo _infoOf(BioMiniDeviceInfo d) => FingerprintScannerInfo(
    vendor: vendor,
    // LFD parametresi açılışta cihaza yazılamasaydı open() zaten başarısız olurdu.
    livenessActive: settings.lfdActive,
    model: bioMiniModelName(d.scannerType),
    scannerType: d.scannerType,
    serial: d.serial,
    sdkVersion: d.sdkVersion,
  );
}
