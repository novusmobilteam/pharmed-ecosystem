import '../../../../../core/core.dart';
import '../model/cabin_dto.dart';
import '../model/drawer_config_dto.dart';
import '../model/drawer_slot_dto.dart';
import '../model/drawer_type_dto.dart';
import '../model/drawer_unit_dto.dart';

/// [GÜNCELLENMİŞ - 3 DATA SOURCE BİRLEŞTİRİLDİ]
///
/// Kabin ile ilgili TÜM veri işlemleri için merkezi data source.
///
/// ESKİ YAPI:
/// - CabinDataSource: Sadece kabin CRUD işlemleri
/// - CabinDesignDataSource: Kabin tasarım ve layout işlemleri
/// - DrawerDataSource: Çekmece tip ve konfig işlemleri
///
/// YENİ YAPI:
/// - CabinDataSource: Tüm cabin-related işlemler tek çatı altında
abstract class CabinDataSource {
  /// Kabinleri listeler.
  Future<Result<List<CabinDTO>>> getCabins();

  /// Belirli bir istasyona ait kabinleri listeler.
  Future<Result<List<CabinDTO>>> getCabinsByStation(int stationId);

  /// Yeni bir kabin oluşturur.
  Future<Result<CabinDTO?>> createCabin(CabinDTO dto);

  /// Mevcut kabin bilgilerini günceller.
  Future<Result<CabinDTO?>> updateCabin(CabinDTO dto);

  /// ID'si verilen kabini siler.
  Future<Result<void>> deleteCabin(int id);

  // ==================== ÇEKMECE TANIMLARI (Eski DrawerDataSource) ====================

  /// Tüm çekmece tiplerini (şablonlarını) getirir
  ///
  /// KULLANIM AMACI:
  /// - Cihaz taraması öncesi sistemde tanımlı tipleri göstermek
  /// - Yeni kabin oluştururken çekmece tipi seçimi
  /// - Raporlarda çekmece tipi filtreleme
  Future<Result<List<DrawerTypeDTO>>> getDrawerTypes();

  /// Tüm çekmece konfigürasyonlarını (motor ayarları) getirir
  ///
  /// KULLANIM AMACI:
  /// - Cihaz tarama sonuçlarını eşleştirmek
  /// - Kabin parametrelerini yönetmek
  /// - Kabin yerleşimini oluşturmak
  Future<Result<List<DrawerConfigDTO>>> getDrawerConfigs();

  /// Bir kabinin fiziksel yuva (slot) dizilimini getirir.
  /// Eski İsim: getCabinDesign
  Future<Result<List<DrawerSlotDTO>>> getCabinSlots(int cabinId);

  /// Seçili çekmeceye ait iç parçaları getiren servis.
  Future<Result<List<DrawerUnitDTO>>> getDrawerUnits(int slotId);

  /// Kabin için yeni yuva dizilimi oluşturur.
  /// Eski İsim: createCabinDesign
  Future<Result<void>> createDrawerSlots(List<DrawerSlotDTO> dtos);

  /// Mevcut yuva dizilimini günceller.
  Future<Result<void>> updateDrawerSlots(List<DrawerSlotDTO> dtos);

  /// Kabinin çekmecelerini çizmek için kullanılan fonksiyon. (Draw Cabin)
  //Future<Result<List<CabinLayoutDTO>>> getCabinLayout(int cabinId);

  /// İşlem yapılan kabinde yer alan serum kabinlerini çekmek için kullanılan istek.
  /// Hasta İlacı Tanımlama işlemi sırasında kullanılıyor. Hastaların ilaçları
  /// sadece serum kabinlerine tanımlanabiliyor.
  Future<Result<List<DrawerSlotDTO>>> getSerumCabins();
}
