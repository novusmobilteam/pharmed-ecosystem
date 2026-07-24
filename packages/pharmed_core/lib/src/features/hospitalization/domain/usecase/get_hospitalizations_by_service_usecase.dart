import 'package:pharmed_core/pharmed_core.dart';

class GetHospitalizationsByServiceUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsByServiceUseCase(this._repository);

  Future<Result<List<Hospitalization>>> call({
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  }) {
    return _repository.getHospitalizationsByService(serviceId: serviceId, filter: filter, myPatients: myPatients);
  }
}
