// pharmed_core/features/refund/refund_cell_grouper.dart
// [SWREQ-CLI-MREFUND-014] [IEC 62304 §5.5]
// Bir RefundDrawerJob içindeki TARGET'LARI (IntakeCellGrouper'ın aksine
// target İÇİNDEKİ değil, target'ların KENDİSİNİ) fiziksel göz (stock'un
// cabinDrawerDetail id'si) bazında gruplar. Aynı ilacın birden fazla
// RefundableItem'ı (farklı alım anları/stok kayıtları — ör. stockId 612,
// 612, 613) aynı fiziksel göze (612) düşüyorsa, kullanıcıya TEK bir kart
// olarak gösterilir — ama tamamlama sırasında her target kendi ayrı
// CompleteRefund isteğini atmaya devam eder (bkz. MasterRefundNotifier.
// _completeTarget, per-target çalışıyor). Bu, IntakeCellGrouper ile aynı
// "görünüm birleştirir, işlem ayırmaz" ilkesidir.
//
// SADECE toOrigin hedefli target'lar için anlamlıdır — toDrawer/toReturnBox
// zaten tek bir sabit hedefe (kübik slot) gider, oraya birden fazla target
// düşse bile ayrı gözlere dağılmaz, bu yüzden çağıran bu grouper'ı yalnızca
// toOrigin alt kümesine uygular.
//
// Bu SADECE bir görünüm/UI yardımcısıdır — RefundTarget/RefundDrawerJob'ın
// kendisini değiştirmez, state'te saklanmaz, her build'de türetilir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RefundCellGroup {
  const RefundCellGroup({required this.cellKey, required this.targetIndexes});

  /// Fiziksel göz kimliği — cabinDrawerDetail.id (DrawerCell.id).
  final int cellKey;

  /// Bu göze düşen tüm target'ların, verilen listedeki index'leri.
  final List<int> targetIndexes;

  bool get isMerged => targetIndexes.length > 1;
}

abstract final class RefundCellGrouper {
  /// [targets] (genelde toOrigin alt kümesi) içindeki target'ları, kaynak
  /// stoğun cabinDrawerDetail id'sine göre gruplar. cellKey çözülemeyen
  /// (stock/cabinDrawerDetail null) target'lar kendi başına, hiçbir
  /// diğeriyle birleşmeyen tek elemanlı gruplar olarak döner — negatif
  /// target index'i anahtar olarak kullanılır, gerçek bir id ile
  /// çakışmaz.
  static List<RefundCellGroup> group(List<RefundTarget> targets) {
    final Map<int, List<int>> byCell = {};

    for (var i = 0; i < targets.length; i++) {
      final detailId = targets[i].item.source.stock?.cabinDrawerDetailId;
      final key = detailId ?? -(i + 1);
      byCell.putIfAbsent(key, () => []).add(i);
    }

    return byCell.entries.map((e) => RefundCellGroup(cellKey: e.key, targetIndexes: e.value)).toList();
  }
}

extension RefundCellGroupX on RefundCellGroup {
  num totalQuantity(List<RefundTarget> targets) => targetIndexes.fold<num>(0, (sum, i) {
    final item = targets[i].item;
    return sum + (item.returnQuantity ?? item.appliedQuantity);
  });
}
