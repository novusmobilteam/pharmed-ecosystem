part of 'dashboard_screen.dart';

class CabinView extends StatelessWidget {
  const CabinView({
    super.key,
    required this.isStale,
    required this.canProceed,
    required this.notifier,
    required this.cabin,
  });

  // final CabinSummary cabin;
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
          _SectionHeader(
            title: 'KABİN DURUMU',
            dotColor: MedColors.blue,
            // badge: MedBadge(
            //   label: cabin.isLocked ? 'Kilitli' : 'Açık',
            //   variant: cabin.isLocked ? MedBadgeVariant.green : MedBadgeVariant.amber,
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CabinVisualizer(powerStatus: LedStatus.on, alertStatus: LedStatus.on, slots: cabin.slots, cabinId: ''),
                const SizedBox(height: 12),
                // Kabin durum satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kabin Durumu',
                      style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w500),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    //   decoration: BoxDecoration(
                    //     color: cabin.isLocked ? MedColors.greenLight : MedColors.amberLight,
                    //     border: Border.all(color: cabin.isLocked ? const Color(0xFFB5DDD4) : const Color(0xFFF5D79E)),
                    //     borderRadius: MedRadius.xlAll,
                    //   ),
                    // child: Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Icon(
                    //       cabin.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    //       size: 9,
                    //       color: cabin.isLocked ? MedColors.green : MedColors.amber,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       cabin.isLocked ? 'Kilitli' : 'Açık',
                    //       style: TextStyle(
                    //         fontFamily: MedFonts.mono,
                    //         fontSize: 9,
                    //         color: cabin.isLocked ? MedColors.green : MedColors.amber,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // ),
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
  const _SectionHeader({required this.title, required this.dotColor, this.badge});

  final String title;
  final Color dotColor;
  final Widget? badge;

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
          if (badge != null) ...[const Spacer(), badge!],
        ],
      ),
    );
  }
}
