// [SWREQ-CORE-ASSIGNMENT-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  CreateMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(MedicineAssignment assignment) => _repository.createMedicineAssignment(assignment);
}
