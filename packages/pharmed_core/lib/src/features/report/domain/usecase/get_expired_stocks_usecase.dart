// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetExpiredStocksUseCase {
  final IReportRepository _repository;

  GetExpiredStocksUseCase(this._repository);

  Future<Result<ApiResponse<List<CabinStock>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getExpiredStocks(
        stationId: stationId,
        params: params.copyWith(
          searchFields: ['material.barcode', 'material.code', 'material.name', 'shelfNo', 'quantity'],
        ),
      );
}
