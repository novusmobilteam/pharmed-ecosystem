// pharmed-client/lib/features/fingerprint_test/notifier/fingerprint_test_notifier.dart
//
// [SWREQ-FP-040]
// Parmak izi okuyucu test ekranının durumu. Geliştirici/kurulum aracıdır:
//   - okuyucuyu açma/kapama, parmak sorgusu
//   - tek okuma ve giriş ekranını taklit eden sürekli okuma döngüsü
//   - kalite / canlılık skoru / süre istatistikleri (eşik ayarı için)
//   - servise gönderim SİMÜLASYONU (servis henüz yok)
//
// Sınıf: Class B

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/core/hardware/fingerprint/fingerprint.dart';
import 'package:pharmed_client/core/providers/fingerprint_providers.dart';

final fingerprintTestNotifierProvider = ChangeNotifierProvider.autoDispose<FingerprintTestNotifier>(
  (ref) => FingerprintTestNotifier(scanner: ref.read(fingerprintScannerProvider)),
);

/// Bir okuma denemesinin sonucu (başarılı ya da başarısız).
class FingerprintAttempt {
  const FingerprintAttempt({
    required this.at,
    required this.elapsed,
    this.capture,
    this.failure,
    this.sdkStatus,
  });

  final DateTime at;
  final Duration elapsed;
  final FingerprintCapture? capture;
  final FingerprintFailureReason? failure;
  final int? sdkStatus;

  bool get isSuccess => capture != null;
}

class FingerprintTestNotifier extends ChangeNotifier {
  FingerprintTestNotifier({required IFingerprintScanner scanner}) : _scanner = scanner;

  static const _unit = 'SW-UNIT-FP';
  static const _swreq = 'SWREQ-FP-040';
  static const _maxHistory = 50;

  final IFingerprintScanner _scanner;
  bool _disposed = false;

  // ── Okuyucu ───────────────────────────────────────────────────────────
  FingerprintScannerInfo? scannerInfo;
  bool isOpening = false;
  FingerprintFailureReason? openFailure;

  bool get isOpen => _scanner.isOpen;

  /// Gerçek okuyucuysa ayarları (LFD seviyesi, mod, format), mock'ta null.
  /// Otomatik seçimde gerçekten kullanılan okuyucu; değilse provider'daki okuyucu.
  IFingerprintScanner get _activeScanner => switch (_scanner) {
    final AutoFingerprintScanner a => a.active ?? a,
    _ => _scanner,
  };

  BioMiniSettings? get bioMiniSettings => switch (_activeScanner) {
    final BioMiniFingerprintScanner s => s.settings,
    _ => null,
  };

  /// Gerçek SecuGen okuyucusuysa ayarları, değilse null.
  SecuGenSettings? get secuGenSettings => switch (_activeScanner) {
    final SecuGenFingerprintScanner s => s.settings,
    _ => null,
  };

  bool get isMock => _scanner is MockFingerprintScanner;

  // ── Okuma ayarları ────────────────────────────────────────────────────
  int timeoutSeconds = 10;
  int minQuality = 30;
  bool includeImage = true;

  // ── Okuma durumu ──────────────────────────────────────────────────────
  bool isCapturing = false;
  bool isContinuous = false;

  /// Sürekli modda kullanıcıya gösterilen ara durum ("Parmağınızı kaldırın" vb.).
  String? continuousHint;

  final List<FingerprintAttempt> attempts = [];
  FingerprintAttempt? get lastAttempt => attempts.isEmpty ? null : attempts.first;

  /// En son BAŞARILI okuma — görüntü ve gönderim simülasyonu bunu kullanır.
  FingerprintCapture? lastCapture;

  // ── Parmak sorgusu ────────────────────────────────────────────────────
  bool? fingerOn;
  FingerprintFailureReason? fingerOnFailure;

  // ── Gönderim simülasyonu ──────────────────────────────────────────────
  bool isSending = false;
  String? payloadPreview;

