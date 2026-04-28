import 'package:pharmed_core/pharmed_core.dart';

class GetRoleMcAuthorizationUseCase {
  final IRoleAuthorizationRepository _repository;

  GetRoleMcAuthorizationUseCase(this._repository);

  Future<Result<RoleMedicalConsumableAuthorization>> call(Role params) {
    return _repository.getMedicalConsumableAuthorization(params);
  }
}
