// [SWREQ-CORE-CABIN-SERUM-003] [IEC 62304 §5.5]
// Bağımsız serum kabininden kapak siler (#203).
//
// Kurallar:
//   • Kapakta ilaç ataması varsa silinmez (SERUM_LID_HAS_ASSIGNMENTS).
//   • Kapak 1'e kadar tek tek silinebilir. Son kapak silinirse kabin de
//     silinir — UI bunu ayrıca onaylatır ([SerumLidRemoval.cabinRemoved]).
//   • Kalan kapakların numarası (= port) değişmez.
// Servis: DELETE /CabinDesign/{id}; son kapakta ardından kabin silme.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum SerumLidRemoval { lidRemoved, cabinRemoved }

class RemoveSerumLidUseCase {
  const RemoveSerumLidUseCase({required ICabinRepository cabinRepository}) : _cabinRepository = cabinRepository;

  final ICabinRepository _cabinRepository;

  static const _unit = 'SW-UNIT-CABIN';
  static const _swreq = 'SWREQ-CORE-CABIN-SERUM-003';

  /// [lidCount]: kabindeki mevcut kapak sayısı (silinecek dahil).
  /// [assignments]: kabinin ilaç atamaları — silinecek kapakta atama var mı.
  Future<Result<SerumLidRemoval>> call({
    required Cabin cabin,
    required DrawerSlot lid,
    required int lidCount,
    required List<MedicineAssignment> assignments,
  }) async {
    final hasAssignments = assignments.any(
      (a) => lid.id != null && (a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId) == lid.id,
    );
    if (hasAssignments) {
      MedLogger.ruleRejected(
        unit: _unit,
        swreq: _swreq,
        rule: 'SERUM_LID_HAS_ASSIGNMENTS',
        context: {'cabinId': cabin.id, 'slotId': lid.id, 'lid': lid.orderNumber},
      );
      return Result.error(
        BusinessRuleException(
          message: contextlessL10n().cabinDesign_serum_lidHasAssignmentsError,
          ruleCode: 'SERUM_LID_HAS_ASSIGNMENTS',
        ),
      );
    }

    final deleted = await _cabinRepository.deleteDrawerSlot(lid);
    if (deleted.isError) {
      MedLogger.error(
        unit: _unit,
        swreq: _swreq,
        message: 'Serum kapağı silinemedi',
        context: {'cabinId': cabin.id, 'slotId': lid.id},
        error: deleted.when(ok: (_) => null, error: (e) => e),
      );
      return Result.error(deleted.when(ok: (_) => const UnexpectedException(), error: (e) => e));
    }
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Serum kapağı silindi',
      context: {'cabinId': cabin.id, 'slotId': lid.id, 'lid': lid.orderNumber, 'kalan': lidCount - 1},
    );

    if (lidCount > 1) return const Result.ok(SerumLidRemoval.lidRemoved);

    // Son kapak — kabin de silinir (kullanıcı onayladı).
    final cabinDeleted = await _cabinRepository.deleteCabin(cabin);
    if (cabinDeleted.isError) {
      MedLogger.error(
        unit: _unit,
        swreq: _swreq,
        message: 'Son kapak silindi ama kabin silinemedi',
        context: {'cabinId': cabin.id},
        error: cabinDeleted.when(ok: (_) => null, error: (e) => e),
      );
      return Result.error(cabinDeleted.when(ok: (_) => const UnexpectedException(), error: (e) => e));
    }
    MedLogger.info(
      unit: _unit,
      swreq: _swreq,
      message: 'Son kapakla birlikte kabin silindi',
      context: {'cabinId': cabin.id},
    );
    return const Result.ok(SerumLidRemoval.cabinRemoved);
  }
}
