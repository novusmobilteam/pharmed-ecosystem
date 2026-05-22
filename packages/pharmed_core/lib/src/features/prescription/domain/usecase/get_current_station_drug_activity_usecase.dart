import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetCurrentStationDrugActivityUseCase {
  final IPrescriptionRepository _repository;

  GetCurrentStationDrugActivityUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItemMovement>>?>> call({
    int? skip,
    int? take,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getCurrentStationDrugActivity(
      search: search,
      skip: skip,
      take: take,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
