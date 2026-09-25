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
  /// [items]'ı fiziksel çekmeceye göre job'lara böler ve sıralar: önce kabin
  /// ([cabinOrder] sırasıyla), sonra kabin içi çekmece sırası, sonra göz.
  /// Çekmecesi çözülemeyen öğeler [skipped]'da döner, sessizce atılmaz.
  static ({List<CabinOperationDrawerJob> jobs, List<T> skipped}) build<T>({
    required List<T> items,
    required MedicineAssignment Function(T item) assignmentOf,
    required CabinOperationTarget Function(T item, MedicineAssignment assignment) targetOf,
    List<int> cabinOrder = const [],
  }) {
    final grouped = <int, List<(T, MedicineAssignment)>>{};
    final skipped = <T>[];

    for (final item in items) {
      final assignment = assignmentOf(item);
      final physicalId = assignment.drawerUnit?.drawerSlot?.id ?? assignment.drawerUnit?.drawerSlotId;
      if (physicalId == null) {
        skipped.add(item);
        continue;
      }
      grouped.putIfAbsent(physicalId, () => []).add((item, assignment));
    }

    final jobs = [
      for (final MapEntry(key: physicalId, value: pairs) in grouped.entries)
        () {
          pairs.sort((a, b) => _compareByCell(a.$2, b.$2));
          final first = pairs.first.$2;
          return CabinOperationDrawerJob(
            cabinDrawerId: physicalId,
            representativeAssignment: first,
            cabinId: first.drawerUnit?.drawerSlot?.cabinId,
            targets: [for (final (item, assignment) in pairs) targetOf(item, assignment)],
          );
        }(),
    ]..sort((a, b) => _compareJobs(a, b, cabinOrder));

    return (jobs: jobs, skipped: skipped);
  }

  static int _compareJobs(CabinOperationDrawerJob a, CabinOperationDrawerJob b, List<int> cabinOrder) {
    int rank(int? cabinId) {
      if (cabinId == null) return 1 << 30;
      final i = cabinOrder.indexOf(cabinId);
      return i >= 0 ? i : cabinOrder.length + cabinId;
    }

    final byCabin = rank(a.cabinId).compareTo(rank(b.cabinId));
    if (byCabin != 0) return byCabin;

    // Sırası bilinmeyen çekmece sona — DB id'sinin fiziksel anlamı yok.
    final orderA = a.representativeAssignment.drawerUnit?.drawerSlot?.orderNumber;
    final orderB = b.representativeAssignment.drawerUnit?.drawerSlot?.orderNumber;
    if (orderA == null && orderB == null) return 0;
    if (orderA == null) return 1;
    if (orderB == null) return -1;
    return orderA.compareTo(orderB);
  }

  static int _compareByCell(MedicineAssignment a, MedicineAssignment b) {
    final byOrder = (a.drawerUnit?.orderNo ?? 0).compareTo(b.drawerUnit?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (a.drawerUnit?.compartmentNo ?? 0).compareTo(b.drawerUnit?.compartmentNo ?? 0);
  }
}
