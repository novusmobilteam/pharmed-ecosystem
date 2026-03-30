// [SWREQ-CORE-STOCK-UC-005]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetExpiringStocksUseCase {
  final ICabinStockRepository _repository;
  GetExpiringStocksUseCase(this._repository);

  Future<Result<List<CabinStock>>> call() => _repository.getExpiringStocks();
}
