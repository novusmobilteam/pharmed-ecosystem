// [SWREQ-CORE-DASH-001] [IEC 62304 §5.5]
// Dashboard domain repository arayüzü.
// Read metodları Result<T> döndürür.
// Cache TTL: 5 dakika — TTL dolmadan gelen istekler cache'den karşılanır.
// [forceRefresh]: true → TTL göz ardı edilir, API'ye gidilir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IDashboardRepository {
  Future<Result<List<MenuItem>>> getMenuItems({int? userId});

  /// Okunmamış QR kodlu reçete kalemlerini listeler.
  Future<Result<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false});

  /// Son kullanma tarihi yaklaşan stok kalemlerini listeler.
  Future<Result<List<CabinStock>>> getExpiringMaterials({bool forceRefresh = false});

  /// Kritik stok seviyesindeki kalemleri listeler.
  /// [isClient]: true → sadece aktif kabine ait stoklar, false → tüm kabinler.
  Future<Result<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false});

  /// Uygulanmamış (onay bekleyen) reçeteleri listeler.
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptions({bool forceRefresh = false});

  /// İade işlemlerini listeler.
  Future<Result<List<Refund>>> getRefunds({bool forceRefresh = false});

  /// Genel stok durumunu listeler.
  Future<Result<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false});

  /// Yaklaşan tedavi zamanlarını listeler.
  Future<Result<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false, required String mac});

  /// Eksik bildirilen stokları listeler.
  Future<Result<List<PrescriptionItem>>> getMissingStocks({bool forceRefresh = false, required String mac});

  /// Kabinleri listeler. Kabinleri listeleyen metod token istediği için dashboard için ayrı bir
  /// endpoint tanımlandı.
  Future<Result<List<Cabin>>> getCabins();

  /// İlgili kabindeki ilaç aktivitilerini getirir
  Future<Result<List<PrescriptionItemMovement>?>> getDrugActivities({required String mac});
}
