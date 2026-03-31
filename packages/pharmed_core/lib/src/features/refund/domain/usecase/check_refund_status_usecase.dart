// [SWREQ-REFUND-UC-001] [IEC 62304 §5.5]
// İade durum kontrol use case'i.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
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

class CheckRefundStatusUseCase {
  CheckRefundStatusUseCase({required IRefundRepository refundRepository, required ICabinRepository cabinRepository})
    : _refundRepository = refundRepository,
      _cabinRepository = cabinRepository;

  final IRefundRepository _refundRepository;
  final ICabinRepository _cabinRepository;

  Future<Result<MedicineWithdrawItem?>> call(CheckRefundStatusParams params) async {
    final checkResult = await _refundRepository.checkRefundStatus(id: params.id, quantity: params.quantity);

    if (checkResult.isError) {
      return Result.error((checkResult as Error).error);
    }

    return switch (params.returnType) {
      ReturnType.toPharmacy || ReturnType.toReturnBox => Result.ok(null),
      ReturnType.toDrawer => _handleDrawer(),
      ReturnType.toOrigin => Result.ok(checkResult.data),
    };
  }

  Future<Result<MedicineWithdrawItem?>> _handleDrawer() async {
    final cabinResult = await _cabinRepository.getCabins();

    // RepoResult → veri çıkar (success veya stale), failure → hata döndür
    final cabins = cabinResult.dataOrNull;
    if (cabins == null) {
      return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
    }

    return _findCubicSlot(cabins);
  }

  Future<Result<MedicineWithdrawItem?>> _findCubicSlot(List<Cabin> cabins) async {
    if (cabins.isEmpty) {
      return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
    }

    for (final cabin in cabins) {
      final cabinId = cabin.id;
      if (cabinId == null) continue;

      final slotsResult = await _cabinRepository.getCabinSlots(cabinId);

      // RepoResult → veri çıkar (success veya stale), failure → atla
      final slots = slotsResult.dataOrNull;
      if (slots == null) continue;

      final cubicSlot = slots.firstWhereOrNull((slot) => slot.drawerConfig?.drawerType?.isKubik ?? false);

      if (cubicSlot != null) {
        return Result.ok(
          MedicineWithdrawItem.empty(
            CabinAssignment(
              drawerUnit: DrawerUnit(drawerSlotId: cubicSlot.id, drawerSlot: cubicSlot),
              cabin: cabin,
            ),
          ),
        );
      }
    }

    return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
  }
}
