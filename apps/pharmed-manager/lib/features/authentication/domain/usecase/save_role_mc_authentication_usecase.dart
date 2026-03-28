import '../../../../core/core.dart';

import '../entity/role_medical_consumable_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class SaveRoleMcAuthenticationUseCase extends UseCase<void, RoleMedicalConsumableAuthentication> {
  final IRoleAuthenticationRepository _repository;

  SaveRoleMcAuthenticationUseCase(this._repository);

  @override
  Future<Result<void>> call(RoleMedicalConsumableAuthentication params) {
    return _repository.saveMedicalConsumableAuthentication(params);
  }
}
