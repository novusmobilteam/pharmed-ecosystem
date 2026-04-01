// [SWREQ-CORE-DASH-001] [IEC 62304 §5.5]
// Dashboard domain repository arayüzü.
// Read metodları RepoResult<T> döndürür.
// Cache TTL: 5 dakika — TTL dolmadan gelen istekler cache'den karşılanır.
// [forceRefresh]: true → TTL göz ardı edilir, API'ye gidilir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IDashboardRepository {
  /// Okunmamış QR kodlu reçete kalemlerini listeler.
  Future<RepoResult<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false});

  /// Son kullanma tarihi yaklaşan stok kalemlerini listeler.
  Future<RepoResult<List<CabinStock>>> getExpiringMaterials({bool forceRefresh = false});

  /// Kritik stok seviyesindeki kalemleri listeler.
  /// [isClient]: true → sadece aktif kabine ait stoklar, false → tüm kabinler.
  Future<RepoResult<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false});

  /// Uygulanmamış (onay bekleyen) reçeteleri listeler.
  Future<RepoResult<List<Prescription>>> getUnappliedPrescriptions({bool forceRefresh = false});

  /// İade işlemlerini listeler.
  Future<RepoResult<List<Refund>>> getRefunds({bool forceRefresh = false});

  /// Genel stok durumunu listeler.
  Future<RepoResult<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false});

  /// Yaklaşan tedavi zamanlarını listeler.
  Future<RepoResult<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false});

  /// Tüm in-memory cache'i temizler.
  /// Logout veya session sonlandırmada çağrılır.
  void clearCache();
}
