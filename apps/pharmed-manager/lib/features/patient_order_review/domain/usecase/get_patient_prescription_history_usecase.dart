import '../../../../core/core.dart';

import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../prescription/domain/repository/i_prescription_repository.dart';

class GetPatientPrescriptionHistoryUseCase implements UseCase<List<PrescriptionItem>, int> {
  final IPrescriptionRepository _repository;

  GetPatientPrescriptionHistoryUseCase(this._repository);

  @override
  Future<Result<List<PrescriptionItem>>> call(int patientId) async {
    return await _repository.getPatientPrescriptionHistory(patientId);
  }
}
