// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Bir DrawerSlot'u kabinin iade çekmecesi olarak işaretler.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class SetReturnDrawerUseCase {
  const SetReturnDrawerUseCase(this._repository);

  final ICabinRepository _repository;

  Future<Result<void>> call(int drawerSlotId, bool status) => _repository.updateReturnDrawer(drawerSlotId, status);
}
