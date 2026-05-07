// [SWREQ-CORE-ASSIGNMENT-UC-007]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  UpdateMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(MedicineAssignment assignment) {
    final ass = assignment.copyWith(
      minQuantity: assignment.minQuantityToBackend,
      maxQuantity: assignment.maxQuantityToBackend,
      criticalQuantity: assignment.critQuantityToBackend,
    );

    return _repository.updateMedicineAssignment(ass);
  }
}
