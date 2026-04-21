// [SWREQ-CABIN-UC-XXX]
// Mobil kabin gözüne yatak ataması yapar.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CreatePatientAssignmentUseCase {
  const CreatePatientAssignmentUseCase(this._repository);

  final IAssignmentRepository _repository;

  Future<Result<void>> call(BedAssignment entity) async {
    MedLogger.info(
      unit: 'SW-UNIT-CABIN',
      swreq: 'SWREQ-CABIN-UC-XXX',
      message: 'Mobil kabin göz ataması başlatıldı',
      context: {'cellId': entity.cellId, 'bedId': entity.bedId},
    );

    return _repository.createBedAssignment(entity);
  }
}
