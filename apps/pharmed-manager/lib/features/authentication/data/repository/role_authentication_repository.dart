import '../../../../core/core.dart';
import '../../../role/domain/entity/role.dart';
import '../../domain/entity/role_drug_authentication.dart';
import '../../domain/entity/role_medical_consumable_authentication.dart';
import '../../domain/entity/role_menu_authentication.dart';
import '../../domain/repository/i_role_authentication_repository.dart';
import '../datasource/role_authentication_data_source.dart';

class RoleAuthenticationRepository implements IRoleAuthenticationRepository {
  final RoleAuthenticationDataSource _ds;

  RoleAuthenticationRepository(this._ds);

  @override
  Future<Result<RoleMenuAuthentication>> getMenuAuthentication(Role role) async {
    final res = await _ds.getMenuAuthentication(role.id ?? 0);

    return res.when(
      ok: (data) => Result.ok(data?.toEntity() ?? RoleMenuAuthentication()),
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<void>> saveMenuAuthentication(RoleMenuAuthentication auth) async {
    final dto = auth.toDTO();

    if (auth.id != null) {
      return _ds.updateMenuAuthentication(dto);
    } else {
      return _ds.createMenuAuthentication(dto);
    }
  }

  @override
  Future<Result<List<RoleDrugAuthentication>>> getDrugAuthentications() async {
    final res = await _ds.getDrugAuthentications();
    return res.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> saveDrugAuthentication(List<RoleDrugAuthentication> auths) async {
    final payload = auths.where((e) => (e.role?.id ?? 0) > 0 && (e.medicine?.id ?? 0) > 0).map((e) {
      final set = e.pendingOps;
      return {
        "roleId": e.role!.id,
        "isDrugPull": set.contains(DrugOp.pull),
        "isFill": set.contains(DrugOp.fill),
        "isReturn": set.contains(DrugOp.returnOp),
        "isDestruction": set.contains(DrugOp.dispose),
        "materialId": e.medicine!.id,
      };
    }).toList();

    final res = await _ds.updateDrugAuthentication(payload);

    return res.when(
      ok: (_) => const Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<RoleMedicalConsumableAuthentication>> getMedicalConsumableAuthentication(Role role) async {
    final res = await _ds.getMedicalConsumableAuthentication(role.id ?? 0);

    return res.when(
      ok: (data) => Result.ok(data?.toEntity() ?? RoleMedicalConsumableAuthentication()),
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<void>> saveMedicalConsumableAuthentication(RoleMedicalConsumableAuthentication auth) async {
    final dto = auth.toDTO();

    if (auth.id != null) {
      return _ds.updateMedicalConsumableAuthentication(dto);
    } else {
      return _ds.createMedicalConsumableAuthentication(dto);
    }
  }
}
