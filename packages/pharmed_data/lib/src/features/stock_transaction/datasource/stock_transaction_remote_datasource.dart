import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class StockTransactionRemoteDataSource extends BaseRemoteDataSource {
  final String _basePath = '/StockTransaction';

  @override
  String get logSwreq => 'SWREQ-DATA-STOCKTRANSACTION-001';

  @override
  String get logUnit => 'SW-UNIT-STOCKTRANSACTION';

  StockTransactionRemoteDataSource({required super.apiManager});

  Future<Result<StockTransactionDTO?>> createTransaction(StockTransactionDTO dto) {
    return postRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(StockTransactionDTO.fromJson),
      successLog: 'Transaction created',
    );
  }

  Future<Result<void>> deleteTransaction(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Transaction deleted',
    );
  }

  Future<Result<List<StockTransactionDTO>>> getStockTransactions() async {
    final r = await fetchRequest<List<StockTransactionDTO>>(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(StockTransactionDTO.fromJson),
    );
    return r.when(ok: (d) => Result.ok(d ?? []), error: Result.error);
  }

  Future<Result<List<StockTransactionDTO>>> getCabinStockTransactions(int stationId) async {
    final r = await fetchRequest<List<StockTransactionDTO>>(
      path: '/CabinDrawrStock/report/cabinStockTransaction/$stationId',
      parser: BaseRemoteDataSource.listParser(StockTransactionDTO.fromJson),
    );
    return r.when(ok: (d) => Result.ok(d ?? []), error: Result.error);
  }
}
