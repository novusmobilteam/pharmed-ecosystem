import '../../../../core/core.dart';

import '../entity/my_patient.dart';
import '../repository/i_patient_repository.dart';

class GetMyPatientsUseCase implements NoParamsUseCase<List<MyPatient>> {
  final IPatientRepository _repository;
  GetMyPatientsUseCase(this._repository);

  @override
  Future<Result<List<MyPatient>>> call() {
    return _repository.getMyPatients();
  }
}
