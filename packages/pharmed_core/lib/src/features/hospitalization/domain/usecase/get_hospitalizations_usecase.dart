import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetHospitalizationsUseCase(this._repository);

  Future<Result<ApiResponse<List<Hospitalization>>>> call(PagedQueryParams params) async {
    return _repository.getHospitalizations(
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
