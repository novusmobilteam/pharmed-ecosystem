// pharmed-client/lib/features/fingerprint_enrollment/notifier/fingerprint_enrollment_notifier.dart
//
// [SWREQ-FP-100] [SWREQ-FP-101] [SWREQ-FP-102]
// Parmak izi tanıtma akışı:
//   1. Şifre doğrulama — açık bırakılmış oturumda başkası kendi parmağını tanıtamasın.
//      Oturumu etkilemeyen tanık doğrulama servisi kullanılır (dönen kullanıcı = oturumdaki kullanıcı).
//   2. KVKK aydınlatma + açık rıza.
//   3. Parmaklar: seçilen parmak için 3 okuma (her biri kayıt kalitesinde, aralarda parmak kaldırılır).
//      Zorunlu parmak yoktur; tek bir parmak okunduğunda kaydedilebilir.
//   4. Gönderim: yalnızca bu oturumda okunan parmaklar tek istekte gider.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/core/providers/fingerprint_providers.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';

final fingerprintEnrollmentNotifierProvider = ChangeNotifierProvider.autoDispose<FingerprintEnrollmentNotifier>(
  (ref) => FingerprintEnrollmentNotifier(
    scanner: ref.read(fingerprintScannerProvider),
    currentUser: ref.read(authNotifierProvider.notifier).currentUser,
    verifyCredentials: ref.read(loginWitnessUseCaseProvider),
    getEnrolled: ref.read(getEnrolledFingersUseCaseProvider),
    enroll: ref.read(enrollFingerprintsUseCaseProvider),
    delete: ref.read(deleteEnrolledFingerUseCaseProvider),
  ),
);

enum EnrollmentStep { password, consent, fingers }

/// Okuma sırasında kullanıcıya gösterilecek yönlendirme.
enum EnrollmentPrompt { none, placeFinger, liftFinger }

class FingerprintEnrollmentNotifier extends ChangeNotifier {
  FingerprintEnrollmentNotifier({
    required IFingerprintScanner scanner,
    required AppUser? currentUser,
    required WitnessUserLoginUseCase verifyCredentials,
    required GetEnrolledFingersUseCase getEnrolled,
    required EnrollFingerprintsUseCase enroll,
    required DeleteEnrolledFingerUseCase delete,
  }) : _scanner = scanner,
       _user = currentUser,
       _verifyCredentials = verifyCredentials,
       _getEnrolled = getEnrolled,
       _enroll = enroll,
       _delete = delete;

  static const _unit = 'SW-UNIT-FP';

  /// Tek bir okumanın parmak bekleme süresi.
  static const captureTimeout = Duration(seconds: 20);

  /// Aynı okuma için art arda bu kadar başarısız denemeden sonra durulur.
  static const _maxConsecutiveFailures = 5;

  final IFingerprintScanner _scanner;
  final AppUser? _user;
  final WitnessUserLoginUseCase _verifyCredentials;
  final GetEnrolledFingersUseCase _getEnrolled;
  final EnrollFingerprintsUseCase _enroll;
  final DeleteEnrolledFingerUseCase _delete;
  bool _disposed = false;

  AppUser? get user => _user;

  EnrollmentStep step = EnrollmentStep.password;

  // ── 1. Şifre ──────────────────────────────────────────────────────────
  bool isVerifying = false;
  String? passwordError;

  // ── 2. Rıza ───────────────────────────────────────────────────────────
  bool consentAccepted = false;

  // ── Okuyucu ───────────────────────────────────────────────────────────
  bool isOpeningScanner = false;
  FingerprintScannerInfo? scannerInfo;
  FingerprintFailureReason? scannerFailure;

  // ── Sunucudaki kayıtlar ───────────────────────────────────────────────
  bool isLoadingEnrolled = false;
  String? loadError;
  Map<FingerPosition, EnrolledFinger> enrolled = {};

  // ── Bu oturumda okunanlar (henüz gönderilmedi) ────────────────────────
  final Map<FingerPosition, List<FingerprintSample>> _drafts = {};
  FingerprintTemplateFormat? _format;

  FingerPosition? selected;

  // ── Okuma ─────────────────────────────────────────────────────────────
  bool isCapturing = false;
  bool _cancelRequested = false;
  EnrollmentPrompt prompt = EnrollmentPrompt.none;

  /// Son okuma denemesinin hatası (kalite düşük, parmak düzgün yerleşmedi vb.).
  FingerprintFailureReason? lastFailure;
  int? lastQuality;
  FingerprintImage? lastImage;

  // ── Gönderim / silme ──────────────────────────────────────────────────
  bool isSaving = false;
  bool isDeleting = false;

  // ─────────────────────────────────────────────────────────────────────
  // Okuma görünümü
  // ─────────────────────────────────────────────────────────────────────

  List<FingerprintSample> samplesOf(FingerPosition p) => List.unmodifiable(_drafts[p] ?? const []);

