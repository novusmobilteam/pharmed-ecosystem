// packages/pharmed_data/lib/src/role/repository/role_repository_impl.dart
//
// [SWREQ-DATA-ROLE-002]
// IRoleRepository implementasyonu.
// DTO → entity dönüşümü RoleMapper üzerinden yapılır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleRepositoryImpl implements IRoleRepository {
  const RoleRepositoryImpl({required RoleRemoteDataSource dataSource, required RoleMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final RoleRemoteDataSource _dataSource;
  final RoleMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Role>>>> getRoles({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getRoles(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Role>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createRole(Role entity) async {
    final result = await _dataSource.createRole(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateRole(Role entity) async {
    final result = await _dataSource.updateRole(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteRole(Role entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek rolün id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteRole(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
