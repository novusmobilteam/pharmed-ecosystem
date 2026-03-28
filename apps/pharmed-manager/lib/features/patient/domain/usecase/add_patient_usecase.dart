import '../../../../core/core.dart';

import '../repository/i_patient_repository.dart';

class AddPatientParams {
  final int userId;
  final int hospitalizationId;

  AddPatientParams({required this.userId, required this.hospitalizationId});

  Map<String, dynamic> toJson() {
    return {"userId": userId, "patientHospitalizationId": hospitalizationId};
  }
}

class AddPatientUseCase implements UseCase<void, List<AddPatientParams>> {
  final IPatientRepository _repository;
  AddPatientUseCase(this._repository);

  @override
  Future<Result<void>> call(List<AddPatientParams> params) {
    return _repository.addPatients(params.map((p) => p.toJson()).toList());
  }
}
