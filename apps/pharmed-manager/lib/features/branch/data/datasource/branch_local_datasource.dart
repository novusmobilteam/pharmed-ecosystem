import '../../../../../core/core.dart';
import '../model/branch_dto.dart';
import 'branch_datasource.dart';

/// Branş işlemleri için yerel (Mock) veri kaynağı.
class BranchLocalDataSource extends BaseLocalDataSource<BranchDTO, int> implements BranchDataSource {
  BranchLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => BranchDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => BranchDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<BranchDTO>>>> getBranches({
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
  Future<Result<BranchDTO?>> createBranch(BranchDTO dto) => createRequest(dto);

  @override
  Future<Result<BranchDTO?>> updateBranch(BranchDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteBranch(int id) => deleteRequest(id);
}
