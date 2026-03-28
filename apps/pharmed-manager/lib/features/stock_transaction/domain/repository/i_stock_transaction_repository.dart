import '../../../../core/core.dart';
import '../entity/stock_transaction.dart';

abstract class IStockTransactionRepository {
  Future<Result<List<StockTransaction>>> getStockTransactions();
  Future<Result<StockTransaction>> createTransaction(StockTransaction entity);
  Future<Result<void>> deleteTransaction(int id);
  Future<Result<List<StockTransaction>>> getCabinStockTransactions(int stationId);
}