  bool isDraftComplete(FingerPosition p) =>
      (_drafts[p]?.length ?? 0) == FingerprintEnrollmentRules.samplesPerFinger;

  bool isEnrolled(FingerPosition p) => enrolled.containsKey(p);

  /// Gönderilmeye hazır parmaklar.
  List<FingerPosition> get pendingFingers =>
      FingerPosition.values.where(isDraftComplete).toList(growable: false);

  bool get hasUnsavedWork => _drafts.values.any((s) => s.isNotEmpty);

  bool get canSave =>
      !isSaving && !isCapturing && pendingFingers.isNotEmpty && _buildRequest() != null;

  // ─────────────────────────────────────────────────────────────────────
  // 1. Şifre
  // ─────────────────────────────────────────────────────────────────────

  /// [SWREQ-FP-102] Hata mesajı UI'da gösterilir; başarılıysa rıza adımına geçilir.
  Future<void> verifyPassword(String password) async {
    final user = _user;
    if (user == null || isVerifying) return;
    isVerifying = true;
    passwordError = null;
    _notify();

    var ok = false;
    if (FlavorConfig.instance.isMock) {
      ok = password.isNotEmpty; // mock flavor'da doğrulama servisi yok
    } else {
      final mac = await DeviceInfo.getMacAddress();
      final result = await _verifyCredentials(
        WitnessUserLoginParams(email: user.email, password: password, macAddress: mac),
      );
      result.when(
        ok: (verified) {
          ok = verified != null && verified.id == user.id;
          if (!ok) passwordError = contextlessL10n().fingerprint_enroll_passwordWrong;
        },
        error: (e) {
          passwordError = e.userMessage;
        },
      );
    }

    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-FP-102',
      message: ok ? 'Parmak izi tanıtma için şifre doğrulandı' : 'Parmak izi tanıtma için şifre doğrulanamadı',
      context: {'userId': user.id},
    );

