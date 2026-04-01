import 'package:pharmed_core/pharmed_core.dart';

class DeleteHospitalizationUseCase {
  final IHospitalizationRepository _repository;

  DeleteHospitalizationUseCase(this._repository);

  Future<Result<void>> call(Hospitalization hospitalization) {
    return _repository.deleteHospitalization(hospitalization);
  }
}
