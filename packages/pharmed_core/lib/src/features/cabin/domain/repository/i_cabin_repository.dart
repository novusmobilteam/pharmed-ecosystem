// [SWREQ-CORE-CABIN-001] [IEC 62304 §5.5]
// Kabin domain repository arayüzü.
//
// Dönüş tipi kuralları:
//   - Read operasyonları → Result<T>
//     API başarılı → RepoSuccess
//     API başarısız + cache var → RepoStale
//     API başarısız + cache yok → RepoFailure
//   - Write operasyonları (create/update/delete) → Result<T>
//     Cache'i etkiler (invalidate), ama offline write desteklenmez.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ICabinRepository {
  // ==================== KABİN İŞLEMLERİ ====================

  Future<Result<List<Cabin>>> getCabins();
  Future<Result<Cabin?>> getCabin(int cabinId);
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId);
  Future<Result<Cabin?>> createCabin(Cabin cabin);
  Future<Result<void>> updateCabin(Cabin cabin);
  Future<Result<void>> deleteCabin(Cabin cabin);

  // ==================== YUVA (SLOT) VE DİZİLİM İŞLEMLERİ ====================

  /// Bir kabinin fiziksel yuva (slot) yapısını ve dizilimini getirir.
  /// [forceRefresh]: true ise cache atlanır, API'ye gidilir. Cache, kabin
  /// dizaynı kaydedildiğinde (createDrawerSlots/updateDrawerSlots) otomatik
  /// invalidate edilir — normal akışta forceRefresh'e gerek yoktur.
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId, {bool forceRefresh = false});

  /// Mobil kabinin çekmece yapısını getirir.
  /// [forceRefresh]: true ise cache atlanır, API'ye gidilir.
  Future<Result<List<MobileDrawerSlot>>> getMobileCabinSlots(int cabinId, {bool forceRefresh = false});

  /// Seçili çekmeceye ait iç parçaları getirir.
  /// [forceRefresh]: true ise cache atlanır, API'ye gidilir. Cache, ilgili
  /// slot'un tasarımı güncellendiğinde (updateDrawerSlots içindeki
  /// scanResults ile) otomatik invalidate edilir.
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId, {bool forceRefresh = false});

  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots);
  Future<Result<void>> createMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers);
  Future<Result<void>> updateMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers);
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots);

  /// Sadece serum tanımlanabilen yuvaları getirir. Gerçek zamanlı — cache'lenmez.
  Future<Result<List<DrawerSlot>>> getSerumSlots();

  /// Serum kabininin kayıtlı raf/avadanlık yerleşimi. Her zaman 3 raf döner;
  /// hiç kayıt yoksa raflar boş ve id'sizdir. Gerçek zamanlı — cache'lenmez.
  Future<Result<List<SerumShelfLayout>>> getSerumLayout(int slotId);

  /// Serum yerleşimini kaydeder: raflar kayıtlıysa (id'li) PUT, değilse POST
  /// (/CabinDrawr/serum). İlgili slot'un unit cache'i invalidate edilir.
  Future<Result<void>> saveSerumLayout({required int slotId, required List<SerumShelfLayout> shelves});

  // ==================== KONFİGÜRASYON & TİP (META VERİLER) ====================

  Future<Result<List<DrawerType>>> getDrawerTypes({bool forceRefresh = false});
  Future<Result<List<DrawerConfig>>> getDrawerConfigs({bool forceRefresh = false});

  Future<Result<void>> updateReturnDrawer(int id, bool status);

  /// [cabinId] kabinindeki iki çekmecenin (DrawerSlot) sırasını takas eder.
  /// Başarılıysa kabinin slot cache'i invalidate edilir.
  Future<Result<void>> changeDrawerPosition({
    required int cabinId,
    required int sourceSlotId,
    required int targetSlotId,
  });
}
