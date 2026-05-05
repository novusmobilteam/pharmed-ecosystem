// [SWREQ-CORE-ASSIGNMENT-UC-006]
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getBedAssignmentsUseCaseProvider = Provider<GetBedAssignmentsUseCase>((ref) {
  return GetBedAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

class GetBedAssignmentsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetBedAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<BedAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getBedAssignments(cabinId);
  }
}
