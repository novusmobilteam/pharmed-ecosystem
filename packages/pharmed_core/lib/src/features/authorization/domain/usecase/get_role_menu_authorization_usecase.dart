import 'package:pharmed_core/pharmed_core.dart';

class GetRoleMenuAuthorizationUseCase {
  final IRoleAuthorizationRepository _repository;

  GetRoleMenuAuthorizationUseCase(this._repository);

  Future<Result<RoleMenuAuthorization>> call(Role params) {
    return _repository.getMenuAuthorization(params);
  }
}
