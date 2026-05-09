import 'package:pharmed_core/pharmed_core.dart';

import '../../stock_transaction.dart';

class CreateStockTransactionUseCase {
  final IStockTransactionRepository _repository;

  CreateStockTransactionUseCase(this._repository);

  Future<Result<void>> call(StockTransaction transaction) {
    return _repository.createTransaction(transaction);
  }
}
