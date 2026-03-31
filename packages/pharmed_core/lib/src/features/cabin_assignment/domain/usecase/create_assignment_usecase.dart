// [SWREQ-CORE-ASSIGNMENT-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateAssignmentUseCase {
  final ICabinAssignmentRepository _repository;

  CreateAssignmentUseCase(this._repository);

  Future<Result<void>> call(CabinAssignment assignment) {
    final ass = assignment.copyWith(
      minQuantity: assignment.minQuantityToBackend,
      maxQuantity: assignment.maxQuantityToBackend,
      criticalQuantity: assignment.critQuantityToBackend,
    );

    return _repository.createAssignment(ass);
  }
}
