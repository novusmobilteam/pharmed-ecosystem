import '../../../../core/core.dart';

import '../repository/i_branch_repository.dart';

class DeleteBranchUseCase extends UseCase<void, int> {
  final IBranchRepository repository;

  DeleteBranchUseCase(this.repository);

  @override
  Future<Result<void>> call(int id) {
    return repository.deleteBranch(id);
  }
}
