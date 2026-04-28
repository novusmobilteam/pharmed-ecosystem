import 'package:pharmed_core/pharmed_core.dart';

abstract class IRoleAuthorizationRepository {
  Future<Result<RoleMenuAuthorization>> getMenuAuthorization(Role role);
  Future<Result<void>> saveMenuAuthorization(RoleMenuAuthorization auth);

  Future<Result<List<RoleDrugAuthorization>>> getDrugAuthorizations();
  Future<Result<void>> saveDrugAuthorizations(List<RoleDrugAuthorization> auths);

  Future<Result<RoleMedicalConsumableAuthorization>> getMedicalConsumableAuthorization(Role role);
  Future<Result<void>> saveMedicalConsumableAuthorization(RoleMedicalConsumableAuthorization auth);
}
