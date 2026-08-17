import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetHospitalizationsByServiceUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsByServiceUseCase(this._repository);

  Future<Result<ApiResponse<List<Hospitalization>>>> call(
    PagedQueryParams params, {
    required int serviceId,
    required PatientFilterType filter,
    bool myPatients = false,
  }) {
    return _repository.getHospitalizationsByService(
      params,
      serviceId: serviceId,
      filter: filter,
      myPatients: myPatients,
    );
  }
}
