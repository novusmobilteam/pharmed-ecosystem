// [SWREQ-CABIN-UC-XXX]
// Mobil kabin gözündeki yatak atamasını siler.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class DeletePatientAssignmentUseCase {
  const DeletePatientAssignmentUseCase(this._repository);

  final IAssignmentRepository _repository;

  Future<Result<void>> call(PatientAssignment entity) async {
    MedLogger.info(
      unit: 'SW-UNIT-CABIN',
      swreq: 'SWREQ-CABIN-UC-XXX',
      message: 'Mobil kabin göz ataması güncellendi',
      context: {'cellId': entity.cellId, 'bedId': entity.bedId},
    );

    return _repository.deletePatientAssignment(entity.id ?? 0);
  }
}
