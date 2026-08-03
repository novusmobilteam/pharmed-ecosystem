// [SWREQ-CORE-DESTRUCTION-001] [IEC 62304 §5.5]
//
// CabinOperationTarget'ı, imha endpoint'inin beklediği (stockId + dosePiece)
// satırlarına çevirir. CabinOperationParamsMapper'dan KASITLI OLARAK AYRI —
// backend burada donanım adresi (shelfNo/compartmentNo/cabinDrawerDetailId)
// değil, doğrudan CabinStock.id istiyor (intake'teki IntakeDetail.stockId
// ile aynı kalıp). Miad hiç gönderilmiyor (imha edilen ilacın SKT'si zaten
// backend'de kayıtlı stok kaydından biliniyor).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

abstract final class DestructionParamsMapper {
  static List<DisposeMaterialParams> toParamsForTarget(CabinOperationTarget target) {
    if (!target.hasEntry) return const [];
    final assignment = target.assignment;

    if (target.isKubik) {
      final stockId = assignment.stocks?.firstOrNull?.id;
      final destroyQty = target.cubicSecondary;
      if (stockId == null || destroyQty <= 0) return const [];
      return [DisposeMaterialParams(stockId: stockId, dosePiece: destroyQty)];
    }

    final result = <DisposeMaterialParams>[];
    for (int i = 0; i < target.numberOfSteps; i++) {
      final step = target.steps[i];
      final destroyQty = step.secondaryQuantity ?? 0;
      if (destroyQty <= 0) continue;

      final details = assignment.cabinDrawerDetail;
      final detail = (details != null && i < details.length) ? details[i] : null;
      final stockId = assignment.stocks?.firstWhereOrNull((s) => s.cabinDrawerDetailId == detail?.id)?.id;
      if (stockId == null) continue;

      result.add(DisposeMaterialParams(stockId: stockId, dosePiece: destroyQty));
    }
    return result;
  }
}
