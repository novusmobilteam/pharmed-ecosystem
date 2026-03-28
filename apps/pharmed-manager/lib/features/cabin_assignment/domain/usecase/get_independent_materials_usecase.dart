import '../../../../core/core.dart';

import '../entity/cabin_assignment.dart';

import '../repository/i_cabin_assignment_repository.dart';

class GetIndependentMaterialsUseCase implements NoParamsUseCase<List<CabinAssignment>> {
  final ICabinAssignmentRepository _assignmentRepository;

  GetIndependentMaterialsUseCase(this._assignmentRepository);

  @override
  Future<Result<List<CabinAssignment>>> call() async {
    return await _assignmentRepository.getIndependentMaterials();
  }
}
