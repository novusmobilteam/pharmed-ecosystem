// [SWREQ-CLI-MCENSUS-007] [IEC 62304 §5.5]
// Seçilen sayım hedeflerini fiziksel çekmece bazında gruplayıp sıralı kuyruk
// üretir — RefillQueueBuilder ile BİREBİR AYNI mantık (gruplama, sıralama).
//
// Gruplama: DrawerSlot.id (fiziksel çekmece). Aynı çekmecedeki tüm gözler —
// hangi ilaca ait olursa olsun — tek CensusDrawerJob altında toplanır.
//
// Sıralama: fiziksel konuma göre üstten alta (DrawerSlot.orderNumber).
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class CensusQueueBuilder {
  /// [selectedAssignments] içindeki her atama bir göz hedefidir. Bunları
  /// fiziksel çekmece bazında gruplayıp sıralı kuyruk döndürür.
  static List<CensusDrawerJob> build(List<MedicineAssignment> selectedAssignments) {
    final Map<int, List<MedicineAssignment>> grouped = {};
    for (final a in selectedAssignments) {
      final physicalId = _physicalDrawerId(a);
      if (physicalId == null) continue;
      grouped.putIfAbsent(physicalId, () => []).add(a);
    }

    final jobs = <CensusDrawerJob>[];
    grouped.forEach((physicalId, assignments) {
      assignments.sort(_compareByCellPosition);

      final targets = assignments.map(CensusTarget.fromAssignment).toList();

      jobs.add(
        CensusDrawerJob(cabinDrawerId: physicalId, representativeAssignment: assignments.first, targets: targets),
      );
    });

    jobs.sort((a, b) => _compareByDrawerPosition(a.representativeAssignment, b.representativeAssignment));

    return jobs;
  }

  // ── Private ──────────────────────────────────────────────────────────────

  /// Fiziksel çekmece id'si = DrawerSlot.id. drawerSlotId API'den null
  /// gelebildiği için önce drawerSlot.id, sonra drawerSlotId'ye düşülür.
  static int? _physicalDrawerId(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;

  static int _compareByDrawerPosition(MedicineAssignment a, MedicineAssignment b) {
    final orderA = a.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(a) ?? 0;
    final orderB = b.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(b) ?? 0;
    return orderA.compareTo(orderB);
  }

  static int _compareByCellPosition(MedicineAssignment a, MedicineAssignment b) {
    final ua = a.drawerUnit;
    final ub = b.drawerUnit;
    final byOrder = (ua?.orderNo ?? 0).compareTo(ub?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (ua?.compartmentNo ?? ua?.id ?? 0).compareTo(ub?.compartmentNo ?? ub?.id ?? 0);
  }
}
