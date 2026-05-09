import 'package:pharmed_core/pharmed_core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class GetCabinStockTransactionsUseCase {
  final IStockTransactionRepository _repository;

  GetCabinStockTransactionsUseCase(this._repository);

  Future<Result<List<StockTransaction>>> call(int stationId) {
    return _repository.getCabinStockTransactions(stationId);
  }
}
