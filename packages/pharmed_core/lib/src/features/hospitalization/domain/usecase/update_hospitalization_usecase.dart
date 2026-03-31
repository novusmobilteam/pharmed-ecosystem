import 'package:pharmed_core/pharmed_core.dart';

class UpdateHospitalizationUseCase {
  final IHospitalizationRepository _repository;

  UpdateHospitalizationUseCase(this._repository);

  Future<Result<void>> call(Hospitalization hospitalization) {
    return _repository.updateHospitalization(hospitalization);
  }
}
