// [SWREQ-CORE-ASSIGNMENT-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetIndependentMaterialsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetIndependentMaterialsUseCase(this._assignmentRepository);

  Future<Result<List<MedicineAssignment>>> call({required int serviceId}) async {
    return await _assignmentRepository.getIndependentMaterials(serviceId: serviceId);
  }
}
