import '../../../../core/core.dart';

import '../repository/i_stock_transaction_repository.dart';

class DeleteStockTransactionUseCase {
  final IStockTransactionRepository _repository;

  DeleteStockTransactionUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteTransaction(id);
  }
}
