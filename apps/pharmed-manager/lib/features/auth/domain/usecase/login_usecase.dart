import '../../../../core/core.dart';
import '../../../../core/storage/auth/auth.dart';

import '../entity/token.dart';
import '../repository/i_auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  final String? macAddress;

  LoginParams({required this.email, required this.password, this.macAddress});
}

class LoginUseCase implements UseCase<Token, LoginParams> {
  final IAuthRepository _repository;
  final AuthStorageNotifier _authStorage;

  LoginUseCase(this._repository, this._authStorage);

  @override
  Future<Result<Token>> call(LoginParams params) async {
    final result = await _repository.login(
      email: params.email,
      password: params.password,
      macAddress: params.macAddress,
    );

    return result.when(
      ok: (token) async {
        await _authStorage.saveToken(token.accessToken);
        await _authStorage.saveCredentials(params.email, params.password);
        return Result.ok(token);
      },
      error: (f) {
        return Result.error(f);
      },
    );
  }
}
