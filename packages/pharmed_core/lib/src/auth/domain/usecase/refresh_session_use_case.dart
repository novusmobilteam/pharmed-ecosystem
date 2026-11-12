// [SWREQ-CORE-AUTH-005]
// Access token süresi dolduğunda refresh token ile oturumu yeniler.
// TokenHolder'ın refresh handler'ı olarak bağlanır; UI'dan çağrılmaz.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repository);

  final IAuthRepository _repository;

  /// Yeni access token'ı döndürür.
  Future<Result<String>> call() => _repository.refreshSession();
}
