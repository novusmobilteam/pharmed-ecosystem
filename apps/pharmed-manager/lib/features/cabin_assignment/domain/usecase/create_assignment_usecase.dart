import '../../../../core/core.dart';

import '../entity/cabin_assignment.dart';
import '../repository/i_cabin_assignment_repository.dart';

class CreateAssignmentUseCase implements UseCase<void, CabinAssignment> {
  final ICabinAssignmentRepository _repository;

  CreateAssignmentUseCase(this._repository);

  @override
  Future<Result<void>> call(CabinAssignment assignment) {
    final ass = assignment.copyWith(
      minQuantity: assignment.minQuantityToBackend,
      maxQuantity: assignment.maxQuantityToBackend,
      criticalQuantity: assignment.critQuantityToBackend,
    );

    return _repository.createAssignment(ass);
  }
}
