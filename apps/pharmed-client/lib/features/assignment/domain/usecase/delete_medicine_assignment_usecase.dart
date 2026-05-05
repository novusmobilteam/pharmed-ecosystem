// [SWREQ-CORE-ASSIGNMENT-UC-002]
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';

final deleteAssignmentUseCaseProvider = Provider<DeleteMedicineAssignmentUseCase>((ref) {
  return DeleteMedicineAssignmentUseCase(ref.read(cabinAssignmentRepositoryProvider));
});

class DeleteMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  DeleteMedicineAssignmentUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteMedicineAssignment(id);
  }
}
