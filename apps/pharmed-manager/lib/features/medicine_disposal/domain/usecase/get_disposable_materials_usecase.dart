import '../../../../core/core.dart';

import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';

class GetDisposableMaterialsUseCase implements NoParamsUseCase<List<MedicineAssignment>> {
  final IMedicineManagementRepository _repository;

  GetDisposableMaterialsUseCase(this._repository);

  @override
  Future<Result<List<MedicineAssignment>>> call() {
    return _repository.getDisposableMaterials();
  }
}
