import '../../../../core/core.dart';

import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';

class GetDisposableMaterialsUseCase implements NoParamsUseCase<List<CabinAssignment>> {
  final IMedicineManagementRepository _repository;

  GetDisposableMaterialsUseCase(this._repository);

  @override
  Future<Result<List<CabinAssignment>>> call() {
    return _repository.getDisposableMaterials();
  }
}
