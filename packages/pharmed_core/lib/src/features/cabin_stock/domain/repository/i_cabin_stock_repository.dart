import 'package:pharmed_core/pharmed_core.dart';

abstract class ICabinStockRepository {
  Future<Result<List<CabinStock>>> getStocks(int cabinId);

  /// Giriş yapılmış kabindeki stokları getiren servis
  Future<Result<List<CabinStock>>> getCurrentCabinStock();

  /// İlaç Dolum Listesi ekranında ilgili ilacın kabinde hangi çekmeceye
  /// dolumunun yapılacağı veren servis.
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId);

  Future<Result<List<CabinStock>>> getExpiringStocks();

  /// Master kabin dolum işlemi
  Future<Result<void>> refillMasterCabin(List<dynamic> data);

  /// Mobil kabin dolum işlemi
  Future<Result<void>> refillMobileCabin(List<dynamic> data);

  Future<Result<List<StationStock>>> getStationStocks(int stationId);

  /// Eksik stok bildirimi onaylama işlemi
  Future<Result<void>> approveMissingStock(int prescriptionItemId);

  /// Eksik stok bildirimi reddetme işlemi
  Future<Result<void>> rejectMissingStock(int prescriptionItemId);

  /// Kabindeki tüm aktif RFID etiketlerini döner.
  /// Boş liste = kabinde RFID'li ilaç olmadığı anlamına gelir, hata değildir.
  Future<Result<List<CabinExpectedEpc>>> getExpectedEpcs(int cabinId);

  /// Mobil kabinde ilaç alım esnasında eksik stok bildirme işlemi
  Future<Result<void>> reportMissingStock({required int prescriptionItemId, required int cabinInventoryTypeId});

  /// Mobil kabinde fazla stok bildirme işlemi
  Future<Result<void>> reportExcessStock({required Map<String, dynamic> data, required int cabinInventoryTypeId});
}
