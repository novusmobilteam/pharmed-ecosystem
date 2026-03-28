import '../../../../core/core.dart';

import '../repository/i_stock_transaction_repository.dart';

class DeleteStockTransactionUseCase implements UseCase<void, int> {
  final IStockTransactionRepository _repository;

  DeleteStockTransactionUseCase(this._repository);

  @override
  Future<Result<void>> call(int id) {
    return _repository.deleteTransaction(id);
  }
}
