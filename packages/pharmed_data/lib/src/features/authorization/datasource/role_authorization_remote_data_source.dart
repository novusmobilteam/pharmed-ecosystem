// [SWREQ-DATA-ROLEAUTHORIZATION-001]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleAuthorizationRemoteDataSource extends BaseRemoteDataSource {
  RoleAuthorizationRemoteDataSource({required super.apiManager});

  final String _menuPath = '/RoleMenuAuthentication';
  final String _drugPath = '/RoleDrugAuthentication';
  final String _mcPath = '/RoleMedicalConsumablesAuthentication';

  @override
  String get logSwreq => 'SWREQ-DATA-ROLEAUTHORIZATION-001';

  @override
  String get logUnit => 'SW-UNIT-ROLEAUTHORIZATION';

  Future<Result<List<RoleMenuAuthorizationDto>>> getMenuAuthorizations() async {
    final res = await fetchRequest<List<RoleMenuAuthorizationDto>>(
      path: _menuPath,
      parser: BaseRemoteDataSource.listParser(RoleMenuAuthorizationDto.fromJson),
      successLog: 'Role menu authentications fetched',
      emptyLog: 'No role menu authentication',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RoleMenuAuthorizationDto>[]), error: Result.error);
  }

  Future<Result<RoleMenuAuthorizationDto?>> getMenuAuthorization(int roleId) async {
    final res = await fetchRequest<RoleMenuAuthorizationDto>(
      path: '$_menuPath/$roleId',
      parser: BaseRemoteDataSource.singleParser(RoleMenuAuthorizationDto.fromJson),
      successLog: 'Role menu authentication fetched',
      emptyLog: 'No role menu authentication',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  Future<Result<void>> updateMenuAuthorization(RoleMenuAuthorizationDto dto) {
    return updateRequest(
      path: '$_menuPath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role menu auth updated',
    );
  }

  Future<Result<void>> createMenuAuthorization(RoleMenuAuthorizationDto dto) {
    return createRequest(
      path: _menuPath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role menu auth created',
    );
  }

  Future<Result<List<RoleDrugAuthorizationDto>>> getDrugAuthorizations() async {
    final res = await fetchRequest<List<RoleDrugAuthorizationDto>>(
      path: _drugPath,
      parser: BaseRemoteDataSource.listParser(RoleDrugAuthorizationDto.fromJson),
      successLog: 'Role drug authentications fetched',
      emptyLog: 'No role drug authentication',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <RoleDrugAuthorizationDto>[]), error: Result.error);
  }

  Future<Result<void>> updateDrugAuthorizations(List<Map<String, dynamic>> body) {
    return createRequest<void>(
      path: '$_drugPath/bulk',
      body: body,
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'RoleDrugAuth upsert',
    );
  }

  Future<Result<RoleMedicalConsumableAuthorizationDto?>> getMedicalConsumableAuthorization(int roleId) {
    return fetchRequest<RoleMedicalConsumableAuthorizationDto>(
      path: '$_mcPath/role/$roleId',
      parser: BaseRemoteDataSource.singleParser(RoleMedicalConsumableAuthorizationDto.fromJson),
      successLog: 'Role mc authentications fetched',
      emptyLog: 'No role mc authentication',
    );
  }

  Future<Result<void>> updateMedicalConsumableAuthorization(RoleMedicalConsumableAuthorizationDto dto) {
    return updateRequest(
      path: '$_mcPath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role mc auth updated',
    );
  }

  Future<Result<void>> createMedicalConsumableAuthorization(RoleMedicalConsumableAuthorizationDto dto) {
    return createRequest(
      path: _mcPath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Role mc auth updated',
    );
  }
}
