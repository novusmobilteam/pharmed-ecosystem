import 'package:pharmed_core/pharmed_core.dart';

class DischargeHospitalizationUseCase {
  final IHospitalizationRepository _repository;

  DischargeHospitalizationUseCase(this._repository);

  Future<Result<void>> call(int hospitalizationId) {
    return _repository.discharge(hospitalizationId);
  }
}
