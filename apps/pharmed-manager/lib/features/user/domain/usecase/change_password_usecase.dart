import '../../../../core/core.dart';

import '../../user.dart';

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({required this.currentPassword, required this.newPassword});
}

class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final IUserRepository _repository;

  ChangePasswordUseCase(this._repository);

  @override
  Future<Result<void>> call(ChangePasswordParams params) {
    return _repository.changePassword(currentPassword: params.currentPassword, newPassword: params.newPassword);
  }
}
