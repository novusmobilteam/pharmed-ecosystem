import 'package:pharmed_core/pharmed_core.dart';

class GetExpiringMaterialsUseCase {
  final IDashboardRepository _repository;

  GetExpiringMaterialsUseCase(this._repository);

  Future<RepoResult<List<CabinStock>>> call({bool forceRefresh = false}) {
    return _repository.getExpiringMaterials(forceRefresh: forceRefresh);
  }
}