  // ── İstatistikler ─────────────────────────────────────────────────────
  int get successCount => attempts.where((a) => a.isSuccess).length;
  int get failureCount => attempts.length - successCount;

  Map<FingerprintFailureReason, int> get failureCounts {
    final map = <FingerprintFailureReason, int>{};
    for (final a in attempts) {
      final f = a.failure;
      if (f != null) map[f] = (map[f] ?? 0) + 1;
    }
    return map;
  }

  double? get averageQuality => _average(attempts.map((a) => a.capture?.quality));
  double? get averageLfdScore => _average(attempts.map((a) => a.capture?.lfdScore));
  double? get averageCaptureMs =>
      _average(attempts.where((a) => a.isSuccess).map((a) => a.elapsed.inMilliseconds));

  // ─────────────────────────────────────────────────────────────────────
  // Okuyucu
  // ─────────────────────────────────────────────────────────────────────

  Future<void> open() async {
    if (isOpening) return;
    isOpening = true;
    openFailure = null;
    _notify();

    final result = await _scanner.open();
    isOpening = false;
    result.when(
      ok: (info) {
        scannerInfo = info;
      },
      error: (e) {
        scannerInfo = null;
        openFailure = _reasonOf(e);
      },
    );
    _notify();
  }

  Future<void> close() async {
    await stopContinuous();
    await _scanner.close();
    scannerInfo = null;
    fingerOn = null;
    _notify();
  }

