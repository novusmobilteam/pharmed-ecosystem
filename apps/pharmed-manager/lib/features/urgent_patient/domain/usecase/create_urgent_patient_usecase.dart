import '../../../../core/core.dart';

import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../../../patient/domain/repository/i_patient_repository.dart';

class CreateUrgentPatientUseCase implements UseCase<Hospitalization?, int> {
  final IPatientRepository _repository;

  CreateUrgentPatientUseCase(this._repository);

  @override
  Future<Result<Hospitalization?>> call(int serviceId) async {
    return await _repository.createUrgentPatient(serviceId);
  }
}
