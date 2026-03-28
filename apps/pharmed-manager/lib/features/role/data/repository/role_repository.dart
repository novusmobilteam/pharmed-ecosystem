import '../../../../core/core.dart';
import '../../domain/entity/role.dart';
import '../../domain/repository/i_role_repository.dart';
import '../datasource/role_datasource.dart';

class RoleRepository implements IRoleRepository {
  final RoleDataSource _ds;

  RoleRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Role>>>> getRoles({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await _ds.getRoles(
      skip: skip,
      take: take,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<Role> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Role>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createRole(Role entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createRole(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateRole(Role entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateRole(dto);

    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteRole(Role role) async {
    final id = role.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deleteRole: id is null'));
    }

    final res = await _ds.deleteRole(id);
    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }
}
