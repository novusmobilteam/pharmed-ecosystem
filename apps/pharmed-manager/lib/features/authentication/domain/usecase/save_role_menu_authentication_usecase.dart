import '../../../../core/core.dart';

import '../entity/role_menu_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class SaveRoleMenuAuthenticationUseCase extends UseCase<void, RoleMenuAuthentication> {
  final IRoleAuthenticationRepository _repository;

  SaveRoleMenuAuthenticationUseCase(this._repository);

  @override
  Future<Result<void>> call(RoleMenuAuthentication params) {
    return _repository.saveMenuAuthentication(params);
  }
}
