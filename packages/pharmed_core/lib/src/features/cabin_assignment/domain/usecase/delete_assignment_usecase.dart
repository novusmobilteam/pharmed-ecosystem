// [SWREQ-CORE-ASSIGNMENT-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteAssignmentUseCase {
  final ICabinAssignmentRepository _repository;

  DeleteAssignmentUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteAssignment(id);
  }
}
