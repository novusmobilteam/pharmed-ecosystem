import '../../../../core/core.dart';
import '../entity/cabin_assignment.dart';

abstract class ICabinAssignmentRepository {
  Future<Result<List<CabinAssignment>>> getAssignments(int cabinId);
  Future<Result<void>> createAssignment(CabinAssignment entity);
  Future<Result<void>> updateAssignment(CabinAssignment entity);
  Future<Result<void>> deleteAssignment(int id);
  Future<Result<List<CabinAssignment>>> getMaterialAssignment(int materialId);

  // Kullanıcının giriş yaptığı kabine ataması yapılan ilaçları getiren istek.
  Future<Result<List<CabinAssignment>>> getCabinAssignments();
  Future<Result<List<CabinAssignment>>> getCabinAssignmentsWithCabinId(int cabinId);

  /// Giriş yapmış kullanıcının ordersız olarak alım yapabileceği ilaçları getiren servis
  Future<Result<List<CabinAssignment>>> getOrderlessCabinAssignments();

  Future<Result<List<CabinAssignment>>> getIndependentMaterials();
}
