import '../../../../core/core.dart';
import '../entity/cabin_assignment.dart';
import '../repository/i_cabin_assignment_repository.dart';

class GetCabinAssignmentsUseCase implements NoParamsUseCase<List<CabinAssignment>> {
  final ICabinAssignmentRepository _assignmentRepository;

  GetCabinAssignmentsUseCase(this._assignmentRepository);

  @override
  Future<Result<List<CabinAssignment>>> call() async {
    return await _assignmentRepository.getCabinAssignments();
  }
}

class GetCabinAssignmentsWithCabinUseCase implements UseCase<List<CabinAssignment>, int> {
  final ICabinAssignmentRepository _assignmentRepository;

  GetCabinAssignmentsWithCabinUseCase(this._assignmentRepository);

  @override
  Future<Result<List<CabinAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getCabinAssignmentsWithCabinId(cabinId);
  }
}
