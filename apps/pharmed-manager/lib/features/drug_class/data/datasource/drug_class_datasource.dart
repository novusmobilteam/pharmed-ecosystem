import '../../../../core/core.dart';
import '../model/drug_class_dto.dart';

/// İlaç Sınıfı (Drug Class) işlemleri için veri kaynağı arayüzü.
///
/// Bu arayüz, ilaç sınıfı kayıtlarının listelenmesi, oluşturulması,
/// güncellenmesi ve silinmesi işlemlerini tanımlar.
abstract class DrugClassDataSource {
  /// İlaç sınıflarını sayfalı bir şekilde listeler.
  ///
  /// [skip]: Atlanacak kayıt sayısı (Pagination).
  /// [take]: Alınacak kayıt sayısı (Pagination).
  /// [search]: Arama metni.
  Future<Result<ApiResponse<List<DrugClassDTO>>>> getDrugClasses({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni bir ilaç sınıfı oluşturur.
  Future<Result<void>> createDrugClass(DrugClassDTO dto);

  /// Mevcut bir ilaç sınıfını günceller.
  Future<Result<void>> updateDrugClass(DrugClassDTO dto);

  /// ID'si verilen ilaç sınıfını siler.
  Future<Result<void>> deleteDrugClassById(int id);
}
