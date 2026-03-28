import '../../../../core/core.dart';
import '../entity/branch.dart';

abstract class IBranchRepository {
  Future<Result<ApiResponse<List<Branch>>>> getBranches({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<void>> createBranch(Branch entity);
  Future<Result<void>> updateBranch(Branch entity);
  Future<Result<void>> deleteBranch(int id);
}
