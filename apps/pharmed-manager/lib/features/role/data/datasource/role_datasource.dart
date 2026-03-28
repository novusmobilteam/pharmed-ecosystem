import '../../../../core/core.dart';
import '../model/role_dto.dart';

/// Rol (Role) işlemleri için veri kaynağı arayüzü.
abstract class RoleDataSource {
  /// Rolleri sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<RoleDTO>>>> getRoles({
    int? skip,
    int? take,
    String? search,
  });
  Future<Result<void>> createRole(RoleDTO dto);
  Future<Result<void>> updateRole(RoleDTO dto);
  Future<Result<void>> deleteRole(int id);
}
