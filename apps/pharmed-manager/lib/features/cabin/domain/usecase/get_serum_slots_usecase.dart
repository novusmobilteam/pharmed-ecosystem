import '../../../../core/core.dart';

import '../entity/drawer_slot.dart';
import '../repository/i_cabin_repository.dart';

class GetSerumSlotsUseCase implements NoParamsUseCase<List<DrawerSlot>> {
  final ICabinRepository _repository;

  GetSerumSlotsUseCase(this._repository);

  @override
  Future<Result<List<DrawerSlot>>> call() {
    return _repository.getSerumSlots();
  }
}
