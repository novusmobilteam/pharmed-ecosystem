// [SWREQ-CORE-ASSIGNMENT-UC-003]
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final getMedicineAssignmentsUseCaseProvider = Provider<GetMedicineAssignmentsUseCase>((ref) {
  return GetMedicineAssignmentsUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

class GetMedicineAssignmentsUseCase {
  final IAssignmentRepository _assignmentRepository;

  GetMedicineAssignmentsUseCase(this._assignmentRepository);

  Future<Result<List<MedicineAssignment>>> call(int cabinId) async {
    return await _assignmentRepository.getMedicineAssignments(cabinId);
  }
}
