import 'package:pharmed_core/pharmed_core.dart';

class GetMyPatientsUseCase {
  final IPatientRepository _repository;
  GetMyPatientsUseCase(this._repository);

  Future<Result<List<MyPatient>>> call() {
    return _repository.getMyPatients();
  }
}
