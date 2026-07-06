import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetActiveHospitalizationsUseCase {
  final IHospitalizationRepository _repository;

  GetActiveHospitalizationsUseCase(this._repository);

  Future<Result<ApiResponse<List<Hospitalization>>>> call(PagedQueryParams params) async {
    print(params.startDate);
    return _repository.getActiveHospitalizations(
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
