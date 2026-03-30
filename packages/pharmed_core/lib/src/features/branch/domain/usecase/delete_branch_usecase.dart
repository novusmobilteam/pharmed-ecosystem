// [SWREQ-CORE-BRANCH-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteBranchUseCase {
  const DeleteBranchUseCase(this._repository);

  final IBranchRepository _repository;

  Future<Result<void>> call(Branch Branch) => _repository.deleteBranch(Branch);
}
