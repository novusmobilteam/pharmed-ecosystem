// [SWREQ-CLI-MREFILL-012] [IEC 62304 §5.5]
// Seçilen dolum hedeflerini fiziksel çekmece bazında gruplayıp sıralı kuyruk
// üretir.
//
// Gruplama: DrawerSlot.id (fiziksel çekmece). Aynı çekmecedeki tüm gözler —
// hangi ilaca ait olursa olsun — tek RefillDrawerJob altında toplanır.
//
// Sıralama: fiziksel konuma göre üstten alta (DrawerSlot.orderNumber). Bu, en az
// çekmece açılışı ve ergonomik akış (yukarıdan aşağı) sağlar.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillQueueBuilder {
  /// [selectedAssignments] içindeki her atama bir göz hedefidir. Bunları
  /// fiziksel çekmece bazında gruplayıp sıralı kuyruk döndürür.
  ///
  /// Her hedef RefillFillTarget.fromAssignment ile (mevcut stoktan) init edilir.
  static List<RefillDrawerJob> build(List<MedicineAssignment> selectedAssignments) {
    // 1. Fiziksel çekmece bazında grupla.
    final Map<int, List<MedicineAssignment>> grouped = {};
    for (final a in selectedAssignments) {
      final physicalId = _physicalDrawerId(a);
      if (physicalId == null) continue;
      grouped.putIfAbsent(physicalId, () => []).add(a);
    }

    // 2. Her grubu job'a çevir.
    final jobs = <RefillDrawerJob>[];
    grouped.forEach((physicalId, assignments) {
      // Çekmece içindeki gözleri de konuma göre sırala.
      assignments.sort(_compareByCellPosition);

      final targets = assignments.map(RefillFillTarget.fromAssignment).toList();

      jobs.add(
        RefillDrawerJob(cabinDrawerId: physicalId, representativeAssignment: assignments.first, targets: targets),
      );
    });

    // 3. Job'ları fiziksel çekmece konumuna göre sırala (üstten alta).
    jobs.sort((a, b) => _compareByDrawerPosition(a.representativeAssignment, b.representativeAssignment));

    return jobs;
  }

  // ── Private ──────────────────────────────────────────────────────────────

  /// Fiziksel çekmece id'si = DrawerSlot.id (JSON: cabinDrawr.cabinDesign.id).
  /// drawerSlotId API'den null gelir (nested cabinDesign var, düz id yok),
  /// bu yüzden drawerSlot.id okunur.
  static int? _physicalDrawerId(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;

  /// Çekmece konumu: DrawerSlot.orderNumber (kabin içi dikey sıra, üstten alta).
  static int _compareByDrawerPosition(MedicineAssignment a, MedicineAssignment b) {
    final orderA = a.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(a) ?? 0;
    final orderB = b.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(b) ?? 0;
    return orderA.compareTo(orderB);
  }

  /// Çekmece içi göz konumu — kübikte göz sırası (orderNo → compartmentNo).
  static int _compareByCellPosition(MedicineAssignment a, MedicineAssignment b) {
    final ua = a.drawerUnit;
    final ub = b.drawerUnit;
    final byOrder = (ua?.orderNo ?? 0).compareTo(ub?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (ua?.compartmentNo ?? ua?.id ?? 0).compareTo(ub?.compartmentNo ?? ub?.id ?? 0);
  }
}
