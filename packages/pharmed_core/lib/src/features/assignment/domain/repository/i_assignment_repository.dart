import 'package:pharmed_core/pharmed_core.dart';

abstract class IAssignmentRepository {
  /// Belirtilen kabindeki tüm ilaç atamalarını getirir.
  Future<Result<List<MedicineAssignment>>> getMedicineAssignments(int cabinId);

  /// Bir çekmece gözüne yeni ilaç ataması oluşturur.
  Future<Result<void>> createMedicineAssignment(MedicineAssignment entity);

  /// Mevcut bir ilaç atamasını günceller.
  Future<Result<void>> updateMedicineAssignment(MedicineAssignment entity);

  /// Belirtilen ID'ye sahip ilaç atamasını siler.
  Future<Result<void>> deleteMedicineAssignment(int id);

  /// Belirtilen ilaca ait tüm kabin atamalarını getirir.
  Future<Result<List<MedicineAssignment>>> getMaterialAssignment(int materialId);

  /// Giriş yapılan kabine ataması yapılmış ilaçları getirir.
  Future<Result<List<MedicineAssignment>>> getCabinAssignments();

  /// Belirtilen kabine ataması yapılmış ilaçları getirir.
  Future<Result<List<MedicineAssignment>>> getCabinAssignmentsWithCabinId(int cabinId);

  /// Giriş yapmış kullanıcının ordersız alım yapabileceği ilaçları getirir.
  Future<Result<List<MedicineAssignment>>> getOrderlessCabinAssignments();

  /// Bağımsız (reçetesiz) malzemeleri getirir.
  Future<Result<List<MedicineAssignment>>> getIndependentMaterials();

  /// Mobil kabin gözüne yatak ataması yapar.
  Future<Result<void>> createPatientAssignment({required int cellId, required int bedId});

  /// Belirtilen kabindeki tüm hasta atamalarını getirir.
  Future<Result<List<PatientAssignment>>> getPatientAssignments(int cabinId);
}
