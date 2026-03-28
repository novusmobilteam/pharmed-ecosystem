import '../../../../core/core.dart';

import '../entity/cabin_assignment.dart';

import '../repository/i_cabin_assignment_repository.dart';

class GetAssignmentsUseCase implements UseCase<List<CabinAssignment>, int> {
  final ICabinAssignmentRepository _assignmentRepository;

  GetAssignmentsUseCase(this._assignmentRepository);

  @override
  Future<Result<List<CabinAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getAssignments(cabinId);
  }
}
