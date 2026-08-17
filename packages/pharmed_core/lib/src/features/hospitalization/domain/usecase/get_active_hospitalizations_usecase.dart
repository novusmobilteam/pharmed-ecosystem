import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetActiveHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetActiveHospitalizationsUseCase(this._repository);

  Future<Result<ApiResponse<List<Hospitalization>>>> call(PagedQueryParams params) async {
    return _repository.getActiveHospitalizations(params);
  }
}
