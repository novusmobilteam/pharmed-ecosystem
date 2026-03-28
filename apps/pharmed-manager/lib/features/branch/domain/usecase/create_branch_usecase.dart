import '../../../../core/core.dart';

import '../entity/branch.dart';
import '../repository/i_branch_repository.dart';

class CreateBranchUseCase extends UseCase<void, Branch> {
  final IBranchRepository repository;

  CreateBranchUseCase(this.repository);

  @override
  Future<Result<void>> call(Branch branch) {
    return repository.createBranch(branch);
  }
}
