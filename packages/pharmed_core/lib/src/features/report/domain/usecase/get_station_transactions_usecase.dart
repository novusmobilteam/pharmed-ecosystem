// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetStationTransactionsUseCase {
  final IReportRepository _repository;

  GetStationTransactionsUseCase(this._repository);

  Future<Result<ApiResponse<List<StockTransaction>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getStationTransactions(
        stationId: stationId,
        params: params.copyWith(searchFields: ['material.barcode', 'material.code', 'material.name', 'quantity']),
      );
}
