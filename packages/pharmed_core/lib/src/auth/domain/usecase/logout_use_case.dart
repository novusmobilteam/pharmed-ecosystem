// [SWREQ-CORE-AUTH-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}
