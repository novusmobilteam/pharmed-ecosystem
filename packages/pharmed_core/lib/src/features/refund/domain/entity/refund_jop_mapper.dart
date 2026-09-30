// pharmed_core/features/refund/refund_job_mapper.dart
// [SWREQ-CORE-MREFUND-015] [IEC 62304 §5.5]
//
// Check edilmiş iade kalemlerini (RefundableItem — returnType ve
// resolvedTarget çözülmüş) CabinOperationTarget kuyruğuna çevirir.
// RefundTarget / RefundDrawerJob / RefundQueueBuilder / RefundCellGrouper'ın
// yerini alır.
//
// Gruplama birimi FİZİKSEL BİRİMDİR (drawerUnit): kübik göz, birim doz
// kolonu ya da iade çekmecesi. Aynı birime giden kalemler TEK target olur:
//   - Kübik: aynı gözün kapağı tek kez açılır, miktarlar toplanır.
//   - Birim doz: kalemler kaynak stoklarının gözüne (corpartmentNo) dağılır,
//     çekmece en arka göze kadar açılır.
//   - İade çekmecesi: tüm kalemler tek target — çekmece bir kez açılır.
// Target'ın girdisi YALNIZCA GÖSTERİM içindir; kayıt her kalem için ayrı
// CompleteRefund isteğiyle, kalemin kendi miktarıyla yapılır
// ([RefundJobPlan.itemsBySourceId]).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Aynı fiziksel birime giden iade kalemleri.
class RefundUnitGroup {
  RefundUnitGroup({required this.items, required this.isReturnDrawer}) : assert(items.isNotEmpty);

  final List<RefundableItem> items;
  final bool isReturnDrawer;

  /// Target'ın sourceId'si — grubun ilk kaleminin id'si. Her kalem tek bir
  /// gruba düştüğü için benzersizdir.
  int get sourceId => items.first.id;

  /// resolvedTarget yoksa boş atama döner — builder fiziksel çekmeceyi
  /// çözemez ve grubu [RefundJobPlan.skipped]'e koyar.
  MedicineAssignment get assignment => items.first.resolvedTarget ?? MedicineAssignment.empty(cabinDrawerId: 0);

  double get totalQuantity => items.fold(0, (sum, item) => sum + RefundJobMapper.quantityOf(item));
}

class RefundJobPlan {
  const RefundJobPlan({required this.jobs, required this.itemsBySourceId, required this.skipped});

  final List<CabinOperationDrawerJob> jobs;

  /// target.sourceId → o target'ta kaydedilecek kalemler.
  final Map<int, List<RefundableItem>> itemsBySourceId;

  /// Fiziksel çekmecesi çözülemeyen kalemler — sessizce atılmaz.
  final List<RefundableItem> skipped;
}

abstract final class RefundJobMapper {
  /// Kalemin iade miktarı — CompleteRefundParams'a giden değerle aynı.
  static double quantityOf(RefundableItem item) => (item.returnQuantity ?? item.appliedQuantity).toDouble();

  static RefundJobPlan build(List<RefundableItem> items, {List<int> cabinOrder = const []}) {
    final groups = _groupByUnit(items);

    final result = CabinOperationQueueBuilder.build<RefundUnitGroup>(
      items: groups,
      assignmentOf: (g) => g.assignment,
      targetOf: _targetOf,
      isReturnDrawerOf: (g) => g.isReturnDrawer,
      cabinOrder: cabinOrder,
    );

    final skippedIds = {for (final g in result.skipped) g.sourceId};

    return RefundJobPlan(
      jobs: result.jobs,
      itemsBySourceId: {
        for (final g in groups)
          if (!skippedIds.contains(g.sourceId)) g.sourceId: g.items,
      },
      skipped: [for (final g in result.skipped) ...g.items],
    );
  }

  static List<RefundUnitGroup> _groupByUnit(List<RefundableItem> items) {
    final byUnit = <(bool, int), List<RefundableItem>>{};

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isReturnDrawer = item.returnType == ReturnType.toDrawer;
      // Birimi çözülemeyen kalem hiçbir kalemle birleşmez — negatif index
      // gerçek bir id ile çakışmaz.
      final unitId = item.resolvedTarget?.drawerUnit?.id ?? -(i + 1);
      byUnit.putIfAbsent((isReturnDrawer, unitId), () => []).add(item);
    }

    return [
      for (final entry in byUnit.entries)
        RefundUnitGroup(items: List.unmodifiable(entry.value), isReturnDrawer: entry.key.$1),
    ];
  }

  static CabinOperationTarget _targetOf(RefundUnitGroup group, MedicineAssignment assignment) {
    final base = CabinOperationTarget.fromAssignment(
      assignment,
      CabinOperationMode.refund,
      countType: CountType.noCount,
      sourceId: group.sourceId,
    );

    if (base.isKubik) return base.withCubicSecondary(group.totalQuantity);
    if (base.numberOfSteps == 0) return base;

    // İade çekmecesinde kaynak stoğun gözü anlamsız (kalem başka bir
    // çekmeceden geliyor) — toplam ilk göze yazılır, çekmece tam açılır.
    if (group.isReturnDrawer) return base.withStepSecondary(0, group.totalQuantity);

    // Birim doz, kaynağına iade: her kalem kendi stoğunun gözüne.
    final byStep = <int, double>{};
    var hasUnplaced = false;

    for (final item in group.items) {
      final stepNo = item.source.stock?.corpartmentNo;
      if (stepNo == null || stepNo < 1 || stepNo > base.numberOfSteps) {
        hasUnplaced = true;
        continue;
      }
      byStep[stepNo - 1] = (byStep[stepNo - 1] ?? 0) + quantityOf(item);
    }

    var target = base;
    for (final MapEntry(key: index, value: quantity) in byStep.entries) {
      target = target.withStepSecondary(index, quantity);
    }

    // Gözü çözülemeyen kalem varsa kısıtlama yok — çekmece tam açılır ki
    // kullanıcı kalemi yerine koyabilsin.
    if (hasUnplaced || byStep.isEmpty) return target;

    final deepest = byStep.keys.reduce((a, b) => a > b ? a : b);
    return target.withIntakePlan(activeSteps: byStep.keys.toSet(), openUntilStep: deepest + 1);
  }
}
