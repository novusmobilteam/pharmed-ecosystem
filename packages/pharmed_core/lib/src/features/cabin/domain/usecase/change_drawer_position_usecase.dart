// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Aynı kabindeki iki çekmecenin (DrawerSlot) sırasını takas eder.
// Yalnızca birim doz ve kübik çekmeceler için kullanılır (serum hariç) —
// uygunluk kontrolü çağıran katmandadır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class ChangeDrawerPositionUseCase {
  const ChangeDrawerPositionUseCase(this._repository);

  final ICabinRepository _repository;

  Future<Result<void>> call({required int cabinId, required int sourceSlotId, required int targetSlotId}) {
    if (sourceSlotId == targetSlotId) return Future.value(const Result.ok(null));
    return _repository.changeDrawerPosition(cabinId: cabinId, sourceSlotId: sourceSlotId, targetSlotId: targetSlotId);
  }
}
