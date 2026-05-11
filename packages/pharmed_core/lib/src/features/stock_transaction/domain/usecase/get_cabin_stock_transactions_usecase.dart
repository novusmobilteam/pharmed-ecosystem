import 'package:pharmed_core/pharmed_core.dart';

class GetCabinStockTransactionsUseCase {
  final IStockTransactionRepository _repository;

  GetCabinStockTransactionsUseCase(this._repository);

  Future<Result<List<StockTransaction>>> call(int stationId) {
    return _repository.getCabinStockTransactions(stationId);
  }
}
