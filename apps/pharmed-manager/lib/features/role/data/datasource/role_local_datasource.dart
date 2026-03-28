import '../../../../core/core.dart';
import '../model/role_dto.dart';
import 'role_datasource.dart';

/// Rol işlemleri için yerel (Mock) veri kaynağı.
class RoleLocalDataSource extends BaseLocalDataSource<RoleDTO, int> implements RoleDataSource {
  RoleLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => RoleDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => RoleDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<RoleDTO>>>> getRoles({
    int? skip,
    int? take,
    String? search,
  }) {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<void>> createRole(RoleDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateRole(RoleDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteRole(int id) => deleteRequest(id);
}
