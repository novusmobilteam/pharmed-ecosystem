// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetHospitalStocksUseCase {
  final IReportRepository _repository;

  GetHospitalStocksUseCase(this._repository);

  Future<Result<ApiResponse<List<HospitalStock>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getHospitalStocks(
        stationId: stationId,
        params: params.copyWith(searchFields: ['materialName', 'materialCode']),
      );
}
