import '../../../../core/core.dart';

import '../entity/role.dart';
import '../repository/i_role_repository.dart';

class UpdateRoleUseCase extends UseCase<void, Role> {
  final IRoleRepository _repository;

  UpdateRoleUseCase(this._repository);

  @override
  Future<Result<void>> call(Role params) {
    return _repository.updateRole(params);
  }
}
