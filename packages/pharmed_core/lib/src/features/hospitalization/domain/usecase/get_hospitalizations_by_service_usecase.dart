import 'package:pharmed_core/pharmed_core.dart';

class GetHospitalizationsByServiceUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsByServiceUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call(int serviceId) {
    return _repository.getHospitalizationsByService(serviceId);
  }
}
