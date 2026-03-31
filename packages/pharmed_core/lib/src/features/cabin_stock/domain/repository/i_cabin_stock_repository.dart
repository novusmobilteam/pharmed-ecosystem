import 'package:pharmed_core/pharmed_core.dart';

abstract class ICabinStockRepository {
  Future<Result<List<CabinStock>>> getStocks(int cabinId);

  /// Giriş yapılmış kabindeki stokları getiren servis
  Future<Result<List<CabinStock>>> getCurrentCabinStock();

  // İlaç Dolum Listesi ekranında ilgili ilacın kabinde hangi çekmeceye
  // dolumunun yapılacağı veren servis.
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId);

  Future<Result<List<CabinStock>>> getExpiringStocks();

  // İlaç sayım ekranında sayım yapmak için kullanılan servis.
  Future<Result<void>> count(List<dynamic> data);

  // İlaç Dolum ekranında ilaç dolum için kullanılan servis.
  Future<Result<void>> fill(List<dynamic> data);

  Future<Result<void>> unload(List<Map<String, dynamic>> data);

  Future<Result<List<CabinStock>>> getExpiredStocks();

  Future<Result<List<StationStock>>> getStationStocks(int stationId);
}
