import '../../../../core/core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class GetStockTransactionsUseCase implements NoParamsUseCase<List<StockTransaction>> {
  final IStockTransactionRepository _repository;

  GetStockTransactionsUseCase(this._repository);

  @override
  Future<Result<List<StockTransaction>>> call() {
    return _repository.getStockTransactions();
  }
}
