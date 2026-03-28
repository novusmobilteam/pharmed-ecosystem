import '../../../../core/core.dart';
import '../model/cabin_temperature_dto.dart';
import '../model/cabin_temperature_detail_dto.dart';

/// Kabin sıcaklık kontrol işlemleri için veri kaynağı arayüzü.
///
/// Bu arayüz, kabin sıcaklık kayıtlarının listelenmesi, oluşturulması,
/// güncellenmesi ve silinmesi işlemlerini tanımlar.
abstract class CabinTemperatureDataSource {
  /// Kabin sıcaklık kayıtlarını sayfalı bir şekilde listeler.
  ///
  /// [skip]: Atlanacak kayıt sayısı (Pagination).
  /// [take]: Alınacak kayıt sayısı (Pagination).
  /// [search]: Arama metni.
  Future<Result<ApiResponse<List<CabinTemperatureDTO>>>> getCabinTemperatures({
    int? skip,
    int? take,
    String? search,
  });

  /// Belirli bir istasyona ait kabin sıcaklık detaylarını getirir.
  Future<Result<List<CabinTemperatureDetailDTO>>> getCabinTemperatureDetails(
      int stationId);

  /// Yeni bir kabin sıcaklık kaydı oluşturur.
  Future<Result<CabinTemperatureDTO?>> createCabinTemperature(
      CabinTemperatureDTO dto);

  /// Yeni bir kabin sıcaklık detay kaydı oluşturur.
  Future<Result<CabinTemperatureDetailDTO?>> createCabinTemperatureDetail(
      CabinTemperatureDetailDTO dto);

  /// Mevcut bir kabin sıcaklık detay kaydını günceller.
  Future<Result<CabinTemperatureDetailDTO?>> updateCabinTemperatureDetail(
      CabinTemperatureDetailDTO dto);

  /// ID'si verilen kabin sıcaklık detay kaydını siler.
  Future<Result<void>> deleteCabinTemperatureDetail(int id);
}
