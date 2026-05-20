part of 'dashboard_screen.dart';

class KpiView extends StatelessWidget {
  const KpiView({super.key, required this.kpi, required this.isStale});

  final KpiData kpi;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return KpiGrid(
      isStale: isStale,
      items: [
        KpiItem(
          label: context.l10n.dashboard_kpiActivePatients,
          value: '${kpi.activePatients}',
          accentColor: MedColors.blue,
          progressValue: kpi.activePatientsProgress,
          deltaLabel: _deltaLabel(kpi.activePatientsChange),
          deltaDirection: _deltaDir(kpi.activePatientsChange),
          icon: const Icon(Icons.people_outline_rounded, size: 16, color: MedColors.blue),
        ),
        KpiItem(
          label: context.l10n.dashboard_kpiCompletedOps,
          value: '${kpi.completedOperations}',
          accentColor: MedColors.green,
          progressValue: kpi.completedOperationsProgress,
          deltaLabel: '▲ ${kpi.completedOperationsChange}',
          deltaDirection: DeltaDirection.up,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: MedColors.green),
        ),
        KpiItem(
          label: context.l10n.dashboard_kpiPendingPrescriptions,
          value: '${kpi.pendingPrescriptions}',
          accentColor: MedColors.amber,
          progressValue: kpi.pendingPrescriptionsProgress,
          deltaLabel: _deltaLabel(kpi.pendingPrescriptions),
          deltaDirection: DeltaDirection.flat,
          icon: const Icon(Icons.receipt_outlined, size: 16, color: MedColors.amber),
        ),
        KpiItem(
          label: context.l10n.dashboard_kpiCriticalAlerts,
          value: '${kpi.criticalAlerts}',
          accentColor: MedColors.red,
          progressValue: kpi.criticalAlertsProgress,
          deltaLabel: _deltaLabel(kpi.criticalAlertsChange),
          deltaDirection: _deltaDir(kpi.criticalAlertsChange),
          icon: const Icon(Icons.warning_amber_rounded, size: 16, color: MedColors.red),
        ),
      ],
    );
  }

  String _deltaLabel(int change) {
    if (change > 0) return '▲ $change';
    if (change < 0) return '▼ ${change.abs()}';
    return '— 0';
  }

  DeltaDirection _deltaDir(int change) {
    if (change > 0) return DeltaDirection.up;
    if (change < 0) return DeltaDirection.down;
    return DeltaDirection.flat;
  }
}

// ─────────────────────────────────────────────────────────────────
// KpiGrid
// [SWREQ-UI-004] [HAZ-003]
// 4'lü KPI kart grid'i.
// isStale → MedKpiCard değerleri soluklaşır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class KpiItem {
  const KpiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.progressValue,
    this.deltaLabel,
    this.deltaDirection,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color accentColor;
  final double progressValue;
  final String? deltaLabel;
  final DeltaDirection? deltaDirection;
  final VoidCallback? onTap;
}

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.items, this.isStale = false})
    : assert(items.length == 4, 'KpiGrid her zaman 4 KpiItem alır');

  final List<KpiItem> items;

  /// [HAZ-007] true → tüm kart değerleri soluklaşır
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 170,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return MedKpiCard(
          label: item.label,
          value: item.value,
          icon: item.icon,
          accentColor: item.accentColor,
          progressValue: item.progressValue,
          deltaLabel: item.deltaLabel,
          deltaDirection: item.deltaDirection,
          isStale: isStale,
          onTap: item.onTap,
        );
      },
    );
  }
}
