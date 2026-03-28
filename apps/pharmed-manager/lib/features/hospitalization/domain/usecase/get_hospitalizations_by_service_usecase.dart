import '../../../../core/core.dart';

import '../entity/hospitalization.dart';
import '../repository/i_hospitalization_repository.dart';

class GetHospitalizationsByServiceUseCase implements UseCase<List<Hospitalization>, int> {
  final IHospitalizationRepository _repository;

  GetHospitalizationsByServiceUseCase(this._repository);

  @override
  Future<Result<List<Hospitalization>>> call(int serviceId) {
    return _repository.getHospitalizationsByService(serviceId);
  }
}
