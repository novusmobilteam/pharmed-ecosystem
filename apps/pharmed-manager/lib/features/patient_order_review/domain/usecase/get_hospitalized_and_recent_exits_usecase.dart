import '../../../../core/core.dart';

import '../../../patient/domain/entity/patient.dart';
import '../../../patient/domain/repository/i_patient_repository.dart';

class GetHospitalizedAndRecentExitsUseCase implements NoParamsUseCase<List<Patient>> {
  final IPatientRepository _repository;

  GetHospitalizedAndRecentExitsUseCase(this._repository);

  @override
  Future<Result<List<Patient>>> call() async {
    return await _repository.getHospitalizedAndRecentExits();
  }
}
