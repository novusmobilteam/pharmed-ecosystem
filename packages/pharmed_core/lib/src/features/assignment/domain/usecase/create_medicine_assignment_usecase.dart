// [SWREQ-CORE-ASSIGNMENT-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  CreateMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(MedicineAssignment assignment) {
    final ass = assignment.copyWith(
      minQuantity: assignment.minQuantityToBackend,
      maxQuantity: assignment.maxQuantityToBackend,
      criticalQuantity: assignment.critQuantityToBackend,
    );

    return _repository.createMedicineAssignment(ass);
  }
}
