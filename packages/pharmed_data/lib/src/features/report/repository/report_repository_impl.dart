import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ReportRepositoryImpl implements IReportRepository {
  final ReportRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final StockTransactionMapper _stockTransactionMapper;

  ReportRepositoryImpl({
    required ReportRemoteDataSource dataSource,
    required CabinStockMapper cabinStockMapper,
    required StockTransactionMapper stockTransactionMapper,
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _stockTransactionMapper = stockTransactionMapper;

  @override
  Future<Result<ApiResponse<List<CabinStock>>?>> getExpiredStocks({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getExpiredStocks(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<CabinStock>>(
          data: apiResponse?.data != null ? _cabinStockMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<StockTransaction>>?>> getStationTransactions({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getStationTransactions(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<StockTransaction>>(
          data: apiResponse?.data != null ? _stockTransactionMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }
}
