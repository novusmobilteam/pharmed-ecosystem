// pharmed-client/lib/features/fingerprint_login/notifier/fingerprint_login_notifier.dart
//
// [SWREQ-FP-103] [SWREQ-FP-104] [SWREQ-FP-105]
// Giriş penceresindeki parmak izi dinleyicisi.
//
// Akış:
//   1. Okuyucu açılır (açılamazsa 'unavailable', kullanıcı yeniden deneyebilir).
//   2. Sensörde parmak varsa önce kalkması beklenir — önceki dokunuş giriş denemesi sayılmaz (FP-104).
//   3. capture() → şablon servise gönderilir; eşleştirme sunucuda yapılır (FP-103).
//   4. Art arda [maxFailedAttempts] başarısız eşleşmeden sonra [cooldown] boyunca dinleme durur (FP-105).
//   5. Uzun süre parmak gelmezse dinleme durur ('idle'); okuyucu boşuna meşgul edilmez.
//
// Şablonlar yalnızca bellekte tutulur, loglanmaz.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'package:pharmed_client/core/providers/fingerprint_providers.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';

/// Şablonu servise gönderip giriş yapar. Başarılıysa true; hata mesajı [onError]'a verilir.
typedef FingerprintLoginCallback =
    Future<bool> Function(FingerprintCapture capture, FingerprintScannerInfo scanner, ValueChanged<String> onError);

final fingerprintLoginNotifierProvider = ChangeNotifierProvider.autoDispose<FingerprintLoginNotifier>((ref) {
  final auth = ref.read(authNotifierProvider.notifier);
  return FingerprintLoginNotifier(
    scanner: ref.read(fingerprintScannerProvider),
    login: (capture, scanner, onError) =>
        auth.loginWithFingerprint(capture: capture, scanner: scanner, onError: onError),
  );
});

enum FingerprintLoginStatus {
  /// Okuyucu açılıyor.
  opening,

  /// Okuyucu yok / açılamadı. [FingerprintLoginNotifier.scannerFailure] nedeni taşır.
  unavailable,

  /// Sensörde kalmış parmağın kalkması bekleniyor.
  waitingLift,

  /// Parmak bekleniyor.
  listening,

  /// Şablon serviste doğrulanıyor.
  checking,

  /// Çok fazla başarısız deneme — geri sayım.
  cooldown,

  /// Uzun süre parmak gelmedi; kullanıcı yeniden başlatmalı.
  idle,

  /// Giriş başarılı.
  success,
}

class FingerprintLoginNotifier extends ChangeNotifier {
  FingerprintLoginNotifier({required IFingerprintScanner scanner, required FingerprintLoginCallback login})
    : _scanner = scanner,
      _login = login;

  static const _unit = 'SW-UNIT-FP';

  static const captureTimeout = Duration(seconds: 10);
  static const maxFailedAttempts = 3;
  static const cooldown = Duration(seconds: 30);

  /// Bu kadar art arda zaman aşımından (~1 dk) sonra dinleme durur.
  static const _maxIdleTimeouts = 6;

  final IFingerprintScanner _scanner;
  final FingerprintLoginCallback _login;

  bool _disposed = false;
  bool _running = false;
  bool _stopRequested = false;
  Timer? _cooldownTimer;

  FingerprintLoginStatus status = FingerprintLoginStatus.opening;
  FingerprintScannerInfo? scannerInfo;
  FingerprintFailureReason? scannerFailure;

  /// Son okuma denemesinin okuyucu tarafı hatası (kalite düşük vb.) — kullanıcıya ipucu.
  FingerprintFailureReason? lastCaptureFailure;

  /// Servisten dönen son hata mesajı (eşleşme yok, servis hazır değil vb.).
  String? message;

  int failedAttempts = 0;
  int cooldownSecondsLeft = 0;

  // ─────────────────────────────────────────────────────────────────────

