import '../../../../core/core.dart';

import '../repository/i_patient_repository.dart';

class RemovePatientsUseCase implements UseCase<void, List<int>> {
  final IPatientRepository _repository;
  RemovePatientsUseCase(this._repository);

  @override
  Future<Result<void>> call(List<int> ids) async {
    return _repository.removePatients(ids);
  }
}
