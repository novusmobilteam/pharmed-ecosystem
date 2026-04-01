import 'package:pharmed_core/pharmed_core.dart';

class GetFilteredHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetFilteredHospitalizationsUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call(PatientFilterType type) {
    return _repository.getFilteredHospitalizations(type);
  }
}
