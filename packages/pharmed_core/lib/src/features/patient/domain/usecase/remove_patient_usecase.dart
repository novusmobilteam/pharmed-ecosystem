import 'package:pharmed_core/pharmed_core.dart';

class RemovePatientsUseCase {
  final IPatientRepository _repository;
  RemovePatientsUseCase(this._repository);

  Future<Result<void>> call(List<int> ids) async {
    return _repository.removePatients(ids);
  }
}
