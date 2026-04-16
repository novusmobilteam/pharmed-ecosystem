// pharmed-client/lib/features/cabin/domain/usecase/assign_bed_to_mobile_cell_use_case.dart
//
// [SWREQ-CABIN-UC-XXX]
// Mobil kabin gözüne yatak ataması yapar.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CreatePatientAssignmentUseCase {
  const CreatePatientAssignmentUseCase(this._repository);

  final IAssignmentRepository _repository;

  Future<Result<void>> call({required int cellId, required int bedId}) async {
    MedLogger.info(
      unit: 'SW-UNIT-CABIN',
      swreq: 'SWREQ-CABIN-UC-XXX',
      message: 'Mobil kabin göz ataması başlatıldı',
      context: {'cellId': cellId, 'bedId': bedId},
    );

    return _repository.createPatientAssignment(cellId: cellId, bedId: bedId);
  }
}
