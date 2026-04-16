// [SWREQ-CORE-ASSIGNMENT-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetPatientAssignmentsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetPatientAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<PatientAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getPatientAssignments(cabinId);
  }
}
