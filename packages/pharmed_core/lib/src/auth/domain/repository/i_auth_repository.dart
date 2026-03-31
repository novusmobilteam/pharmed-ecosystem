import 'package:pharmed_core/pharmed_core.dart';

// [SWREQ-CORE-AUTH-001]
// Sınıf: Class B

abstract interface class IAuthRepository {
  /// Login + getCurrentUser zinciri.
  /// Başarılıysa token ve user'ı cache'e yazar, AuthToken döndürür.
  Future<Result<AuthToken>> login({required String email, required String password, String? macAddress});

  /// Cache'i temizler.
  Future<Result<void>> logout();

  /// Dio interceptor'ı tarafından çağrılır.
  /// Token yoksa null döner — interceptor Authorization header eklemez.
  Future<String?> getStoredToken();
}
