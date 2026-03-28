import '../../../../core/core.dart';
import '../entity/medicine.dart';

abstract class IMedicineRepository {
  /// İlaç ve tıbbi sarf malzemelerini sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<Medicine>>>> getMedicines({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<ApiResponse<List<Medicine>>>> getDrugs({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<ApiResponse<List<Medicine>>>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  });

  /// ID'si verilen ilacı getirir.
  Future<Result<Drug?>> getDrug(int id);

  /// Yeni bir ilaç oluşturur.
  Future<Result<void>> createMedicine(Medicine medicine);

  /// Mevcut bir ilacı günceller.
  Future<Result<void>> updateMedicine(Medicine medicine);

  /// ID'si verilen ilacı siler.
  Future<Result<void>> deleteMedicine(Medicine medicine);

  /// ID'si verilen ilacın eşdeğer ilaçlarını getirir.
  Future<Result<ApiResponse<List<Medicine>>>> getEquivalentMedicines(int id);
}
