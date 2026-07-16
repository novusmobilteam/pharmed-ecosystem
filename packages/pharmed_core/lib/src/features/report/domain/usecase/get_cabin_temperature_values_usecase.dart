import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetCabinTemperatureValuesUseCase {
  final IReportRepository _repository;

  GetCabinTemperatureValuesUseCase(this._repository);

  Future<Result<ApiResponse<List<CabinTemperatureValue>>?>> call(
    PagedQueryParams params, {
    required int stationId,
    bool outOfRange = false,
  }) => _repository.getCabinTemperatures(
    stationId: stationId,
    outOfRange: outOfRange,
    params: params.copyWith(searchFields: ['cabinName']),
  );
}
