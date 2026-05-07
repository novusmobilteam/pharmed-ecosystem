import '../../../../core/core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class CreateStockTransactionUseCase {
  final IStockTransactionRepository _repository;

  CreateStockTransactionUseCase(this._repository);

  Future<Result<void>> call(StockTransaction transaction) {
    return _repository.createTransaction(transaction);
  }
}
