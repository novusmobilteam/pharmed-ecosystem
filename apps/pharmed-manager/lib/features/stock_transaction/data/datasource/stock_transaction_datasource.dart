import '../../../../core/core.dart';
import '../model/stock_transaction_dto.dart';

/// Stok İşlemleri (Stock Transaction) için veri kaynağı arayüzü.
abstract class StockTransactionDataSource {
  /// Stok işlemlerini sayfalı bir şekilde listeler.
  Future<Result<List<StockTransactionDTO>>> getStockTransactions();
  Future<Result<StockTransactionDTO?>> createTransaction(StockTransactionDTO dto);
  Future<Result<void>> deleteTransaction(int id);

  /// İstasyon(Kabin) bazlı stok hareketlerini getiren servis
  Future<Result<List<StockTransactionDTO>>> getCabinStockTransactions(int stationId);
}
