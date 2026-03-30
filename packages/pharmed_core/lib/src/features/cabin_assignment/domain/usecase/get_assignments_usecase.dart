// [SWREQ-CORE-ASSIGNMENT-UC-003]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetAssignmentsUseCase {
  final ICabinAssignmentRepository _assignmentRepository;

  GetAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<CabinAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getAssignments(cabinId);
  }
}
