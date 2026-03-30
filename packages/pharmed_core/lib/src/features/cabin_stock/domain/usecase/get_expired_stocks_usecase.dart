// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetExpiredStocksUseCase {
  final ICabinStockRepository _repository;
  GetExpiredStocksUseCase(this._repository);

  Future<Result<List<CabinStock>>> call() => _repository.getExpiredStocks();
}
