import '../../../../core/core.dart';

import '../entity/patient.dart';
import '../repository/i_patient_repository.dart';

class UpdatePatientUseCase implements UseCase<void, Patient> {
  final IPatientRepository _repository;
  UpdatePatientUseCase(this._repository);

  @override
  Future<Result<void>> call(Patient patient) => _repository.updatePatient(patient);
}
