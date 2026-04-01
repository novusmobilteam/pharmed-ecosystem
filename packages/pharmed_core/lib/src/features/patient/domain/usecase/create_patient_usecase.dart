import 'package:pharmed_core/pharmed_core.dart';

class CreatePatientUseCase {
  final IPatientRepository _repository;
  CreatePatientUseCase(this._repository);

  Future<Result<void>> call(Patient patient) => _repository.createPatient(patient);
}
