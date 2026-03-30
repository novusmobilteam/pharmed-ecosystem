import '../../../../core/core.dart';

import '../repository/i_dashboard_repository.dart';

class GetExpiringMaterialsUseCase implements NoParamsUseCase<List<CabinStock>> {
  final IDashboardRepository _repository;

  GetExpiringMaterialsUseCase(this._repository);

  @override
  Future<Result<List<CabinStock>>> call() {
    return _repository.getExpiringMaterials();
  }
}
