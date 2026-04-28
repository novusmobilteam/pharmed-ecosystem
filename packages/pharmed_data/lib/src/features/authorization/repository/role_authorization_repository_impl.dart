import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleAuthorizationRepositoryImpl implements IRoleAuthorizationRepository {
  final RoleAuthorizationRemoteDataSource _dataSource;
  final RoleMenuAuthorizationMapper _menuMapper;
  final RoleDrugAuthorizationMapper _drugMapper;
  final RoleMedicalConsumableAuthorizationMapper _consumableMapper;

  RoleAuthorizationRepositoryImpl({
    required RoleAuthorizationRemoteDataSource dataSource,
    required RoleMenuAuthorizationMapper menuMapper,
    required RoleDrugAuthorizationMapper drugMapper,
    required RoleMedicalConsumableAuthorizationMapper consumableMapper,
  }) : _dataSource = dataSource,
       _menuMapper = menuMapper,
       _drugMapper = drugMapper,
       _consumableMapper = consumableMapper;

  @override
  Future<Result<RoleMenuAuthorization>> getMenuAuthorization(Role role) async {
    final res = await _dataSource.getMenuAuthorization(role.id ?? 0);

    return res.when(
      ok: (dto) => Result.ok(dto != null ? _menuMapper.toEntity(dto, role: role) : RoleMenuAuthorization(role: role)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> saveMenuAuthorization(RoleMenuAuthorization auth) async {
    final dto = _menuMapper.toDto(auth);

    if (auth.id != null) {
      return _dataSource.updateMenuAuthorization(dto);
    } else {
      return _dataSource.createMenuAuthorization(dto);
    }
  }

  @override
  Future<Result<List<RoleDrugAuthorization>>> getDrugAuthorizations() async {
    final res = await _dataSource.getDrugAuthorizations();

    return res.when(
      ok: (dtos) => Result.ok(dtos.map((dto) => _drugMapper.toEntity(dto)).toList()),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> saveDrugAuthorizations(List<RoleDrugAuthorization> auths) async {
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

    final res = await _dataSource.updateDrugAuthorizations(payload);

    return res.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<RoleMedicalConsumableAuthorization>> getMedicalConsumableAuthorization(Role role) async {
    final res = await _dataSource.getMedicalConsumableAuthorization(role.id ?? 0);

    return res.when(
      ok: (dto) => Result.ok(
        dto != null ? _consumableMapper.toEntity(dto) : RoleMedicalConsumableAuthorization(roleId: role.id),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> saveMedicalConsumableAuthorization(RoleMedicalConsumableAuthorization auth) async {
    final dto = _consumableMapper.toDto(auth);

    if (auth.id != null) {
      return _dataSource.updateMedicalConsumableAuthorization(dto);
    } else {
      return _dataSource.createMedicalConsumableAuthorization(dto);
    }
  }
}
