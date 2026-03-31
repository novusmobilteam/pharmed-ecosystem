import '../../../../core/core.dart';

class GetUrgentPatientsUseCase implements NoParamsUseCase<List<UrgentPatient>> {
  final IPatientRepository _repository;

  GetUrgentPatientsUseCase(this._repository);

  @override
  Future<Result<List<UrgentPatient>>> call() async {
    return await _repository.getUrgentPatients();
  }
}
