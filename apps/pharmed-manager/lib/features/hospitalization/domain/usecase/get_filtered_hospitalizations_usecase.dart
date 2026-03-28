import '../../../../core/core.dart';

import '../entity/hospitalization.dart';
import '../repository/i_hospitalization_repository.dart';

class GetFilteredHospitalizationsUseCase implements UseCase<List<Hospitalization>, PatientFilterType> {
  final IHospitalizationRepository _repository;

  GetFilteredHospitalizationsUseCase(this._repository);

  @override
  Future<Result<List<Hospitalization>>> call(PatientFilterType type) {
    return _repository.getFilteredHospitalizations(type);
  }
}
