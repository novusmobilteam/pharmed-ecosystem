import '../../../../core/core.dart';

import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../cabin_stock/domain/repository/i_cabin_stock_repository.dart';

class GetExpiredStocksUseCase implements NoParamsUseCase<List<CabinStock>> {
  final ICabinStockRepository _repository;
  GetExpiredStocksUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call() => _repository.getExpiredStocks();
}
