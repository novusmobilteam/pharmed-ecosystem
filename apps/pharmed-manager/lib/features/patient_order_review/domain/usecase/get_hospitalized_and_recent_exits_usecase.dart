import '../../../../core/core.dart';

class GetHospitalizedAndRecentExitsUseCase implements NoParamsUseCase<List<Patient>> {
  final IPatientRepository _repository;

  GetHospitalizedAndRecentExitsUseCase(this._repository);

  @override
  Future<Result<List<Patient>>> call() async {
    return await _repository.getHospitalizedAndRecentExits();
  }
}
