import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ReportRepositoryImpl implements IReportRepository {
  final ReportRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final StockTransactionMapper _stockTransactionMapper;
  final HospitalStockMapper _hospitalStockMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final UserAuthorizationSummaryMapper _summaryMapper;
  final UserAuthorizationDetailMapper _authorizationDetailMapper;
  final CabinTemperatureValueMapper _cabinTemperatureValueMapper;

  ReportRepositoryImpl({
    required ReportRemoteDataSource dataSource,
    required CabinStockMapper cabinStockMapper,
    required StockTransactionMapper stockTransactionMapper,
    required HospitalStockMapper hospitalStockMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required UserAuthorizationSummaryMapper summaryMapper,
    required UserAuthorizationDetailMapper authorizationDetailMapper,
    required CabinTemperatureValueMapper cabinTemperatureValueMapper,
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _stockTransactionMapper = stockTransactionMapper,
       _hospitalStockMapper = hospitalStockMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _summaryMapper = summaryMapper,
       _authorizationDetailMapper = authorizationDetailMapper,
       _cabinTemperatureValueMapper = cabinTemperatureValueMapper;

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

  @override
  Future<Result<ApiResponse<List<HospitalStock>>?>> getHospitalStocks({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getHospitalStocks(params: params, stationId: stationId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<HospitalStock>>(
          data: apiResponse?.data != null ? _hospitalStockMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getPatientInventory({
    PagedQueryParams? params,
    required int patientId,
  }) async {
    final result = await _dataSource.getPatientInventory(params: params, patientId: patientId);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<PrescriptionItem>>(
          data: apiResponse?.data != null ? _prescriptionItemMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<StockTransaction>>?>> getMaterialUsages({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    final result = await _dataSource.getMaterialUsages(params: params, stationId: stationId);
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

  @override
  Future<Result<ApiResponse<List<UserAuthorizationSummary>>?>> getAuthorizationSummary({
    PagedQueryParams? params,
  }) async {
    final result = await _dataSource.getAuthorizationSummary(params: params);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<UserAuthorizationSummary>>(
          data: apiResponse?.data != null ? _summaryMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<UserAuthorizationDetail?>> getUserAuthorizationSummary(int userId) async {
    final result = await _dataSource.getUserAuthorizationSummary(userId);
    return result.when(
      ok: (dto) => Result.ok(_authorizationDetailMapper.toEntityOrNull(dto)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<CabinTemperatureValue>>?>> getCabinTemperatures({
    PagedQueryParams? params,
    required int stationId,
    bool outOfRange = false,
  }) async {
    final result = await _dataSource.getCabinTemperatures(params: params, stationId: stationId, outOfRange: outOfRange);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<CabinTemperatureValue>>(
          data: apiResponse?.data != null ? _cabinTemperatureValueMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }
}
