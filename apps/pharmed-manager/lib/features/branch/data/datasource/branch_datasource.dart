import '../../../../core/core.dart';
import '../model/branch_dto.dart';

abstract class BranchDataSource {
  Future<Result<ApiResponse<List<BranchDTO>>>> getBranches({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni bir branş oluşturur.
  Future<Result<BranchDTO?>> createBranch(BranchDTO dto);

  /// Mevcut branş bilgilerini günceller.
  Future<Result<BranchDTO?>> updateBranch(BranchDTO dto);

  /// ID'si verilen branşı siler.
  Future<Result<void>> deleteBranch(int id);
}
