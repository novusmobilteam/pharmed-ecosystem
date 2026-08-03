// [SWREQ-CORE-STOCK-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class GetExpiringStocksUseCase {
  final ICabinStockRepository _repository;

  GetExpiringStocksUseCase(this._repository);

  Future<Result<ApiResponse<List<CabinStock>>?>> call({PagedQueryParams? params}) =>
      _repository.getExpiringStocks(params: params);
}
