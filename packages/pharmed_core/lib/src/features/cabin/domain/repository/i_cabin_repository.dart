// [SWREQ-CORE-CABIN-001] [IEC 62304 §5.5]
// Kabin domain repository arayüzü.
//
// Dönüş tipi kuralları:
//   - Read operasyonları → RepoResult<T>
//     API başarılı → RepoSuccess
//     API başarısız + cache var → RepoStale
//     API başarısız + cache yok → RepoFailure
//   - Write operasyonları (create/update/delete) → Result<T>
//     Cache'i etkiler (invalidate), ama offline write desteklenmez.
//   - getDrawerUnits → Result<T> (gerçek zamanlı, cache'lenmez)
//   - getSerumSlots → Result<T> (gerçek zamanlı, cache'lenmez)
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ICabinRepository {
  // ==================== KABİN İŞLEMLERİ ====================

  /// Sistemdeki tüm kabinleri listeler.
  Future<RepoResult<List<Cabin>>> getCabins();

  /// Belirli bir istasyona bağlı kabinleri listeler.
  Future<RepoResult<List<Cabin>>> getCabinsByStation(int stationId);

  /// Yeni bir kabin tanımı oluşturur.
  Future<Result<Cabin?>> createCabin(Cabin cabin);

  /// Mevcut bir kabinin temel bilgilerini günceller.
  Future<Result<Cabin?>> updateCabin(Cabin cabin);

  /// Kabini sistemden kaldırır.
  Future<Result<void>> deleteCabin(Cabin cabin);

  // ==================== YUVA (SLOT) VE DİZİLİM İŞLEMLERİ ====================

  /// Bir kabinin fiziksel yuva (slot) yapısını ve dizilimini getirir.
  Future<RepoResult<List<DrawerSlot>>> getCabinSlots(int cabinId);

  /// Seçili çekmeceye ait iç parçaları getirir. Gerçek zamanlı — cache'lenmez.
  Future<RepoResult<List<DrawerUnit>>> getDrawerUnits(int slotId);

  /// Kabin için yeni bir yuva dizilimi kaydeder.
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots);

  /// Mevcut yuva dizilimini günceller.
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots);

  /// Sadece serum tanımlanabilen yuvaları getirir. Gerçek zamanlı — cache'lenmez.
  Future<Result<List<DrawerSlot>>> getSerumSlots();

  // ==================== KONFİGÜRASYON & TİP (META VERİLER) ====================

  /// Sistemde tanımlı tüm çekmece şablonlarını getirir.
  /// [forceRefresh]: true ise cache atlanır, API'ye gidilir.
  Future<RepoResult<List<DrawerType>>> getDrawerTypes({bool forceRefresh = false});

  /// Motor ayarları ve cihaz tipi bilgilerini içeren konfigürasyonları getirir.
  /// [forceRefresh]: true ise cache atlanır, API'ye gidilir.
  Future<RepoResult<List<DrawerConfig>>> getDrawerConfigs({bool forceRefresh = false});
}
