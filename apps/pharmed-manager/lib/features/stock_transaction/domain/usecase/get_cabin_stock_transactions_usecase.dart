import '../../../../core/core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class GetCabinStockTransactionsUseCase implements UseCase<List<StockTransaction>, int> {
  final IStockTransactionRepository _repository;

  GetCabinStockTransactionsUseCase(this._repository);

  @override
  Future<Result<List<StockTransaction>>> call(int stationId) {
    return _repository.getCabinStockTransactions(stationId);
  }
}
