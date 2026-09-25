import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// Alım planını (IntakeItem + CheckIntake'in stok detayları) kabin işlem
/// hedefine çevirir. Hangi gözden ne kadar alınacağı PLANDAN gelir —
/// kullanıcı yalnızca sayım girer.
///
/// Birim dozda çekmece, planın ulaştığı en arka göze kadar açılır (öndeki N
/// göz): FIFO önden arkaya aldığı için daha arkadaki (daha yeni) partilere
/// erişilemez. Göz çözülemeyen bir detay varsa null döner — plan kuyruğa
/// ALINMAZ; aksi halde ya çekmece tam açılır (FIFO güvenliği kalkar) ya da
/// fiziksel olarak alınmayan stok kayda gider.
abstract final class IntakeTargetMapper {
  static CabinOperationTarget? build(IntakeItem item, List<IntakeDetail> details) {
    final assignment = item.assignment;
    if (assignment == null || details.isEmpty) return null;

    final medicine = item.medicine;
    final countType = medicine is Drug ? medicine.countType : CountType.noCount;
    final totalDose = details.fold<double>(0, (sum, d) => sum + d.dosePiece);

    var target = CabinOperationTarget.fromAssignment(
      assignment,
      CabinOperationMode.intake,
      countType: countType,
      plannedQuantity: totalDose,
      sourceId: item.id,
    );

    if (target.isKubik) {
      final totalDose = details.fold<double>(0, (sum, d) => sum + d.dosePiece);
      return target.withCubicSecondary(totalDose);
    }

    final activeSteps = <int>{};
    var deepestStep = 0;
    for (final detail in details) {
      final stepNo = stepNoOf(item, detail.stockId);
      if (stepNo == null || stepNo < 1 || stepNo > target.steps.length) return null;

      final index = stepNo - 1;
      activeSteps.add(index);
      target = target.withStepSecondary(index, (target.steps[index].secondaryQuantity ?? 0) + detail.dosePiece);
      if (stepNo > deepestStep) deepestStep = stepNo;
    }

    return target.withIntakePlan(activeSteps: activeSteps, openUntilStep: deepestStep);
  }

  /// Stok → göz numarası (1 tabanlı). Önce servisin çözdüğü item.stock
  /// (sipariş bazlı alım), yoksa assignment.stocks (FIFO). İç içe stepNo
  /// boşsa cabinDrawerDetailId üzerinden atamanın göz listesinden bulunur.
  static int? stepNoOf(IntakeItem item, int stockId) {
    final itemStock = item.stock;
    final stock = itemStock != null && itemStock.id == stockId
        ? itemStock
        : item.assignment?.stocks?.firstWhereOrNull((s) => s.id == stockId);
    if (stock == null) return null;

    final nested = stock.cabinDrawerDetail?.stepNo;
    if (nested != null) return nested;

    final cellId = stock.cabinDrawerDetailId;
    return item.assignment?.cabinDrawerDetail?.firstWhereOrNull((c) => c.id == cellId)?.stepNo;
  }
}
