import '../../../../core/core.dart';

import '../repository/i_cabin_assignment_repository.dart';

class DeleteAssignmentUseCase implements UseCase<void, int> {
  final ICabinAssignmentRepository _repository;

  DeleteAssignmentUseCase(this._repository);

  @override
  Future<Result<void>> call(int id) {
    return _repository.deleteAssignment(id);
  }
}
