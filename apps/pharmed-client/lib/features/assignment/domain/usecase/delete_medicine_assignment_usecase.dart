// [SWREQ-CORE-ASSIGNMENT-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  DeleteMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteMedicineAssignment(id);
  }
}
