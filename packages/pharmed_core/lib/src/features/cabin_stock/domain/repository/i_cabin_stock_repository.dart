import 'package:pharmed_core/pharmed_core.dart';

abstract class ICabinStockRepository {
  Future<Result<List<CabinStock>>> getStocks(int cabinId);

  /// Giriş yapılmış kabindeki stokları getiren servis
  Future<RepoResult<List<CabinStock>>> getCurrentCabinStock();

  /// İlaç Dolum Listesi ekranında ilgili ilacın kabinde hangi çekmeceye
  /// dolumunun yapılacağı veren servis.
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId);

  Future<Result<List<CabinStock>>> getExpiringStocks();

  /// Master kabin dolum işlemi
  Future<Result<void>> refillMasterCabin(List<dynamic> data);

  /// Mobil kabin dolum işlemi
  Future<Result<void>> refillMobileCabin(List<dynamic> data);

  Future<Result<void>> unload(List<Map<String, dynamic>> data);

  Future<Result<List<CabinStock>>> getExpiredStocks();

  Future<Result<List<StationStock>>> getStationStocks(int stationId);
}
