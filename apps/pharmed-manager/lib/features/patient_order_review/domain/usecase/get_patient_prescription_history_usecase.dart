import 'package:pharmed_manager/core/core.dart';

class GetPatientPrescriptionHistoryUseCase {
  final IPrescriptionRepository _repository;

  GetPatientPrescriptionHistoryUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int patientId) async {
    return await _repository.getPatientPrescriptionHistory(patientId);
  }
}
