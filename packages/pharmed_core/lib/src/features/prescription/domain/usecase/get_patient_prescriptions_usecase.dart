import 'package:pharmed_core/pharmed_core.dart';

class GetPatientPrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetPatientPrescriptionsUseCase(this._repository);

  Future<Result<List<Prescription>>> call(int hospitalizationId) {
    return _repository.getPatientPrescriptions(hospitalizationId);
  }
}
