import '../../../../core/core.dart';

import '../repository/i_patient_repository.dart';

class EndEmergencyPatientParams {
  final int hospitalizationId;
  final int patientId;
  final List<int> prescriptionItemIds;

  /// Acil hasta sonlandırma servisi
  /// - [hospitalizationId] : Acil hastaya ait yatış id
  /// - [patientId] : Eşleştirilen hastaya ait id
  /// - [prescriptionItemIds] : Hasta üzerine çekilen ilaçların id'leri
  EndEmergencyPatientParams({
    required this.hospitalizationId,
    required this.patientId,
    required this.prescriptionItemIds,
  });
}

class EndEmergencyPatientUseCase implements UseCase<void, EndEmergencyPatientParams> {
  final IPatientRepository _repository;
  EndEmergencyPatientUseCase(this._repository);

  @override
  Future<Result<void>> call(EndEmergencyPatientParams params) {
    return _repository.endEmergencyPatient(
      hospitalizationId: params.hospitalizationId,
      patientId: params.patientId,
      prescriptionItemIds: params.prescriptionItemIds,
    );
  }
}
