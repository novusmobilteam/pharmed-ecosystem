import 'package:pharmed_core/pharmed_core.dart';

class SaveRoleMenuAuthorizationUseCase {
  final IRoleAuthorizationRepository _repository;

  SaveRoleMenuAuthorizationUseCase(this._repository);

  Future<Result<void>> call(RoleMenuAuthorization params) {
    return _repository.saveMenuAuthorization(params);
  }
}
