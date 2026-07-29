// [SWREQ-REFUND-UC-001] [IEC 62304 §5.5]
// İade durum kontrol use case'i.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:collection/collection.dart';

class CheckMasterRefundStatusUseCase {
  CheckMasterRefundStatusUseCase(this._refundRepository, this._cabinRepository);

  final IRefundRepository _refundRepository;
  final ICabinRepository _cabinRepository;

  /// [item]: kullanıcının seçtiği kalem (source zaten dolu). [returnType]/
  /// [quantity]: kullanıcının bu adımda seçtiği/girdiği değerler.
  /// Döner: aynı item'ın returnType/returnQuantity/resolvedTarget alanları
  /// doldurulmuş hâli — hedef göz artık item'ın İÇİNDE, ayrı bir
  /// MedicineAssignment? dönmüyoruz, çağıran taraf tek bir nesneyle ilgilenir.
  Future<Result<RefundableItem>> call({
    required RefundableItem item,
    required ReturnType returnType,
    required double quantity,
  }) async {
    final checkResult = await _refundRepository.checkMasterRefundStatus(id: item.id, quantity: quantity);

    if (checkResult.isError) {
      return Result.error((checkResult as Error).error);
    }

    final Result<MedicineAssignment?> targetResult = switch (returnType) {
      ReturnType.toPharmacy => Result.ok(null),
      ReturnType.toReturnBox || ReturnType.toDrawer => await _handleDrawer(),
      ReturnType.toOrigin => Result.ok(checkResult.data?.cabinAssignment),
    };

    if (targetResult.isError) {
      return Result.error((targetResult as Error).error);
    }

    return Result.ok(
      item.copyWith(returnQuantity: quantity, returnType: returnType, resolvedTarget: targetResult.data),
    );
  }

  Future<Result<MedicineAssignment?>> _handleDrawer() async {
    final cabinResult = await _cabinRepository.getCabins();

    final cabins = cabinResult.data;
    if (cabins == null) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
    }

    return _findCubicSlot(cabins);
  }

  Future<Result<MedicineAssignment?>> _findCubicSlot(List<Cabin> cabins) async {
    if (cabins.isEmpty) {
      return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
    }

    for (final cabin in cabins) {
      final cabinId = cabin.id;
      if (cabinId == null) continue;

      final slotsResult = await _cabinRepository.getCabinSlots(cabinId);
      final slots = slotsResult.data;
      if (slots == null) continue;

      final cubicSlot = slots.firstWhereOrNull((slot) => slot.drawerConfig?.drawerType?.isKubik ?? false);

      if (cubicSlot != null) {
        return Result.ok(
          MedicineAssignment(
            drawerUnit: DrawerUnit(drawerSlotId: cubicSlot.id, drawerSlot: cubicSlot),
            cabin: cabin,
          ),
        );
      }
    }

    return Result.error(CustomException(message: contextlessL10n().core_genericErrorRetryMessage));
  }
}
