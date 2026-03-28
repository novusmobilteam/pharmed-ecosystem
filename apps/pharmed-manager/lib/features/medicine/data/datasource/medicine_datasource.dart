import '../../../../core/core.dart';
import '../model/medicine_dto.dart';

/// İlaç ve Tıbbi Sarf Malzemesi (Medicine) işlemleri için veri kaynağı arayüzü.
abstract class MedicineDataSource {
  /// İlaç ve tıbbi sarf malzemelerini sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<MedicineDTO>>>> getMedicines({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<ApiResponse<List<DrugDTO>>>> getDrugs({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<ApiResponse<List<MedicalConsumableDTO>>>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  });

  /// ID'si verilen ilacı getirir.
  Future<Result<DrugDTO?>> getDrug(int id);

  /// Yeni bir ilaç oluşturur.
  Future<Result<void>> createMedicine(MedicineDTO medicine);

  /// Mevcut bir ilacı günceller.
  Future<Result<void>> updateMedicine(MedicineDTO medicine);

  /// ID'si verilen ilacı siler.
  Future<Result<void>> deleteMedicine(MedicineDTO medicine);

  /// ID'si verilen ilacın eşdeğer ilaçlarını getirir.
  Future<Result<ApiResponse<List<MedicineDTO>>>> getEquivalentMedicines(
    int medicineId, {
    int? skip,
    int? take,
    String? search,
  });
}
