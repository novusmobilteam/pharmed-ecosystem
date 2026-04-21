part of 'dashboard_screen.dart';

class CabinView extends StatelessWidget {
  const CabinView({
    super.key,
    required this.isStale,
    required this.canProceed,
    required this.notifier,
    required this.cabin,
  });

  final bool isStale;
  final bool canProceed;
  final DashboardNotifier notifier;
  final CabinVisualizerData cabin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _SectionHeader(title: context.l10n.dashboard_cabinStatusHeader, dotColor: MedColors.blue),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CabinSummaryView(slots: cabin.slots, cabinId: ''),
                const SizedBox(height: 12),
                // Kabin durum satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.dashboard_cabinStatusLabel,
                      style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                CabinStatsGrid(
                  totalDrawers: cabin.totalDrawers,
                  fullDrawers: cabin.fullDrawers,
                  emptyDrawers: cabin.emptyDrawers,
                  criticalCount: cabin.criticalCount,
                  isStale: cabin.isStale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.dotColor});

  final String title;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: const BorderRadius.only(topLeft: MedRadius.md, topRight: MedRadius.md),
      ),
      child: Row(
        children: [
          StatusDot(color: dotColor, size: 7),
          const SizedBox(width: 7),
          Text(title, style: MedTextStyles.titleSm()),
        ],
      ),
    );
  }
}
