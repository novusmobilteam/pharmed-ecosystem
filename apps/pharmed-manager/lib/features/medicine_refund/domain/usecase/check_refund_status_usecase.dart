import 'package:collection/collection.dart';

import '../../../../core/core.dart';

import '../../../medicine_withdraw/domain/entity/medicine_withdraw_item.dart';
import '../repository/i_medicine_refund_repository.dart';

class CheckRefundStatusParams {
  final int id;
  final double quantity;
  final ReturnType returnType;
  final int medicineId;

  CheckRefundStatusParams({
    required this.id,
    required this.quantity,
    required this.returnType,
    required this.medicineId,
  });
}

class CheckRefundStatusUseCase implements UseCase<MedicineWithdrawItem?, CheckRefundStatusParams> {
  final IMedicineRefundRepository _refundRepository;
  final ICabinRepository _cabinRepository;

  CheckRefundStatusUseCase({
    required IMedicineRefundRepository refundRepository,
    required ICabinRepository cabinRepository,
  }) : _refundRepository = refundRepository,
       _cabinRepository = cabinRepository;

  @override
  Future<Result<MedicineWithdrawItem?>> call(CheckRefundStatusParams params) async {
    final type = params.returnType;
    final checkResult = await _refundRepository.checkRefundStatus(id: params.id, quantity: params.quantity);

    if (checkResult.isError) {
      return Result.error((checkResult as Error).error);
    }

    switch (type) {
      case ReturnType.toPharmacy:
      case ReturnType.toReturnBox:
        return Result.ok(null);
      case ReturnType.toDrawer:
        return _handleDrawer();
      case ReturnType.toOrigin:
        return Result.ok(checkResult.data);
    }
  }

  Future<Result<MedicineWithdrawItem?>> _handleDrawer() async {
    final cabinResult = await _cabinRepository.getCabins();

    return cabinResult.when(
      // RepoSuccess veya RepoStale — her ikisinde de veriyi kullan
      success: (cabins) => _findCubicSlot(cabins),
      stale: (cabins, _) => _findCubicSlot(cabins),
      failure: (error) => Result.error(error),
    );
  }

  Future<Result<MedicineWithdrawItem?>> _findCubicSlot(List<Cabin> cabins) async {
    if (cabins.isEmpty) {
      return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
    }

    for (final cabin in cabins) {
      final cabinId = cabin.id;
      if (cabinId == null) continue;

      final slotsResult = await _cabinRepository.getCabinSlots(cabinId);

      final foundAssignment = slotsResult.when(
        success: (slots) => _findCubicInSlots(slots, cabin),
        stale: (slots, _) => _findCubicInSlots(slots, cabin),
        failure: (_) => null,
      );

      if (foundAssignment != null) {
        return Result.ok(MedicineWithdrawItem.empty(foundAssignment));
      }
    }

    return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
  }

  CabinAssignment? _findCubicInSlots(List<DrawerSlot> slots, Cabin cabin) {
    final cubicSlot = slots.firstWhereOrNull((slot) => slot.drawerConfig?.drawerType?.isKubik ?? false);

    if (cubicSlot == null) return null;

    return CabinAssignment(
      drawerUnit: DrawerUnit(drawerSlotId: cubicSlot.id, drawerSlot: cubicSlot),
      cabin: cabin,
    );
  }
}
