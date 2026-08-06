import 'package:pharmed_core/pharmed_core.dart';

class GetUrgentPatientsUseCase {
  final IPatientRepository _repository;

  GetUrgentPatientsUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call() async {
    return await _repository.getUrgentPatients();
  }
}
