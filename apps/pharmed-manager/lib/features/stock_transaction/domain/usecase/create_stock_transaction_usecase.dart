import '../../../../core/core.dart';

import '../entity/stock_transaction.dart';
import '../repository/i_stock_transaction_repository.dart';

class CreateStockTransactionUseCase implements UseCase<void, StockTransaction> {
  final IStockTransactionRepository _repository;

  CreateStockTransactionUseCase(this._repository);

  @override
  Future<Result<void>> call(StockTransaction transaction) {
    return _repository.createTransaction(transaction);
  }
}