    isVerifying = false;
    if (ok) step = EnrollmentStep.consent;
    _notify();
  }

  // ─────────────────────────────────────────────────────────────────────
  // 2. Rıza
  // ─────────────────────────────────────────────────────────────────────

  void setConsent(bool value) {
    consentAccepted = value;
    _notify();
  }

  Future<void> continueAfterConsent() async {
    if (!consentAccepted) return;
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-FP-100',
      message: 'Biyometrik veri açık rızası alındı',
      context: {'userId': _user?.id, 'at': DateTime.now().toUtc().toIso8601String()},
    );
    step = EnrollmentStep.fingers;
    _notify();
    await Future.wait([openScanner(), loadEnrolled()]);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Okuyucu ve kayıtlar
  // ─────────────────────────────────────────────────────────────────────

  Future<void> openScanner() async {
    if (isOpeningScanner) return;
    isOpeningScanner = true;
    scannerFailure = null;
    _notify();
    final result = await _scanner.open();
    result.when(
      ok: (info) {
        scannerInfo = info;
      },
      error: (e) {
        scannerInfo = null;
        scannerFailure = e is FingerprintException ? e.reason : FingerprintFailureReason.unexpected;
      },
    );
    isOpeningScanner = false;
    _notify();
  }

  Future<void> loadEnrolled() async {
    isLoadingEnrolled = true;
    loadError = null;
    _notify();
    final result = await _getEnrolled();
    result.when(
      ok: (list) {
        enrolled = {for (final f in list) f.position: f};
      },
      error: (e) {
        loadError = e.userMessage;
      },
    );
    isLoadingEnrolled = false;
    _notify();
  }

  // ─────────────────────────────────────────────────────────────────────
  // 3. Parmak seçimi ve okuma
  // ─────────────────────────────────────────────────────────────────────

  void select(FingerPosition position) {
    if (isCapturing || isSaving || isDeleting) return;
    selected = position;
    lastFailure = null;
    lastQuality = null;
    lastImage = null;
    _notify();
  }

  /// Seçili parmak için 3 okuma alır. Önceki taslağı siler (yeniden tanıtma).
  Future<void> startCapture() async {
    final position = selected;
    if (position == null || isCapturing || !_scanner.isOpen) return;

    isCapturing = true;
    _cancelRequested = false;
    _drafts[position] = [];
    lastFailure = null;
    lastQuality = null;
    lastImage = null;
    _notify();

    var failures = 0;
    while (!_disposed && !_cancelRequested && !isDraftComplete(position)) {
      prompt = EnrollmentPrompt.placeFinger;
      _notify();

      final result = await _scanner.capture(
        timeout: captureTimeout,
        minQuality: FingerprintEnrollmentRules.minEnrollQuality,
        includeImage: true,
      );
      if (_disposed) return;

      final stop = result.when(
        ok: (capture) {
          failures = 0;
          lastFailure = null;
          lastQuality = capture.quality;
          lastImage = capture.image;
          if (_format != null && _format != capture.format) {
            // Okuyucu oturum ortasında değişti — karışık formatlı kayıt gönderilmez.
            lastFailure = FingerprintFailureReason.unexpected;
            return true;
          }
          _format = capture.format;
          _drafts[position]!.add(FingerprintSample.fromCapture(capture));
          return false;
        },
        error: (e) {
          final reason = e is FingerprintException ? e.reason : FingerprintFailureReason.unexpected;
          lastFailure = reason;
          failures++;
          return switch (reason) {
            // Kullanıcı yeniden deneyebilir.
            FingerprintFailureReason.lowQuality ||
            FingerprintFailureReason.extractionFailed ||
            FingerprintFailureReason.fingerOnSensor ||
            FingerprintFailureReason.fakeFinger => failures >= _maxConsecutiveFailures,
            // İptal, zaman aşımı, okuyucu sorunları: dur.
            _ => true,
          };
        },
      );
      _notify();
      if (stop) break;

      if (!isDraftComplete(position) && !_cancelRequested) await _waitForFingerLift();
    }

    if (!isDraftComplete(position)) {
      _drafts.remove(position); // yarım kalan parmak gönderilmez
      if (_cancelRequested) lastFailure = null;
    }
    prompt = EnrollmentPrompt.none;
    isCapturing = false;
    _cancelRequested = false;
    _notify();
  }

  Future<void> cancelCapture() async {
    if (!isCapturing) return;
    _cancelRequested = true;
    await _scanner.cancelCapture();
  }

  /// Kaydedilmemiş okumaları bırakır (ekrandan onaylı çıkış).
  void discardAllForExit() {
    if (isCapturing) return;
    _drafts.clear();
    _format = null;
    lastImage = null;
    _notify();
  }

  void discardDraft(FingerPosition position) {
    if (isCapturing) return;
    _drafts.remove(position);
    _resetFormatIfEmpty();
    _notify();
  }

  /// Taslak kalmadıysa format kilidi kalkar (okuyucu değişmişse yeni formatla devam edilebilir).
  void _resetFormatIfEmpty() {
    if (_drafts.values.every((s) => s.isEmpty)) _format = null;
  }

  /// Okumalar arasında parmağın kalkmasını bekler (aynı dokunuşun iki örnek sayılmaması için).
  Future<void> _waitForFingerLift() async {
    prompt = EnrollmentPrompt.liftFinger;
    _notify();
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!_disposed && !_cancelRequested && DateTime.now().isBefore(deadline)) {
      final on = await _scanner.isFingerOn();
      if (on.data == false) break;
      if (on.isError) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    // Kısa bir ara: kullanıcı yönlendirmeyi görsün.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  // ─────────────────────────────────────────────────────────────────────
  // 4. Gönderim ve silme
  // ─────────────────────────────────────────────────────────────────────

  FingerprintEnrollmentRequest? _buildRequest() {
    final info = scannerInfo;
    final format = _format;
    final pending = pendingFingers;
    if (info == null || format == null || pending.isEmpty) return null;
    return FingerprintEnrollmentRequest(
      fingers: [for (final p in pending) FingerEnrollment(position: p, samples: List.of(_drafts[p]!))],
      source: FingerprintSource.fromScanner(info, format),
    );
  }

  /// Başarılıysa null, değilse kullanıcıya gösterilecek hata mesajı.
  Future<String?> save() async {
    final request = _buildRequest();
    if (request == null || isSaving) return null;
    isSaving = true;
    _notify();

    final result = await _enroll(request);
    String? error;
    await result.when(
      ok: (_) async {
        for (final f in request.fingers) {
          _drafts.remove(f.position);
        }
        _resetFormatIfEmpty();
        MedLogger.info(
          unit: _unit,
          swreq: 'SWREQ-FP-100',
          message: 'Parmak izleri kaydedildi',
          context: {'userId': _user?.id, 'fingers': request.fingers.map((f) => f.position.isoCode).toList()},
        );
        await loadEnrolled();
      },
      error: (e) async {
        error = e.userMessage;
      },
    );

    isSaving = false;
    _notify();
    return error;
  }

  /// Başarılıysa null, değilse hata mesajı.
  Future<String?> deleteEnrolled(FingerPosition position) async {
    if (isDeleting || isCapturing) return null;
    isDeleting = true;
    _notify();
    final result = await _delete(position);
    String? error;
    await result.when(
      ok: (_) async {
        enrolled = Map.of(enrolled)..remove(position);
      },
      error: (e) async {
        error = e.userMessage;
      },
    );
    isDeleting = false;
    _notify();
    return error;
  }

  // ─────────────────────────────────────────────────────────────────────

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (isCapturing) unawaited(_scanner.cancelCapture());
    // Okumalar yalnızca bellekte; ekran kapanınca bırakılır (KVKK).
    _drafts.clear();
    lastImage = null;
    super.dispose();
  }
}
