import '../../../../core/core.dart';

import '../../../role/domain/entity/role.dart';
import '../entity/role_menu_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class GetRoleMenuAuthenticationUseCase extends UseCase<RoleMenuAuthentication, Role> {
  final IRoleAuthenticationRepository _repository;

  GetRoleMenuAuthenticationUseCase(this._repository);

  @override
  Future<Result<RoleMenuAuthentication>> call(Role params) {
    return _repository.getMenuAuthentication(params);
  }
}
