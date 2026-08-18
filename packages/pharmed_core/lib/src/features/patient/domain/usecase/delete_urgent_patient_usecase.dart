import 'package:pharmed_core/pharmed_core.dart';

class DeleteUrgentPatientUseCase {
  final IPatientRepository _repository;

  DeleteUrgentPatientUseCase(this._repository);

  Future<Result<void>> call(int patientId) async {
    return await _repository.deleteUrgentPatient(patientId);
  }
}
