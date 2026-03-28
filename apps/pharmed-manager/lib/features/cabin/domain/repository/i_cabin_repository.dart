import '../../../../core/core.dart';
import '../entity/cabin.dart';
import '../entity/drawer_config.dart';
import '../entity/drawer_slot.dart';
import '../entity/drawer_type.dart';
import '../entity/drawer_unit.dart';

abstract class ICabinRepository {
// ==================== KABİN İŞLEMLERİ ====================

  /// Sistemdeki tüm kabinleri listeler.
  Future<Result<List<Cabin>>> getCabins();

  /// Belirli bir istasyona bağlı kabinleri listeler.
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId);

  /// Yeni bir kabin tanımı oluşturur.
  Future<Result<Cabin?>> createCabin(Cabin cabin);

  /// Mevcut bir kabinin temel bilgilerini günceller.
  Future<Result<Cabin?>> updateCabin(Cabin cabin);

  /// Kabini sistemden kaldırır.
  Future<Result<void>> deleteCabin(int id);

  // ==================== YUVA (SLOT) VE DİZİLİM İŞLEMLERİ ====================

  /// Bir kabinin fiziksel yuva (slot) yapısını ve dizilimini getirir.
  /// (Eski İsim: getCabinDesign)
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId);

  /// Seçili çekmeceye ait iç parçaları getiren servis.
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId);

  /// Kabin için yeni bir yuva dizilimi kaydeder.
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots);

  /// Mevcut yuva dizilimini (adres, sıra no vb.) günceller.
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots);

  /// Sadece serum tanımlanabilen yuvaları (Serum Slots) getirir.
  Future<Result<List<DrawerSlot>>> getSerumSlots();

  // ==================== KONFİGÜRASYON & TİP (META VERİLER) ====================

  /// Sistemde tanımlı tüm çekmece şablonlarını (Kübik, Birim Doz vb.) getirir.
  Future<Result<List<DrawerType>>> getDrawerTypes();

  /// Motor ayarları ve cihaz tipi (no) bilgilerini içeren tüm konfigürasyonları getirir.
  Future<Result<List<DrawerConfig>>> getDrawerConfigs();
}
