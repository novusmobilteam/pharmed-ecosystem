import '../../../../core/core.dart';

import '../../../../core/storage/auth/auth.dart';
import '../../user.dart';

class GetCurrentUserUseCase implements NoParamsUseCase<User?> {
  final IUserRepository _repository;
  final AuthStorageNotifier _authStorage;

  GetCurrentUserUseCase(this._repository, this._authStorage);

  @override
  Future<Result<User?>> call() async {
    final result = await _repository.getCurrentUser();

    return result.when(
      ok: (user) async {
        if (user != null) {
          await _authStorage.saveUser(user);
        }
        return Result.ok(user);
      },
      error: (f) => Result.error(f),
    );
  }
}