  /// Okuyucuyu açar ve dinlemeye başlar. Zaten çalışıyorsa bir şey yapmaz.
  Future<void> start() async {
    if (_running || _disposed || status == FingerprintLoginStatus.cooldown) return;
    _running = true;
    _stopRequested = false;
    lastCaptureFailure = null;
    try {
      if (!await _ensureOpen()) return;
      await _loop();
    } finally {
      _running = false;
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    await _scanner.cancelCapture();
  }

  Future<bool> _ensureOpen() async {
    if (_scanner.isOpen && scannerInfo != null) return true;
    _set(FingerprintLoginStatus.opening);
    final result = await _scanner.open();
    if (_disposed) return false;
    return result.when(
      ok: (info) {
        scannerInfo = info;
        scannerFailure = null;
        return true;
      },
      error: (e) {
        scannerInfo = null;
        scannerFailure = e is FingerprintException ? e.reason : FingerprintFailureReason.unexpected;
        _set(FingerprintLoginStatus.unavailable);
        return false;
      },
    );
  }

  Future<void> _loop() async {
    var idleTimeouts = 0;

    while (!_disposed && !_stopRequested) {
      await _waitForFingerLift();
      if (_disposed || _stopRequested) return;

      _set(FingerprintLoginStatus.listening);
      final result = await _scanner.capture(
        timeout: captureTimeout,
        minQuality: FingerprintEnrollmentRules.minLoginQuality,
      );
      if (_disposed || _stopRequested) return;

      final (capture, failure) = result.when<(FingerprintCapture?, FingerprintFailureReason?)>(
        ok: (c) {
          return (c, null);
        },
        error: (e) {
          return (null, e is FingerprintException ? e.reason : FingerprintFailureReason.unexpected);
        },
      );

      if (capture == null) {
        final reason = failure ?? FingerprintFailureReason.unexpected;
        switch (reason) {
          case FingerprintFailureReason.timeout:
            lastCaptureFailure = null;
            idleTimeouts++;
            if (idleTimeouts >= _maxIdleTimeouts) {
              _set(FingerprintLoginStatus.idle);
              return;
            }
          case FingerprintFailureReason.cancelled:
            return;
          case FingerprintFailureReason.busy:
            // Okuyucu başka bir ekranda kullanılıyor olabilir — kısa bekleyip tekrar dene,
            // uzun sürerse beklemeye geç.
            idleTimeouts++;
            if (idleTimeouts >= _maxIdleTimeouts) {
              _set(FingerprintLoginStatus.idle);
              return;
            }
            await Future<void>.delayed(const Duration(seconds: 1));
          case FingerprintFailureReason.lowQuality ||
              FingerprintFailureReason.extractionFailed ||
              FingerprintFailureReason.fingerOnSensor ||
              FingerprintFailureReason.fakeFinger ||
              FingerprintFailureReason.sensorDirty:
            idleTimeouts = 0;
            lastCaptureFailure = reason;
            _notify();
          default:
            // Okuyucu koptu / açık değil.
            scannerInfo = null;
            scannerFailure = reason;
            _set(FingerprintLoginStatus.unavailable);
            return;
        }
        continue;
      }

      idleTimeouts = 0;
      lastCaptureFailure = null;
      message = null;
      _set(FingerprintLoginStatus.checking);

      String? error;
      final ok = await _login(capture, scannerInfo!, (msg) => error = msg);
      if (_disposed) return;

      if (ok) {
        failedAttempts = 0;
        _set(FingerprintLoginStatus.success);
        return;
      }
      if (error == null) {
        // Başka bir giriş sürüyor ya da tamamlandı — sessizce dinlemeye dön.
        continue;
      }

      message = error;
      if (!FingerprintApi.isAvailable) {
        // Servis henüz yok (501): deneme sayılmaz, okuyucu boşuna dinlenmez.
        _set(FingerprintLoginStatus.idle);
        return;
      }
      failedAttempts++;
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-FP-103',
        message: 'Parmak iziyle giriş başarısız',
        context: {'attempt': failedAttempts, 'quality': capture.quality},
      );
      if (failedAttempts >= maxFailedAttempts) {
        _startCooldown();
        return;
      }
      _notify();
      // Mesaj okunabilsin, aynı dokunuş hemen tekrar gönderilmesin.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }
  }

  /// [SWREQ-FP-104] Sensörde parmak varsa kalkmasını bekler.
  Future<void> _waitForFingerLift() async {
    var announced = false;
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (!_disposed && !_stopRequested && DateTime.now().isBefore(deadline)) {
      final on = await _scanner.isFingerOn();
      if (on.isError || on.data != true) return;
      if (!announced) {
        announced = true;
        _set(FingerprintLoginStatus.waitingLift);
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  /// [SWREQ-FP-105]
  void _startCooldown() {
    MedLogger.warn(
      unit: _unit,
      swreq: 'SWREQ-FP-105',
      message: 'Parmak iziyle giriş geçici olarak durduruldu',
      context: {'attempts': failedAttempts, 'seconds': cooldown.inSeconds},
    );
    cooldownSecondsLeft = cooldown.inSeconds;
    _set(FingerprintLoginStatus.cooldown);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      cooldownSecondsLeft--;
      if (cooldownSecondsLeft > 0) {
        _notify();
        return;
      }
      t.cancel();
      _cooldownTimer = null;
      failedAttempts = 0;
      message = null;
      status = FingerprintLoginStatus.listening;
      unawaited(start());
    });
  }

  /// Okuyucu yeniden aranır ya da boşta kalan dinleme yeniden başlatılır.
  Future<void> retry() async {
    if (_running || status == FingerprintLoginStatus.cooldown) return;
    message = null;
    await start();
  }

  // ─────────────────────────────────────────────────────────────────────

  void _set(FingerprintLoginStatus s) {
    status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cooldownTimer?.cancel();
    if (_running) unawaited(_scanner.cancelCapture());
    super.dispose();
  }
}
