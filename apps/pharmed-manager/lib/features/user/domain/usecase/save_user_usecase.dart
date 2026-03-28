import '../../../../core/core.dart';

import '../../user.dart';

class SaveUserUseCase implements UseCase<void, User> {
  final IUserRepository _repository;
  SaveUserUseCase(this._repository);

  @override
  Future<Result<void>> call(User params) async {
    if (params.id == null) {
      return await _repository.createUser(params);
    } else {
      return await _repository.updateUser(params);
    }
  }
}
