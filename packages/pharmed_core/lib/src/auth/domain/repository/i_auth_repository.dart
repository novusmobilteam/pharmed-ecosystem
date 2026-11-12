import 'package:pharmed_core/pharmed_core.dart';

// [SWREQ-CORE-AUTH-001]
// Sınıf: Class B

abstract interface class IAuthRepository {
  /// Login + getCurrentUser zinciri.
  /// Başarılıysa token ve user'ı cache'e yazar, AuthToken döndürür.
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
    String? macAddress,
    int? stationId,
  });

  Future<Result<AuthToken>> loginWithBadge({required String cardData, String? macAddress});

  /// [SWREQ-FP-103] Parmak iziyle giriş. Eşleştirme sunucuda yapılır; başarılıysa
  /// token ve kullanıcı login() ile aynı şekilde önbelleğe yazılır.
  Future<Result<AuthToken>> loginWithFingerprint(FingerprintLoginRequest request);

  /// [SWREQ-CORE-AUTH-005] Saklı refresh token ile oturumu yeniler
  /// (POST /Login/refresh). Başarılıysa yeni access/refresh token
  /// cache'e ve TokenHolder'a yazılır, yeni access token döner.
  /// Refresh token yoksa veya sunucu reddederse error döner — çağıran
  /// (TokenInterceptor) oturumu kapatır.
  Future<Result<String>> refreshSession();

  /// Cache'i temizler.
  Future<Result<void>> logout();

  /// Dio interceptor'ı tarafından çağrılır.
  /// Token yoksa null döner — interceptor Authorization header eklemez.
  Future<String?> getStoredToken();
}
