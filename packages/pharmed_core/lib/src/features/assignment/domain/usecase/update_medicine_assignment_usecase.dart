// [SWREQ-CORE-ASSIGNMENT-UC-007]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class UpdateMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  UpdateMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(MedicineAssignment assignment) => _repository.updateMedicineAssignment(assignment);
}
