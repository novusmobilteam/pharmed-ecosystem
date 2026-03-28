import '../../../../core/core.dart';

import '../entity/patient.dart';
import '../repository/i_patient_repository.dart';

class CreatePatientUseCase implements UseCase<void, Patient> {
  final IPatientRepository _repository;
  CreatePatientUseCase(this._repository);

  @override
  Future<Result<void>> call(Patient patient) => _repository.createPatient(patient);
}
