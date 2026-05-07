import 'package:pharmed_core/pharmed_core.dart';

class GetHospitalizedAndRecentExitsUseCase {
  final IPatientRepository _repository;

  GetHospitalizedAndRecentExitsUseCase(this._repository);

  Future<Result<List<Patient>>> call() async {
    return await _repository.getHospitalizedAndRecentExits();
  }
}
