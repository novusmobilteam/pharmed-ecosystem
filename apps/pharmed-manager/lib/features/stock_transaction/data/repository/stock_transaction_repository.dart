import '../../../../core/core.dart';
import '../../domain/entity/stock_transaction.dart';
import '../../domain/repository/i_stock_transaction_repository.dart';
import '../datasource/stock_transaction_datasource.dart';

class StockTransactionRepository implements IStockTransactionRepository {
  final StockTransactionDataSource _ds;

  StockTransactionRepository(this._ds);

  @override
  Future<Result<List<StockTransaction>>> getStockTransactions({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await _ds.getStockTransactions();
    return r.when(
      ok: (data) {
        List<StockTransaction> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<StockTransaction>> createTransaction(StockTransaction entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createTransaction(dto);

    return res.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    final r = await _ds.deleteTransaction(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<StockTransaction>>> getCabinStockTransactions(int stationId) async {
    final r = await _ds.getCabinStockTransactions(stationId);
    return r.when(
      ok: (data) {
        List<StockTransaction> entities = [];
        entities = data.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (err) => Result.error(err),
    );
  }
}
