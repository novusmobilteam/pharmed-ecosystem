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
          label: 'Aktif Hasta',
          value: '${kpi.activePatients}',
          accentColor: MedColors.blue,
          progressValue: kpi.activePatientsProgress,
          deltaLabel: _deltaLabel(kpi.activePatientsChange),
          deltaDirection: _deltaDir(kpi.activePatientsChange),
          icon: const Icon(Icons.people_outline_rounded, size: 16, color: MedColors.blue),
        ),
        KpiItem(
          label: 'Tamamlanan İşlem',
          value: '${kpi.completedOperations}',
          accentColor: MedColors.green,
          progressValue: kpi.completedOperationsProgress,
          deltaLabel: '▲ ${kpi.completedOperationsChange}',
          deltaDirection: DeltaDirection.up,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: MedColors.green),
        ),
        KpiItem(
          label: 'Bekleyen Reçete',
          value: '${kpi.pendingPrescriptions}',
          accentColor: MedColors.amber,
          progressValue: kpi.pendingPrescriptionsProgress,
          deltaLabel: _deltaLabel(kpi.pendingPrescriptions),
          deltaDirection: DeltaDirection.flat,
          icon: const Icon(Icons.receipt_outlined, size: 16, color: MedColors.amber),
        ),
        KpiItem(
          label: 'Kritik Uyarı',
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
