// [SWREQ-CORE-BRANCH-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateBranchUseCase {
  const UpdateBranchUseCase(this._repository);

  final IBranchRepository _repository;

  Future<Result<void>> call(Branch Branch) => _repository.updateBranch(Branch);
}
