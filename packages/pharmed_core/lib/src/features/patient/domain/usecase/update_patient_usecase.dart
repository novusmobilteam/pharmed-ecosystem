import 'package:pharmed_core/pharmed_core.dart';

class UpdatePatientUseCase {
  final IPatientRepository _repository;
  UpdatePatientUseCase(this._repository);

  Future<Result<void>> call(Patient patient) => _repository.updatePatient(patient);
}
