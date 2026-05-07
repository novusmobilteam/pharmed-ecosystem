// [SWREQ-CORE-ASSIGNMENT-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetBedAssignmentsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetBedAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<BedAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getBedAssignments(cabinId);
  }
}
