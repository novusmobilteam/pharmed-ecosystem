// [SWREQ-CORE-BRANCH-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateBranchUseCase {
  const CreateBranchUseCase(this._repository);

  final IBranchRepository _repository;

  Future<Result<void>> call(Branch branch) => _repository.createBranch(branch);
}
