import '../../../../core/core.dart';

import '../entity/role.dart';
import '../repository/i_role_repository.dart';

class CreateRoleUseCase extends UseCase<void, Role> {
  final IRoleRepository _repository;

  CreateRoleUseCase(this._repository);

  @override
  Future<Result<void>> call(Role params) {
    return _repository.createRole(params);
  }
}
