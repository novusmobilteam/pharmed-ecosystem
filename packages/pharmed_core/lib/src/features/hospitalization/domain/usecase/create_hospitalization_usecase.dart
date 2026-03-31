import 'package:pharmed_core/pharmed_core.dart';

class CreateHospitalizationUseCase {
  final IHospitalizationRepository _repository;

  CreateHospitalizationUseCase(this._repository);

  Future<Result<void>> call(Hospitalization hospitalization) {
    return _repository.createHospitalization(hospitalization);
  }
}
