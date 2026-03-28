import '../../../../core/core.dart';

import '../../user.dart';

class UpdateUserUseCase implements UseCase<void, User> {
  final IUserRepository _repository;
  UpdateUserUseCase(this._repository);

  @override
  Future<Result<void>> call(User params) => _repository.updateUser(params);
}
