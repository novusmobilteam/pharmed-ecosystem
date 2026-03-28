import '../../../../core/core.dart';

import '../entity/prescription.dart';
import '../repository/i_prescription_repository.dart';

class GetPatientPrescriptionsUseCase implements UseCase<List<Prescription>, int> {
  final IPrescriptionRepository _repository;

  GetPatientPrescriptionsUseCase(this._repository);

  @override
  Future<Result<List<Prescription>>> call(int hospitalizationId) {
    return _repository.getPatientPrescriptions(hospitalizationId);
  }
}
