import '../../../../core/core.dart';
import '../model/role_drug_authentication_dto.dart';
import '../model/role_mc_authentication_dto.dart';
import '../model/role_menu_authentication_dto.dart';
import 'role_authentication_data_source.dart';

class _MenuStore extends BaseLocalDataSource<RoleMenuAuthenticationDTO, int> {
  _MenuStore({required super.filePath})
      : super(
          fromJson: (m) => RoleMenuAuthenticationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => RoleMenuAuthenticationDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

class _DrugStore extends BaseLocalDataSource<RoleDrugAuthenticationDTO, int> {
  _DrugStore({required super.filePath})
      : super(
          fromJson: (m) => RoleDrugAuthenticationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => RoleDrugAuthenticationDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

class _MedicalConsumableStore extends BaseLocalDataSource<RoleMedicalConsumableAuthenticationDTO, int> {
  _MedicalConsumableStore({required super.filePath})
      : super(
          fromJson: (m) => RoleMedicalConsumableAuthenticationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => RoleMedicalConsumableAuthenticationDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

class RoleAuthenticationLocalDataSource implements RoleAuthenticationDataSource {
  final _MenuStore _menuStore;
  final _DrugStore _drugStore;
  final _MedicalConsumableStore _medicalConsumableStore;

  RoleAuthenticationLocalDataSource({
    required String menuPath,
    required String drugPath,
    required String medicalConsumablePath,
  })  : _menuStore = _MenuStore(filePath: menuPath),
        _drugStore = _DrugStore(filePath: drugPath),
        _medicalConsumableStore = _MedicalConsumableStore(filePath: medicalConsumablePath);

  @override
  Future<Result<List<RoleDrugAuthenticationDTO>>> getDrugAuthentications() async {
    final res = await _drugStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<RoleMenuAuthenticationDTO>>> getMenuAuthentications() async {
    final res = await _menuStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<RoleMenuAuthenticationDTO?>> getMenuAuthentication(int roleId) async {
    final res = await _menuStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data?.first),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<RoleDrugAuthenticationDTO?>> updateDrugAuthentication(List<Map<String, dynamic>> body) =>
      _drugStore.updateRequest(RoleDrugAuthenticationDTO());

  @override
  Future<Result<RoleMedicalConsumableAuthenticationDTO?>> updateMedicalConsumableAuthentication(
          RoleMedicalConsumableAuthenticationDTO dto) =>
      _medicalConsumableStore.updateRequest(dto);

  @override
  Future<Result<RoleMenuAuthenticationDTO?>> updateMenuAuthentication(RoleMenuAuthenticationDTO dto) =>
      _menuStore.updateRequest(dto);

  @override
  Future<Result<RoleMenuAuthenticationDTO?>> createMenuAuthentication(RoleMenuAuthenticationDTO dto) =>
      _menuStore.createRequest(dto);

  @override
  Future<Result<RoleMedicalConsumableAuthenticationDTO?>> getMedicalConsumableAuthentication(int roleId) async {
    final res = await _medicalConsumableStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data?.first),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<RoleMedicalConsumableAuthenticationDTO?>> createMedicalConsumableAuthentication(
          RoleMedicalConsumableAuthenticationDTO dto) =>
      _medicalConsumableStore.createRequest(dto);
}
