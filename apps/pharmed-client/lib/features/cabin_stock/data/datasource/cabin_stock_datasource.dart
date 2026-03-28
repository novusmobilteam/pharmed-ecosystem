// lib/feature/cabin_stock/data/datasource/cabin_stock_datasource.dart
//
// [SWREQ-DS-INTERFACE-001]
// CabinStock feature'ının veri kaynağı sözleşmesi.
// Remote, local ve mock implementasyonlar bu interface'i uygular.
// Repository yalnızca bu interface'i bilir, implementasyonu bilmez.
//
// Tüm metodlar:
//   - Result<T> döner — exception fırlatmaz
//   - Input validasyonu implementasyon tarafında yapılır
//   - Her çağrı MedLogger ile izlenir
//
// Sınıf: Class B

import 'package:result_dart/result_dart.dart';
import '../dto/cabin_stock_dto.dart';
import '../dto/station_stock_dto.dart';

abstract interface class CabinStockDataSource {
  // ── Okuma işlemleri ───────────────────────────────────────────

  /// [SWREQ-DS-001] [HAZ-003] [HAZ-007]
  /// Belirtilen kabindeki tüm çekmece stoklarını getirir.
  /// [cabinId] > 0 olmalıdır, aksi hâlde [ValidationException] döner.
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId);

  /// [SWREQ-DS-002] [HAZ-003]
  /// Giriş yapılmış aktif kabinin stoklarını getirir.
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock();

  /// [SWREQ-DS-003] [HAZ-003]
  /// Belirtilen ilacın kabin içinde hangi çekmeceye atandığını getirir.
  /// İlaç atanmamışsa [NotFoundException] ile [Result.failure] döner.
  /// [medicineId] > 0 olmalıdır, aksi hâlde [ValidationException] döner.
  Future<Result<CabinStockDTO>> getMedicineInfo(int medicineId);

  /// [SWREQ-DS-004] [HAZ-008]
  /// SKT'ye 14 gün veya daha az kalan stokları getirir.
  Future<Result<List<CabinStockDTO>>> getExpiringStocks();

  /// [SWREQ-DS-008] [HAZ-008]
  /// SKT'si geçmiş stokları getirir.
  Future<Result<List<CabinStockDTO>>> getExpiredStocks();

  /// [SWREQ-DS-009] [HAZ-003]
  /// Belirtilen istasyona ait stok özetini getirir.
  /// [stationId] > 0 olmalıdır.
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId);

  // ── Yazma işlemleri ───────────────────────────────────────────

  /// [SWREQ-DS-005] [HAZ-005]
  /// Sayım sonuçlarını kaydeder.
  /// [data] boş olamaz, aksi hâlde [ValidationException] döner.
  /// Başarılı kayıt sonrası ilgili cache geçersiz kılınmalıdır.
  Future<Result<void>> count(List<dynamic> data);

  /// [SWREQ-DS-006] [HAZ-004]
  /// Dolum işlemini kaydeder.
  /// [data] boş olamaz, aksi hâlde [ValidationException] döner.
  /// Başarılı kayıt sonrası ilgili cache geçersiz kılınmalıdır.
  Future<Result<void>> fill(List<dynamic> data);

  /// [SWREQ-DS-007] [HAZ-006]
  /// Boşaltma işlemini kaydeder.
  /// [data] boş olamaz, aksi hâlde [ValidationException] döner.
  /// Başarılı kayıt sonrası ilgili cache geçersiz kılınmalıdır.
  Future<Result<void>> unload(List<Map<String, dynamic>> data);
}
