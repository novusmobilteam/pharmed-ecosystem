import 'package:pharmed_core/pharmed_core.dart';

class DeleteStockTransactionUseCase {
  final IStockTransactionRepository _repository;

  DeleteStockTransactionUseCase(this._repository);

  Future<Result<void>> call(int id) {
    return _repository.deleteTransaction(id);
  }
}
