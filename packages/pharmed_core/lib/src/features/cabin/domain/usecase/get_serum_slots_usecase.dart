// [SWREQ-CORE-CABIN-UC-006]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class GetSerumSlotsUseCase {
  final ICabinRepository _repository;

  GetSerumSlotsUseCase(this._repository);

  Future<Result<List<DrawerSlot>>> call() {
    return _repository.getSerumSlots();
  }
}
