import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IStockTransactionRepository {
  Future<Result<List<StockTransaction>>> getStockTransactions();
  Future<Result<StockTransaction?>> createTransaction(StockTransaction entity);
  Future<Result<void>> deleteTransaction(int id);
  Future<Result<List<StockTransaction>>> getCabinStockTransactions(int stationId);
}
