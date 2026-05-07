import '../../../../core/core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class GetStockTransactionsUseCase {
  final IStockTransactionRepository _repository;

  GetStockTransactionsUseCase(this._repository);

  Future<Result<List<StockTransaction>>> call() {
    return _repository.getStockTransactions();
  }
}
