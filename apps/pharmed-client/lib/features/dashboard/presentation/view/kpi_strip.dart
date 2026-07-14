part of 'dashboard_screen.dart';

/// KPI şeridi — dashboard'un en alt bandı.
///
/// Servis henüz yok; [DashboardData.kpi] null olduğu sürece bu widget
/// hiç inşa edilmez ([_DashboardBody] içinde `hasKpi` kontrolü var).
///
/// Bilinçli olarak düşük vurgulu: bordersuz, gölgesiz, surface2 zeminli.
/// Ekranın ağırlık merkezi tedaviler ve telemetri panelleri.
class KpiStrip extends StatelessWidget {
  const KpiStrip({super.key, required this.kpi});

  final KpiData kpi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: PhosphorIcons.users(),
            label: context.l10n.dashboard_kpiActivePatients,
            value: kpi.activePatients,
            change: kpi.activePatientsChange,
            progress: kpi.activePatientsProgress,
            accent: MedColors.blue,
          ),
        ),
        const SizedBox(width: MedSpacing.lg),
        Expanded(
          child: _KpiCard(
            icon: PhosphorIcons.checkCircle(),
            label: context.l10n.dashboard_kpiCompletedOperationsLabel,
            value: kpi.completedOperations,
            change: kpi.completedOperationsChange,
            progress: kpi.completedOperationsProgress,
            accent: MedColors.green,
          ),
        ),
        const SizedBox(width: MedSpacing.lg),
        Expanded(
          child: _KpiCard(
            icon: PhosphorIcons.prescription(),
            label: context.l10n.dashboard_kpiPendingPrescriptions,
            value: kpi.pendingPrescriptions,
            progress: kpi.pendingPrescriptionsProgress,
            accent: MedColors.amber,
          ),
        ),
        const SizedBox(width: MedSpacing.lg),
        Expanded(
          child: _KpiCard(
            icon: PhosphorIcons.warningOctagon(),
            label: context.l10n.dashboard_kpiCriticalAlerts,
            value: kpi.criticalAlerts,
            change: kpi.criticalAlertsChange,
            progress: kpi.criticalAlertsProgress,
            accent: MedColors.red,

            // Kritik uyarıda artış kötüdür — yeşil/kırmızı yorumu ters çevir
            higherIsWorse: true,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.accent,
    this.change,
    this.higherIsWorse = false,
  });

  final IconData icon;
  final String label;
  final int value;

  /// Bir önceki döneme göre fark. Null → değişim gösterilmez.
  final int? change;

  /// 0–1 arası doluluk. Alt çubuk olarak çizilir.
  final double progress;

  final Color accent;

  /// true ise artış kırmızı, azalış yeşil (ör. kritik uyarı sayısı).
  final bool higherIsWorse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: MedColors.text3),
              const SizedBox(width: MedSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: MedSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$value', style: MedTextStyles.numericLg(color: MedColors.text)),
              if (change != null && change != 0) ...[
                const SizedBox(width: MedSpacing.sm),
                _ChangeIndicator(change: change!, higherIsWorse: higherIsWorse),
              ],
            ],
          ),
          const SizedBox(height: MedSpacing.md),

          ClipRRect(
            borderRadius: MedRadius.smAll,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: MedColors.surface3,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeIndicator extends StatelessWidget {
  const _ChangeIndicator({required this.change, required this.higherIsWorse});

  final int change;
  final bool higherIsWorse;

  @override
  Widget build(BuildContext context) {
    final isUp = change > 0;
    final isGood = higherIsWorse ? !isUp : isUp;
    final color = isGood ? MedColors.green : MedColors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? PhosphorIcons.arrowUp() : PhosphorIcons.arrowDown(), size: 12, color: color),
        const SizedBox(width: 1),
        Text('${change.abs()}', style: MedTextStyles.monoSm(color: color)),
      ],
    );
  }
}
