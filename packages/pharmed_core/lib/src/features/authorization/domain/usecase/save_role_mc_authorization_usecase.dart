import 'package:pharmed_core/pharmed_core.dart';

class SaveRoleMcAuthorizationUseCase {
  final IRoleAuthorizationRepository _repository;

  SaveRoleMcAuthorizationUseCase(this._repository);

  Future<Result<void>> call(RoleMedicalConsumableAuthorization params) {
    return _repository.saveMedicalConsumableAuthorization(params);
  }
}
