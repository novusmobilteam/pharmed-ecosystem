import '../../../../core/core.dart';
import '../../user.dart';

class CreateUserUseCase implements UseCase<void, User> {
  final IUserRepository _repository;
  CreateUserUseCase(this._repository);

  @override
  Future<Result<void>> call(User params) => _repository.createUser(params);
}
