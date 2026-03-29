import '../../../../core/core.dart';

import '../entity/role_medical_consumable_authentication.dart';
import '../repository/i_role_authentication_repository.dart';

class GetRoleMcAuthenticationUseCase extends UseCase<RoleMedicalConsumableAuthentication, Role> {
  final IRoleAuthenticationRepository _repository;

  GetRoleMcAuthenticationUseCase(this._repository);

  @override
  Future<Result<RoleMedicalConsumableAuthentication>> call(Role params) {
    return _repository.getMedicalConsumableAuthentication(params);
  }
}
