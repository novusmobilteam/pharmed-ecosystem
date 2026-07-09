import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IReportRepository {
  /// S.K.T Geçmiş Malzemeler
  Future<Result<ApiResponse<List<CabinStock>>?>> getExpiredStocks({PagedQueryParams? params, required int stationId});

  /// İstasyon Hareketleri
  Future<Result<ApiResponse<List<StockTransaction>>?>> getStationTransactions({
    PagedQueryParams? params,
    required int stationId,
  });

  /// Hastane Malzeme Listesi
  Future<Result<ApiResponse<List<HospitalStock>>?>> getHospitalStocks({
    PagedQueryParams? params,
    required int stationId,
  });
}
