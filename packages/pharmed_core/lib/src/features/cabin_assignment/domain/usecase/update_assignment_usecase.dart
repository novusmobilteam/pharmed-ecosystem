// [SWREQ-CORE-ASSIGNMENT-UC-007]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateAssignmentUseCase {
  final ICabinAssignmentRepository _repository;

  UpdateAssignmentUseCase(this._repository);

  Future<Result<void>> call(CabinAssignment assignment) {
    final ass = assignment.copyWith(
      minQuantity: assignment.minQuantityToBackend,
      maxQuantity: assignment.maxQuantityToBackend,
      criticalQuantity: assignment.critQuantityToBackend,
    );

    return _repository.updateAssignment(ass);
  }
}
