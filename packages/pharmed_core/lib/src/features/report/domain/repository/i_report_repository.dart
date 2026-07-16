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

  /// Hasta Envanter Listesi
  Future<Result<ApiResponse<List<PrescriptionItem>>?>> getPatientInventory({
    PagedQueryParams? params,
    required int patientId,
  });

  /// Malzeme Kullanım Listesi
  Future<Result<ApiResponse<List<StockTransaction>>?>> getMaterialUsages({
    PagedQueryParams? params,
    required int stationId,
  });

  /// Yetki Listesi
  Future<Result<ApiResponse<List<UserAuthorizationSummary>>?>> getAuthorizationSummary({PagedQueryParams? params});
  Future<Result<UserAuthorizationDetail?>> getUserAuthorizationSummary(int userId);

  /// Kabin Isı Listesi
  Future<Result<ApiResponse<List<CabinTemperatureValue>>?>> getCabinTemperatures({
    PagedQueryParams? params,
    required int stationId,
    bool outOfRange = false,
  });
}
