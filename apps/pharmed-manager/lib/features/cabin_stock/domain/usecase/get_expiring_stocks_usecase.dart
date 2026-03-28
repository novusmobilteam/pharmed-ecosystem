import '../../../../core/core.dart';

import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../cabin_stock/domain/repository/i_cabin_stock_repository.dart';

class GetExpiringStocksUseCase implements NoParamsUseCase<List<CabinStock>> {
  final ICabinStockRepository _repository;
  GetExpiringStocksUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call() => _repository.getExpiringStocks();
}
