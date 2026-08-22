// [SWREQ-CORE-CABINOP-004] [IEC 62304 §5.5]
//
// Seçilen hedefleri fiziksel çekmece bazında gruplayıp sıralı bir kuyruk
// üretir. Gruplama birimi GÖZ değil, FİZİKSEL ÇEKMECEDİR (DrawerSlot.id) —
// aynı çekmecedeki tüm gözler, hangi ilaca ait olursa olsun, tek job altında
// toplanır (en az çekmece açılışı garantisi). Job'lar fiziksel konuma göre
// üstten alta sıralanır.
//
// [skipped]: fiziksel çekmece kimliği (drawerSlot.id / drawerSlotId) hiç
// çözülemeyen atamalar — eksik/bozuk ilişkisel veri anlamına gelir. Bunlar
// SESSİZCE atılmaz, çağırana bildirilir; aksi halde kullanıcı bir ilacı
// "seçtim" sanıp aslında hiç kuyruğa girmediğini fark edemez.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract final class CabinOperationQueueBuilder {
  static int? _cabinId(MedicineAssignment? a) => a?.drawerUnit?.drawerSlot?.cabinId;

  static ({List<CabinOperationDrawerJob> jobs, List<MedicineAssignment> skipped}) build({
    required List<MedicineAssignment> selectedAssignments,
    required CabinOperationTargetConfig config,
  }) {
    final Map<int, List<MedicineAssignment>> grouped = {};
    final skipped = <MedicineAssignment>[];

    for (final a in selectedAssignments) {
      final physicalId = _physicalDrawerId(a);
      if (physicalId == null) {
        skipped.add(a);
        continue;
      }
      grouped.putIfAbsent(physicalId, () => []).add(a);
    }

    final jobs = <CabinOperationDrawerJob>[];
    grouped.forEach((physicalId, assignments) {
      assignments.sort(_compareByCellPosition);
      final targets = assignments.map((a) => CabinOperationTarget.fromAssignment(a, config)).toList();
      jobs.add(
        CabinOperationDrawerJob(
          cabinDrawerId: physicalId,
          representativeAssignment: assignments.first,
          targets: targets,
          cabinId: _cabinId(assignments.first),
        ),
      );
    });

    jobs.sort((a, b) => _compareByDrawerPosition(a.representativeAssignment, b.representativeAssignment));
    return (jobs: jobs, skipped: skipped);
  }

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
