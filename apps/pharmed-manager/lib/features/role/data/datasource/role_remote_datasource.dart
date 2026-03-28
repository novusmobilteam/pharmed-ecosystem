import '../../../../core/core.dart';
import '../model/role_dto.dart';
import 'role_datasource.dart';

/// Rol işlemleri için uzak (API) veri kaynağı.
class RoleRemoteDataSource extends BaseRemoteDataSource implements RoleDataSource {
  final String _basePath = '/Role';

  RoleRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<RoleDTO>>>> getRoles({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<RoleDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(RoleDTO.fromJson),
      successLog: 'Roles fetched',
      emptyLog: 'No roles',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createRole(RoleDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Role created',
    );
  }

  @override
  Future<Result<void>> updateRole(RoleDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Role updated',
    );
  }

  @override
  Future<Result<void>> deleteRole(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Role deleted',
    );
  }
}
