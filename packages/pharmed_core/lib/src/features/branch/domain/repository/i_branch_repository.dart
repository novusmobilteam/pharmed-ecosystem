import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IBranchRepository {
  Future<Result<ApiResponse<List<Branch>>>> getBranches({int? skip, int? take, String? search});

  Future<Result<void>> createBranch(Branch entity);
  Future<Result<void>> updateBranch(Branch entity);
  Future<Result<void>> deleteBranch(Branch entity);
}
