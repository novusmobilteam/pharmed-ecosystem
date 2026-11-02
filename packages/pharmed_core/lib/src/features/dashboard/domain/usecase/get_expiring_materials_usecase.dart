import 'package:pharmed_core/pharmed_core.dart';

class GetExpiringMaterialsUseCase {
  final IDashboardRepository _repository;

  GetExpiringMaterialsUseCase(this._repository);

  Future<Result<List<CabinStock>>> call({required int stationId, bool forceRefresh = false}) {
    return _repository.getExpiringMaterials(stationId: stationId, forceRefresh: forceRefresh);
  }
}
