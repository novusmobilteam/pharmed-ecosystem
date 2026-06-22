import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetUnappliedPrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetUnappliedPrescriptionsUseCase(this._repository);

  Future<Result<ApiResponse<List<Prescription>>?>> call(PagedQueryParams params) {
    return _repository.getUnappliedPrescriptions(
      skip: params.skip,
      take: params.take,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
