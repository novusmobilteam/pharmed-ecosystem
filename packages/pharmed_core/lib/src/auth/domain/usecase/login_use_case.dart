// [SWREQ-CORE-AUTH-002]
// Token/user kaydetme sorumluluğu repository'dedir.
// UseCase yalnızca orchestrate eder.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password, this.macAddress});

  final String email;
  final String password;
  final String? macAddress;
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthToken>> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password, macAddress: params.macAddress);
}
