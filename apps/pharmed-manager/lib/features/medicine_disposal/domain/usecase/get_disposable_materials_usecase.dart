import '../../../../core/core.dart';

import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';

class GetDisposableMaterialsUseCase {
  final IMedicineManagementRepository _repository;

  GetDisposableMaterialsUseCase(this._repository);

  Future<Result<List<MedicineAssignment>>> call() {
    return _repository.getDisposableMaterials();
  }
}
