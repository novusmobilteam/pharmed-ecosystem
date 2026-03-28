import '../../../../core/core.dart';
import '../model/drug_type_dto.dart';

/// İlaç Türü (Drug Type) işlemleri için veri kaynağı arayüzü.
abstract class DrugTypeDataSource {
  /// İlaç türlerini sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<DrugTypeDTO>>>> getDrugTypes({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni bir ilaç türü oluşturur.
  Future<Result<void>> createDrugType(DrugTypeDTO dto);

  /// Mevcut bir ilaç türünü günceller.
  Future<Result<void>> updateDrugType(DrugTypeDTO dto);

  /// ID'si verilen ilaç türünü siler.
  Future<Result<void>> deleteDrugType(int id);
}
