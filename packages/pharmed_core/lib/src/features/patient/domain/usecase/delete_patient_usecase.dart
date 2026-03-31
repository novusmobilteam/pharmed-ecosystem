import 'package:pharmed_core/pharmed_core.dart';

class DeletePatientUseCase {
  final IPatientRepository _repository;
  DeletePatientUseCase(this._repository);

  Future<Result<void>> call(Patient patient) => _repository.deletePatient(patient);
}
