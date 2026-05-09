import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class StockTransactionRepositoryImpl implements IStockTransactionRepository {
  final StockTransactionRemoteDataSource _dataSource;
  final StockTransactionMapper _mapper;

  StockTransactionRepositoryImpl({
    required StockTransactionRemoteDataSource dataSource,
    required StockTransactionMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  @override
  Future<Result<List<StockTransaction>>> getStockTransactions({int? skip, int? take, String? search}) async {
    final r = await _dataSource.getStockTransactions();
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (err) => Result.error(err));
  }

  @override
  Future<Result<StockTransaction?>> createTransaction(StockTransaction entity) async {
    final dto = _mapper.toDto(entity);
    final res = await _dataSource.createTransaction(dto);

    return res.when(ok: (dto) => Result.ok(_mapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    final r = await _dataSource.deleteTransaction(id);
    return r.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<StockTransaction>>> getCabinStockTransactions(int stationId) async {
    final r = await _dataSource.getCabinStockTransactions(stationId);
    return r.when(ok: (dtos) => Result.ok(_mapper.toEntityList(dtos)), error: (err) => Result.error(err));
  }
}
