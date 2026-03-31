import 'package:pharmed_core/pharmed_core.dart';

class AddPatientParams {
  final int userId;
  final int hospitalizationId;

  AddPatientParams({required this.userId, required this.hospitalizationId});

  Map<String, dynamic> toJson() {
    return {"userId": userId, "patientHospitalizationId": hospitalizationId};
  }
}

class AddPatientUseCase {
  final IPatientRepository _repository;
  AddPatientUseCase(this._repository);

  Future<Result<void>> call(List<AddPatientParams> params) {
    return _repository.addPatients(params.map((p) => p.toJson()).toList());
  }
}
