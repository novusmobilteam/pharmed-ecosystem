import '../../../../core/core.dart';
import '../entity/role_drug_authentication.dart';
import '../entity/role_medical_consumable_authentication.dart';
import '../entity/role_menu_authentication.dart';

abstract class IRoleAuthenticationRepository {
  Future<Result<RoleMenuAuthentication>> getMenuAuthentication(Role role);
  Future<Result<void>> saveMenuAuthentication(RoleMenuAuthentication auth);

  Future<Result<List<RoleDrugAuthentication>>> getDrugAuthentications();
  Future<Result<void>> saveDrugAuthentication(List<RoleDrugAuthentication> auths);

  Future<Result<RoleMedicalConsumableAuthentication>> getMedicalConsumableAuthentication(Role role);
  Future<Result<void>> saveMedicalConsumableAuthentication(RoleMedicalConsumableAuthentication auth);
}
