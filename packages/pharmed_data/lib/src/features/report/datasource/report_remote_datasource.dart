import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class ReportRemoteDataSource extends BaseRemoteDataSource {
  ReportRemoteDataSource({required super.apiManager});

  static const String _basePath = '/Report';

  @override
  String get logSwreq => 'SWREQ-DATA-REPORT-001';

  @override
  String get logUnit => 'SW-UNIT-REPORT';

  Future<Result<ApiResponse<List<CabinStockDTO>>?>> getExpiredStocks({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    return await fetchRequest(
      path: '$_basePath/expiredMiadDate/$stationId',
      skip: params?.skip,
      take: params?.take,
      searchQuery: params?.searchQuery,
      searchFields: params?.searchFields,
      startDate: params?.startDate,
      endDate: params?.endDate,
      dateField: 'miadDate',
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(CabinStockDTO.fromJson),
    );
  }

  Future<Result<ApiResponse<List<StockTransactionDTO>>?>> getStationTransactions({
    PagedQueryParams? params,
    required int stationId,
  }) async {
    return await fetchRequest(
      path: '$_basePath/cabinStockTransaction/$stationId',
      skip: params?.skip,
      take: params?.take,
      searchQuery: params?.searchQuery,
      searchFields: params?.searchFields,
      startDate: params?.startDate,
      endDate: params?.endDate,

      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(StockTransactionDTO.fromJson),
    );
  }
}
