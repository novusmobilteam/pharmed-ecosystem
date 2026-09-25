// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetStationTransactionsUseCase {
  final IReportRepository _repository;

  GetStationTransactionsUseCase(this._repository);

  Future<Result<ApiResponse<List<StationTransaction>>?>> call(PagedQueryParams params) =>
      _repository.getStationTransactions(
        params: params.copyWith(searchFields: ['material.barcode', 'material.code', 'material.name', 'quantity']),
      );
}
