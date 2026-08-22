import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetCurrentStationDrugActivityUseCase {
  final IPrescriptionRepository _repository;

  GetCurrentStationDrugActivityUseCase(this._repository);

  Future<Result<ApiResponse<List<PrescriptionItemMovement>>?>> call(PagedQueryParams params) {
    return _repository.getCurrentStationDrugActivity(params);
  }
}
