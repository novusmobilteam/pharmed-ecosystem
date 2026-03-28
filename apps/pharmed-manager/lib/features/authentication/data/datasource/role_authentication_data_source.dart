import '../../../../core/core.dart';
import '../model/role_drug_authentication_dto.dart';
import '../model/role_mc_authentication_dto.dart';
import '../model/role_menu_authentication_dto.dart';

abstract class RoleAuthenticationDataSource {
  Future<Result<List<RoleMenuAuthenticationDTO>>> getMenuAuthentications();
  Future<Result<RoleMenuAuthenticationDTO?>> getMenuAuthentication(int roleId);

  Future<Result<void>> updateMenuAuthentication(RoleMenuAuthenticationDTO dto);
  Future<Result<void>> createMenuAuthentication(RoleMenuAuthenticationDTO dto);

  Future<Result<List<RoleDrugAuthenticationDTO>>> getDrugAuthentications();
  Future<Result<void>> updateDrugAuthentication(List<Map<String, dynamic>> body);

  Future<Result<RoleMedicalConsumableAuthenticationDTO?>> getMedicalConsumableAuthentication(int roleId);
  Future<Result<void>> createMedicalConsumableAuthentication(RoleMedicalConsumableAuthenticationDTO dto);
  Future<Result<void>> updateMedicalConsumableAuthentication(RoleMedicalConsumableAuthenticationDTO dto);
}
