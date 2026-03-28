import '../../../../core/core.dart';

import '../../../patient/domain/entity/urgent_patient.dart';
import '../../../patient/domain/repository/i_patient_repository.dart';

class GetUrgentPatientsUseCase implements NoParamsUseCase<List<UrgentPatient>> {
  final IPatientRepository _repository;

  GetUrgentPatientsUseCase(this._repository);

  @override
  Future<Result<List<UrgentPatient>>> call() async {
    return await _repository.getUrgentPatients();
  }
}
