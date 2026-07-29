// refund_queue_builder.dart — master-cabin-operations §2'deki desenle birebir

import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefundQueueBuilder {
  static List<RefundDrawerJob> build(List<RefundTarget> targets) {
    final byDrawer = <int, List<RefundTarget>>{};
    for (final t in targets) {
      final id = _physicalDrawerId(t.assignment);
      byDrawer.putIfAbsent(id, () => []).add(t);
    }

    final jobs = byDrawer.entries.map((e) {
      final sorted = e.value.toList()
        ..sort((a, b) => (a.assignment.drawerUnit?.orderNo ?? 0).compareTo(b.assignment.drawerUnit?.orderNo ?? 0));
      return RefundDrawerJob(cabinDrawerId: e.key, representativeTarget: sorted.first, targets: sorted);
    }).toList();

    jobs.sort((a, b) {
      final an = a.representativeTarget.assignment.drawerUnit?.drawerSlot?.orderNumber ?? a.cabinDrawerId;
      final bn = b.representativeTarget.assignment.drawerUnit?.drawerSlot?.orderNumber ?? b.cabinDrawerId;
      return an.compareTo(bn);
    });

    return jobs;
  }

  // refill'deki fallback zinciriyle birebir — drawerSlotId API'den null gelir.
  static int _physicalDrawerId(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId ?? 0;
}
