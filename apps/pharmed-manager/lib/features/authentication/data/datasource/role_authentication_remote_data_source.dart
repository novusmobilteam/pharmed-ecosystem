import '../../../../core/core.dart';
import '../model/role_drug_authentication_dto.dart';
import '../model/role_mc_authentication_dto.dart';
import '../model/role_menu_authentication_dto.dart';
import 'role_authentication_data_source.dart';

class RoleAuthenticationRemoteDataSource extends BaseRemoteDataSource implements RoleAuthenticationDataSource {
  final String _menuPath = '/RoleMenuAuthentication';
  final String _drugPath = '/RoleDrugAuthentication';
  final String _mcPath = '/RoleMedicalConsumablesAuthentication';

  RoleAuthenticationRemoteDataSource({required super.apiManager});

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<RoleMenuAuthenticationDTO>>> getMenuAuthentications() async {
    final res = await fetchRequest<List<RoleMenuAuthenticationDTO>>(
      path: _menuPath,
      parser: BaseRemoteDataSource.listParser(RoleMenuAuthenticationDTO.fromJson),
      successLog: 'Role menu authentications fetched',
      emptyLog: 'No role menu authentication',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RoleMenuAuthenticationDTO>[]), error: Result.error);
  }

  @override
  Future<Result<RoleMenuAuthenticationDTO?>> getMenuAuthentication(int roleId) async {
    final res = await fetchRequest<RoleMenuAuthenticationDTO>(
      path: '$_menuPath/$roleId',
      parser: BaseRemoteDataSource.singleParser(RoleMenuAuthenticationDTO.fromJson),
      successLog: 'Role menu authentication fetched',
      emptyLog: 'No role menu authentication',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  @override
  Future<Result<void>> updateMenuAuthentication(RoleMenuAuthenticationDTO dto) {
    return updateRequest(
      path: '$_menuPath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role menu auth updated',
    );
  }

  @override
  Future<Result<void>> createMenuAuthentication(RoleMenuAuthenticationDTO dto) {
    return createRequest(
      path: _menuPath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role menu auth created',
    );
  }

  @override
  Future<Result<List<RoleDrugAuthenticationDTO>>> getDrugAuthentications() async {
    final res = await fetchRequest<List<RoleDrugAuthenticationDTO>>(
      path: _drugPath,
      parser: BaseRemoteDataSource.listParser(RoleDrugAuthenticationDTO.fromJson),
      successLog: 'Role drug authentications fetched',
      emptyLog: 'No role drug authentication',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RoleDrugAuthenticationDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> updateDrugAuthentication(List<Map<String, dynamic>> body) {
    return createRequest<void>(
      path: '$_drugPath/bulk',
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'RoleDrugAuth upsert',
    );
  }

  @override
  Future<Result<RoleMedicalConsumableAuthenticationDTO?>> getMedicalConsumableAuthentication(int roleId) {
    return fetchRequest<RoleMedicalConsumableAuthenticationDTO>(
      path: '$_mcPath/role/$roleId',
      parser: BaseRemoteDataSource.singleParser(RoleMedicalConsumableAuthenticationDTO.fromJson),
      successLog: 'Role mc authentications fetched',
      emptyLog: 'No role mc authentication',
    );
  }

  @override
  Future<Result<void>> updateMedicalConsumableAuthentication(RoleMedicalConsumableAuthenticationDTO dto) {
    return updateRequest(
      path: '$_mcPath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role mc auth updated',
    );
  }

  @override
  Future<Result<void>> createMedicalConsumableAuthentication(RoleMedicalConsumableAuthenticationDTO dto) {
    return createRequest(
      path: _mcPath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role mc auth updated',
    );
  }
}
