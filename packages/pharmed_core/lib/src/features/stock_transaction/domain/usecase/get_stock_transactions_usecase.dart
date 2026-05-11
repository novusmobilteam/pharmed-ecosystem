import 'package:pharmed_core/pharmed_core.dart';

class GetStockTransactionsUseCase {
  final IStockTransactionRepository _repository;

  GetStockTransactionsUseCase(this._repository);

  Future<Result<List<StockTransaction>>> call() {
    return _repository.getStockTransactions();
  }
}
