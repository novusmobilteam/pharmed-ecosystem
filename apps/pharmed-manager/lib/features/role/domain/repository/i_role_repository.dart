import '../../../../core/core.dart';
import '../entity/role.dart';

abstract class IRoleRepository {
  Future<Result<ApiResponse<List<Role>>>> getRoles({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<void>> createRole(Role entity);
  Future<Result<void>> updateRole(Role entity);
  Future<Result<void>> deleteRole(Role entity);
}