  Future<void> checkFingerOn() async {
    final result = await _scanner.isFingerOn();
    result.when(
      ok: (on) {
        fingerOn = on;
        fingerOnFailure = null;
      },
      error: (e) {
        fingerOn = null;
        fingerOnFailure = _reasonOf(e);
      },
    );
    _notify();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Okuma
  // ─────────────────────────────────────────────────────────────────────

  Future<void> captureOnce() async {
    if (isCapturing || !isOpen) return;
    await _capture();
  }

  /// Giriş ekranı davranışını taklit eder: başarılı okumadan sonra parmağın
  /// kalkmasını bekler ve tekrar dinlemeye başlar. Durdurulana kadar sürer.
  Future<void> startContinuous() async {
    if (isCapturing || isContinuous || !isOpen) return;
    isContinuous = true;
    _notify();

    while (isContinuous && !_disposed) {
      continuousHint = 'Parmağınızı okuyucuya koyun';
      _notify();

      final attempt = await _capture();
      if (!isContinuous || _disposed) break;

      switch (attempt.failure) {
        case FingerprintFailureReason.cancelled:
        case FingerprintFailureReason.notOpen:
        case FingerprintFailureReason.deviceDisconnected:
        case FingerprintFailureReason.deviceNotFound:
        case FingerprintFailureReason.libraryNotFound:
          isContinuous = false; // tekrar denemenin anlamı yok
        case FingerprintFailureReason.fingerOnSensor:
          await _waitForFingerLift();
        case null:
          // Başarılı: giriş ekranında burada servise gidilir. Sonraki okuma
          // için parmağın kalkması SDK'da da zorunlu (FINGER_CHECK).
          await _waitForFingerLift();
        default:
          // timeout, düşük kalite, sahte parmak vb.: kısa bekleyip tekrar dinle.
          await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }

    isContinuous = false;
    continuousHint = null;
    _notify();
  }

  Future<void> stopContinuous() async {
    if (!isContinuous) return;
    isContinuous = false;
    continuousHint = null;
    _notify();
    await _scanner.cancelCapture();
  }

  Future<void> cancelCapture() => _scanner.cancelCapture();

  Future<FingerprintAttempt> _capture() async {
    isCapturing = true;
    _notify();

    final watch = Stopwatch()..start();
    final result = await _scanner.capture(
      timeout: Duration(seconds: timeoutSeconds),
      minQuality: minQuality,
      includeImage: includeImage,
    );
    watch.stop();

    final attempt = result.when(
      ok: (capture) => FingerprintAttempt(at: DateTime.now(), elapsed: watch.elapsed, capture: capture),
      error: (e) => FingerprintAttempt(
        at: DateTime.now(),
        elapsed: watch.elapsed,
        failure: _reasonOf(e),
        sdkStatus: e is FingerprintException ? e.sdkStatus : null,
      ),
    );

    if (attempt.capture != null) {
      lastCapture = attempt.capture;
      payloadPreview = null; // yeni okuma → eski önizleme geçersiz
    }
    attempts.insert(0, attempt);
    if (attempts.length > _maxHistory) attempts.removeLast();

    isCapturing = false;
    _notify();
    return attempt;
  }

  Future<void> _waitForFingerLift() async {
    continuousHint = 'Parmağınızı kaldırın';
    _notify();
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (isContinuous && !_disposed && DateTime.now().isBefore(deadline)) {
      final on = await _scanner.isFingerOn();
      if (on.data == false) return;
      if (on.isError) {
        // Sorgu desteklenmiyorsa kısa bir bekleme yeterli; SDK zaten
        // parmak kalkmadan yeni okuma yapmıyor.
        await Future<void>.delayed(const Duration(milliseconds: 800));
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Ayarlar
  // ─────────────────────────────────────────────────────────────────────

  void setTimeoutSeconds(int value) {
    timeoutSeconds = value.clamp(3, 30);
    _notify();
  }

  void setMinQuality(int value) {
    minQuality = value.clamp(10, 90);
    _notify();
  }

  void setIncludeImage(bool value) {
    includeImage = value;
    _notify();
  }

  void clearHistory() {
    attempts.clear();
    _notify();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Servise gönderim — SİMÜLASYON
  // ─────────────────────────────────────────────────────────────────────

  /// Servis hazır olduğunda bu gövde `EnrollFingerprintUseCase` → DTO'ya taşınır.
  /// Kullanıcı kimliği gövdede yok: token'dan alınacak.
  Future<void> simulateSend() async {
    final capture = lastCapture;
    if (capture == null || isSending) return;
    isSending = true;
    _notify();

    final payload = {
      'templateBase64': base64Encode(capture.template),
      'templateFormat': capture.format.wireName,
      'quality': capture.quality,
      'lfdScore': capture.lfdScore,
      'capturedAt': capture.capturedAt.toUtc().toIso8601String(),
      // Sunucu, şablonun hangi okuyucudan geldiğini bilsin (kalite ölçekleri üreticiye göre farklı).
      'scannerVendor': scannerInfo?.vendor,
      'scannerModel': scannerInfo?.model,
      'livenessActive': scannerInfo?.livenessActive,
    };

    // KVKK: şablonun kendisi loglanmaz.
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Parmak izi gönderimi simüle edildi (servis yok)',
      context: {
        'templateFormat': capture.format.wireName,
        'templateSize': capture.templateSize,
        'quality': capture.quality,
        'lfdScore': capture.lfdScore,
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 600)); // ağ gecikmesi taklidi

    final b64 = payload['templateBase64']! as String;
    final preview = Map.of(payload)
      ..['templateBase64'] = b64.length <= 48
          ? b64
          : '${b64.substring(0, 24)}…${b64.substring(b64.length - 12)} (${b64.length} karakter)';
    payloadPreview = const JsonEncoder.withIndent('  ').convert(preview);

    isSending = false;
    _notify();
  }

  // ─────────────────────────────────────────────────────────────────────

  static FingerprintFailureReason _reasonOf(AppException e) =>
      e is FingerprintException ? e.reason : FingerprintFailureReason.unexpected;

  static double? _average(Iterable<int?> values) {
    final list = values.whereType<int>().toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    isContinuous = false;
    // Okuyucu global; ekran kapanınca kapatılmaz, yalnızca bekleyen okuma iptal edilir.
    unawaited(_scanner.cancelCapture());
    super.dispose();
  }
}
