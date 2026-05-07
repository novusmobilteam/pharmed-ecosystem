import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IRoleRepository {
  Future<Result<ApiResponse<List<Role>>>> getRoles({int? skip, int? take, String? search});

  Future<Result<void>> createRole(Role entity);
  Future<Result<void>> updateRole(Role entity);
  Future<Result<void>> deleteRole(Role entity);
}
