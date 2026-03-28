import 'package:collection/collection.dart';

import '../../../../core/core.dart';

import '../../../cabin/domain/entity/drawer_unit.dart';
import '../../../cabin/domain/repository/i_cabin_repository.dart';
import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';

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
      final errorValue = (checkResult as Error).error;
      return Result.error(errorValue);
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
      error: (error) => Result.error(error),
      ok: (cabins) async {
        if (cabins.isEmpty) {
          return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
        }

        for (var cabin in cabins) {
          final cabinId = cabin.id;
          if (cabinId == null) continue;

          final slotsResult = await _cabinRepository.getCabinSlots(cabinId);

          final foundAssignment = slotsResult.when(
            error: (_) => null,
            ok: (slots) {
              //Slotlar içinden kübik olanı bul
              final cubicSlot = slots.firstWhereOrNull((slot) => slot.drawerConfig?.drawerType?.isKubik ?? false);

              if (cubicSlot != null) {
                return CabinAssignment(
                  drawerUnit: DrawerUnit(drawerSlotId: cubicSlot.id, drawerSlot: cubicSlot),
                  cabin: cabin,
                );
              }

              return null;
            },
          );

          // Eğer bir tane bulduysak döngüden çık ve dön
          if (foundAssignment != null) return Result.ok(MedicineWithdrawItem.empty(foundAssignment));
        }

        // Hiçbir kabinde kübik slot bulunamadı
        return Result.error(CustomException(message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz'));
      },
    );
  }
}
