import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillListJobMapper {
  static int? _physicalDrawerId(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;

  static ({List<CabinOperationDrawerJob> jobs, List<RefillListDetail> skipped}) build({
    required List<RefillListDetail> rows,
    required CabinOperationTargetConfig config,
  }) {
    final Map<int, List<RefillListDetail>> grouped = {};
    final skipped = <RefillListDetail>[];

    for (final row in rows) {
      final assignment = row.toCompatibleQuantity();
      final physicalId = _physicalDrawerId(assignment);
      if (physicalId == null) {
        skipped.add(row);
        continue;
      }
      grouped.putIfAbsent(physicalId, () => []).add(row);
    }

    final jobs = <CabinOperationDrawerJob>[];
    grouped.forEach((physicalId, rowsInDrawer) {
      rowsInDrawer.sort(_compareByCellPosition);

      final targets = rowsInDrawer
          .map(
            (row) => CabinOperationTarget.fromAssignment(
              row.toCompatibleQuantity(),
              config,
              plannedQuantity: row.quantity?.toDouble(),
              refillListDetailId: row.id,
            ),
          )
          .toList();

      final representative = rowsInDrawer.first.toCompatibleQuantity();
      jobs.add(
        CabinOperationDrawerJob(
          cabinDrawerId: physicalId,
          representativeAssignment: representative,
          targets: targets,
          cabinId: representative.drawerUnit?.drawerSlot?.cabinId,
        ),
      );
    });

    jobs.sort((a, b) => _compareByDrawerPosition(a.representativeAssignment, b.representativeAssignment));
    return (jobs: jobs, skipped: skipped);
  }

  static int _compareByDrawerPosition(MedicineAssignment a, MedicineAssignment b) {
    final orderA = a.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(a) ?? 0;
    final orderB = b.drawerUnit?.drawerSlot?.orderNumber ?? _physicalDrawerId(b) ?? 0;
    return orderA.compareTo(orderB);
  }

  static int _compareByCellPosition(RefillListDetail a, RefillListDetail b) {
    final ua = a.cabinAssignment?.drawerUnit;
    final ub = b.cabinAssignment?.drawerUnit;
    final byOrder = (ua?.orderNo ?? 0).compareTo(ub?.orderNo ?? 0);
    if (byOrder != 0) return byOrder;
    return (ua?.compartmentNo ?? ua?.id ?? 0).compareTo(ub?.compartmentNo ?? ub?.id ?? 0);
  }
}
