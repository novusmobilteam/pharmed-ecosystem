// [SWREQ-REFUND-UC-001] [IEC 62304 §5.5]
// İade durum kontrol use case'i.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:collection/collection.dart';

class CheckRefundStatusParams {
  const CheckRefundStatusParams({
    required this.id,
    required this.quantity,
    required this.returnType,
    required this.medicineId,
  });

  final int id;
  final double quantity;
  final ReturnType returnType;
  final int medicineId;
}

class CheckMasterRefundStatusUseCase {
  CheckMasterRefundStatusUseCase({
    required IRefundRepository refundRepository,
    required ICabinRepository cabinRepository,
  }) : _refundRepository = refundRepository,
       _cabinRepository = cabinRepository;

  final IRefundRepository _refundRepository;
  final ICabinRepository _cabinRepository;

  Future<Result<MedicineIntakeItem?>> call(CheckRefundStatusParams params) async {
    final checkResult = await _refundRepository.checkMasterRefundStatus(id: params.id, quantity: params.quantity);

    if (checkResult.isError) {
      return Result.error((checkResult as Error).error);
    }

    return switch (params.returnType) {
      ReturnType.toPharmacy || ReturnType.toReturnBox => Result.ok(null),
      ReturnType.toDrawer => _handleDrawer(),
      ReturnType.toOrigin => Result.ok(checkResult.data),
    };
  }

  Future<Result<MedicineIntakeItem?>> _handleDrawer() async {
    final cabinResult = await _cabinRepository.getCabins();

    // RepoResult → veri çıkar (success veya stale), failure → hata döndür
    final cabins = cabinResult.data;
    if (cabins == null) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
    }

    return _findCubicSlot(cabins);
  }

  Future<Result<MedicineIntakeItem?>> _findCubicSlot(List<Cabin> cabins) async {
    if (cabins.isEmpty) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
    }

    for (final cabin in cabins) {
      final cabinId = cabin.id;
      if (cabinId == null) continue;

      final slotsResult = await _cabinRepository.getCabinSlots(cabinId);

      // RepoResult → veri çıkar (success veya stale), failure → atla
      final slots = slotsResult.data;
      if (slots == null) continue;

      final cubicSlot = slots.firstWhereOrNull((slot) => slot.drawerConfig?.drawerType?.isKubik ?? false);

      if (cubicSlot != null) {
        return Result.ok(
          MedicineIntakeItem.empty(
            MedicineAssignment(
              drawerUnit: DrawerUnit(drawerSlotId: cubicSlot.id, drawerSlot: cubicSlot),
              cabin: cabin,
            ),
          ),
        );
      }
    }

    return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
  }
}
