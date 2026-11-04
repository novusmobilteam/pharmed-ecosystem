// [SWREQ-FP-100]
// Oturum açmış kullanıcının parmak izi kayıtları.
// Kullanıcı kimliği her çağrıda oturum token'ından alınır (gövdede gönderilmez).
//
// Parmak iziyle giriş bu arayüzde değil: token ve kullanıcı önbelleği
// IAuthRepository.loginWithFingerprint içinde yönetilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IFingerprintRepository {
  /// Parmakları kaydeder. Aynı pozisyon zaten kayıtlıysa değiştirilir.
  /// Sunucu: aynı parmak BAŞKA bir kullanıcıda kayıtlıysa reddeder (409).
  Future<Result<void>> enroll(FingerprintEnrollmentRequest request);

  /// Kullanıcının kayıtlı parmakları.
  Future<Result<List<EnrolledFinger>>> getEnrolledFingers();

  /// Bir parmağın kaydını siler.
  Future<Result<void>> deleteFinger(FingerPosition position);

  /// [SWREQ-FP-106] Kullanıcı KVKK açık rıza metnini daha önce onaylamış mı?
  /// GET /Fingerprint/consent/{userId}
  Future<Result<bool>> hasConsent(int userId);

  /// [SWREQ-FP-106] KVKK açık rızasını kaydeder.
  /// POST /Fingerprint/consent  { userId, consentAt }
  Future<Result<void>> saveConsent({required int userId, required DateTime consentAt});
}
