import '../../../../core/core.dart';
import '../model/cabin_stock_dto.dart';
import '../model/station_stock_dto.dart';

/// Kabin stoklarını, ilaç bilgilerini ve sayım/dolum işlemlerini yöneten veri kaynağı.
abstract class CabinStockDataSource {
  /// Belirtilen kabindeki tüm çekmece stoklarını getirir.
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId);

  /// Giriş yapılmış kabindeki stokları getiren servis
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock();

  /// İlaç Dolum Listesi ekranında ilgili ilacın kabinde hangi çekmeceye
  /// dolumunun yapılacağı bilgisini verir.
  Future<Result<CabinStockDTO?>> getMedicineInfo(int medicineId);

  /// Son kullanma tarihi yaklaşan materyalleri (ilaçları) getirir.
  Future<Result<List<CabinStockDTO>>> getExpiringStocks();

  /// İlaç sayım ekranında sayım sonuçlarını kaydetmek için kullanılır.
  Future<Result<void>> count(List<dynamic> data);

  /// İlaç Dolum ekranında yapılan dolum işlemlerini kaydetmek için kullanılır.
  Future<Result<void>> fill(List<dynamic> data);

  /// İlaç Boşaltma
  Future<Result<void>> unload(List<Map<String, dynamic>> data);

  /// Son kullanma tarihi geçmiş malzemeleri getiren servis
  Future<Result<List<CabinStockDTO>>> getExpiredStocks();

  /// Seçili istasyona ait stok kayıtlarını getiren servis.
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId);
}
