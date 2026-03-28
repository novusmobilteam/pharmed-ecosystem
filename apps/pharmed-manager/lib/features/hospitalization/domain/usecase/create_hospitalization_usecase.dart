import '../../../../core/core.dart';

import '../entity/hospitalization.dart';
import '../repository/i_hospitalization_repository.dart';

class CreateHospitalizationUseCase implements UseCase<void, Hospitalization> {
  final IHospitalizationRepository _repository;

  CreateHospitalizationUseCase(this._repository);

  @override
  Future<Result<void>> call(Hospitalization hospitalization) {
    return _repository.createHospitalization(hospitalization);
  }
}
