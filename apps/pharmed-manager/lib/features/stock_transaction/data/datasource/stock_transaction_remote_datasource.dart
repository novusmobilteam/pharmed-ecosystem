import '../../../../core/core.dart';
import '../model/stock_transaction_dto.dart';
import 'stock_transaction_datasource.dart';

class StockTransactionRemoteDataSource extends BaseRemoteDataSource implements StockTransactionDataSource {
  final String _basePath = '/StockTransaction';

  StockTransactionRemoteDataSource({required super.apiManager});

  @override
  Future<Result<StockTransactionDTO?>> createTransaction(
    StockTransactionDTO dto,
  ) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: singleParser(StockTransactionDTO.fromJson),
      successLog: 'Transaction created',
    );
  }

  @override
  Future<Result<void>> deleteTransaction(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Transaction deleted',
    );
  }

  @override
  Future<Result<List<StockTransactionDTO>>> getStockTransactions() async {
    final r = await fetchRequest<List<StockTransactionDTO>>(
      path: _basePath,
      //envelope: ResponseEnvelope.raw,
      parser: listParser(StockTransactionDTO.fromJson),
    );
    return r.when(
      ok: (d) => Result.ok(d ?? []),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<StockTransactionDTO>>> getCabinStockTransactions(int stationId) async {
    final r = await fetchRequest<List<StockTransactionDTO>>(
      path: '/CabinDrawrStock/report/cabinStockTransaction/$stationId',
      parser: listParser(StockTransactionDTO.fromJson),
    );
    return r.when(
      ok: (d) => Result.ok(d ?? []),
      error: Result.error,
    );
  }
}
