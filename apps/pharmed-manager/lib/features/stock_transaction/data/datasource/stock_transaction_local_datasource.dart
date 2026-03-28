import '../../../../core/core.dart';
import '../model/stock_transaction_dto.dart';
import 'stock_transaction_datasource.dart';

class StockTransactionLocalDataSource extends BaseLocalDataSource<StockTransactionDTO, int>
    implements StockTransactionDataSource {
  StockTransactionLocalDataSource({
    required String assetPath,
  }) : super(
          filePath: assetPath,
          fromJson: (m) => StockTransactionDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => StockTransactionDTO.fromJson({...d.toJson(), 'id': id}),
        );

  @override
  Future<Result<List<StockTransactionDTO>>> getStockTransactions() async {
    return Result.ok([]);
  }

  @override
  Future<Result<StockTransactionDTO?>> createTransaction(StockTransactionDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> deleteTransaction(int id) => deleteRequest(id);

  @override
  Future<Result<List<StockTransactionDTO>>> getCabinStockTransactions(int stationId) async {
    return Result.ok([]);
  }
}
