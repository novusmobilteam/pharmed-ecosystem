// [SWREQ-CORE-ASSIGNMENT-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetMedicineAssignmentsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetMedicineAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<MedicineAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getMedicineAssignments(cabinId);
  }
}
