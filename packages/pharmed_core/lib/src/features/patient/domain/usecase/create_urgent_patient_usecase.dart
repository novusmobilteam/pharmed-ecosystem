import 'package:pharmed_core/pharmed_core.dart';

class CreateUrgentPatientUseCase {
  final IPatientRepository _repository;

  CreateUrgentPatientUseCase(this._repository);

  Future<Result<Hospitalization?>> call(int serviceId) async {
    return await _repository.createUrgentPatient(serviceId);
  }
}
