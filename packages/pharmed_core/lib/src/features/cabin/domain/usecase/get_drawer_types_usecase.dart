// [SWREQ-CORE-CABIN-UC-008]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Sistemde tanımlı çekmece tiplerini getirir (repository local cache'i kullanır).
class GetDrawerTypesUseCase {
  final ICabinRepository _repository;

  GetDrawerTypesUseCase(this._repository);

  Future<Result<List<DrawerType>>> call({bool forceRefresh = false}) {
    return _repository.getDrawerTypes(forceRefresh: forceRefresh);
  }
}
