// [SWREQ-CORE-ASSIGNMENT-UC-002]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DeleteMedicineAssignmentUseCase {
  final IAssignmentRepository _repository;

  DeleteMedicineAssignmentUseCase(this._repository);

  /// [id]: atamanın bağlı olduğu göz (cabinDrawrId).
  Future<Result<void>> call(int id) {
    return _repository.deleteMedicineAssignment(id);
  }

  /// Serum kabini: yalnızca verilen avadanlığın atamasını siler. Raf bazlı
  /// [call] serumda raftaki tüm avadanlık atamalarını sileceği için kullanılmaz.
  Future<Result<void>> serumTray(int cabinDrawerDetailId) {
    return _repository.deleteSerumTrayAssignment(cabinDrawerDetailId);
  }
}
