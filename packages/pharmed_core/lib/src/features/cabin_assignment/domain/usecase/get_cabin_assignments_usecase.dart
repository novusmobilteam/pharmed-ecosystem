// [SWREQ-CORE-ASSIGNMENT-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetCabinAssignmentsUseCase {
  final ICabinAssignmentRepository _assignmentRepository;

  GetCabinAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<CabinAssignment>>> call() async {
    return await _assignmentRepository.getCabinAssignments();
  }
}

// [SWREQ-CORE-ASSIGNMENT-UC-005]
// Sınıf: Class B

class GetCabinAssignmentsWithCabinUseCase {
  final ICabinAssignmentRepository _assignmentRepository;

  GetCabinAssignmentsWithCabinUseCase(this._assignmentRepository);

  Future<Result<List<CabinAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getCabinAssignmentsWithCabinId(cabinId);
  }
}
