// [SWREQ-REFUND-UC-001] [IEC 62304 §5.5]
// İade durum kontrol use case'i.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CheckMasterRefundStatusUseCase {
  CheckMasterRefundStatusUseCase(this._refundRepository);

  final IRefundRepository _refundRepository;

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
      ReturnType.toPharmacy || ReturnType.toReturnBox || ReturnType.toDrawer => Result.ok(null),
      ReturnType.toOrigin => Result.ok(checkResult.data?.cabinAssignment),
    };

    if (targetResult.isError) {
      return Result.error((targetResult as Error).error);
    }

    return Result.ok(
      item.copyWith(returnQuantity: quantity, returnType: returnType, resolvedTarget: targetResult.data),
    );
  }
}
