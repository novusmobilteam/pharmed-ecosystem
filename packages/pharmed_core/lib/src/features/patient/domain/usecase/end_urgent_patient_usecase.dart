import 'package:pharmed_core/pharmed_core.dart';

class EndUrgentPatientParams {
  final int hospitalizationId;
  final int patientId;
  final List<int> prescriptionItemIds;

  /// Acil hasta sonlandırma servisi
  /// - [hospitalizationId] : Acil hastaya ait yatış id
  /// - [patientId] : Eşleştirilen hastaya ait id
  /// - [prescriptionItemIds] : Hasta üzerine çekilen ilaçların id'leri
  EndUrgentPatientParams({required this.hospitalizationId, required this.patientId, required this.prescriptionItemIds});
}

class EndUrgentPatientUseCase {
  final IPatientRepository _repository;
  EndUrgentPatientUseCase(this._repository);

  Future<Result<void>> call(EndUrgentPatientParams params) {
    return _repository.endEmergencyPatient(
      hospitalizationId: params.hospitalizationId,
      patientId: params.patientId,
      prescriptionItemIds: params.prescriptionItemIds,
    );
  }
}
