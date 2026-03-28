import '../../../../core/core.dart';

import '../entity/branch.dart';
import '../repository/i_branch_repository.dart';

class UpdateBranchUseCase extends UseCase<void, Branch> {
  final IBranchRepository repository;

  UpdateBranchUseCase(this.repository);

  @override
  Future<Result<void>> call(Branch branch) {
    return repository.updateBranch(branch);
  }
}
