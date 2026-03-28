import '../../../../core/core.dart';
import '../../user.dart';

class DeleteUserUseCase implements UseCase<void, User> {
  final IUserRepository _repository;
  DeleteUserUseCase(this._repository);

  @override
  Future<Result<void>> call(User params) => _repository.deleteUser(params);
}
