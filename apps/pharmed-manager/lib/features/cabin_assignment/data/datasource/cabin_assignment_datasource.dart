import '../../../../core/core.dart';
import '../model/cabin_assignment_dto.dart';

/// Kabin çekmecelerindeki miktar ve stok bilgilerini yöneten veri kaynağı arayüzü.
abstract class CabinAssignmentDataSource {
  /// Belirtilen kabin ID'sine ait miktar listesini getirir.
  Future<Result<List<CabinAssignmentDTO>>> getAssignments(int cabinId);

  /// Yeni bir miktar kaydı oluşturur.
  Future<Result<void>> createAssignment(CabinAssignmentDTO dto);

  /// Var olan miktar kaydını günceller.
  Future<Result<void>> updateAssignment(CabinAssignmentDTO dto);

  /// Belirtilen ID'ye sahip miktar kaydını siler.
  Future<Result<void>> deleteAssignment(int id);

  /// Belirli bir materyal ID'sine göre miktar bilgisini getirir.
  Future<Result<List<CabinAssignmentDTO>>> getMaterialAssignment(int materialId);

  /// Kullanıcının giriş yaptığı kabine ataması yapılan ilaçları getiren istek.
  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignments();

  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignmentsWithCabinId(int cabinId);

  /// Giriş yapmış kullanıcının ordersız olarak alım yapabileceği ilaçları getiren servis
  Future<Result<List<CabinAssignmentDTO>>> getOrderlessCabinAssignments();

  /// Serbest ilaçları getiren servis
  Future<Result<List<CabinAssignmentDTO>>> getIndependentMaterials();
}
