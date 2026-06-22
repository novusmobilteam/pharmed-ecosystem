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
                _CabinConnectionStatusView(),
                const SizedBox(height: 10),
                // CabinStatsGrid(
                //   totalDrawers: cabin.totalDrawers,
                //   fullDrawers: cabin.fullDrawers,
                //   emptyDrawers: cabin.emptyDrawers,
                //   criticalCount: cabin.criticalCount,
                // ),
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

class _CabinConnectionStatusView extends StatelessWidget {
  const _CabinConnectionStatusView();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final conn = ref.watch(cabinConnectionProvider);

        final (Color color, Color bg, String label) = switch (conn.status) {
          CabinConnectionStatus.connected => (
            MedColors.green,
            MedColors.greenLight,
            context.l10n.dashboard_cabinConnectionStatus_connected,
          ),
          CabinConnectionStatus.connecting => (
            MedColors.amber,
            MedColors.amberLight,
            context.l10n.dashboard_cabinConnectionStatus_connecting,
          ),
          CabinConnectionStatus.error => (
            MedColors.red,
            MedColors.redLight,
            context.l10n.dashboard_cabinConnectionStatus_error,
          ),
          CabinConnectionStatus.disconnected => (
            MedColors.text3,
            MedColors.surface3,
            context.l10n.dashboard_cabinConnectionStatus_disconnected,
          ),
        };

        final isConnecting = conn.status == CabinConnectionStatus.connecting;
        final isError = conn.status == CabinConnectionStatus.error;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Durum rozeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg, vertical: MedSpacing.md),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: MedRadius.mdAll,
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.dashboard_cabinStatusLabel,
                    style: MedTextStyles.bodyMd(color: color, weight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bağlanıyor durumunda spinner, diğerlerinde nokta
                      if (isConnecting)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
                        )
                      else
                        StatusDot(color: color, size: 8),
                      const SizedBox(width: MedSpacing.sm),
                      Text(
                        label,
                        style: MedTextStyles.bodyMd(color: color, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hata durumunda belirgin "Yeniden Bağlan" butonu
            if (isError) ...[
              const SizedBox(height: MedSpacing.sm),
              _ReconnectButton(onTap: () => ref.read(cabinConnectionProvider.notifier).reconnect()),
            ],
          ],
        );
      },
    );
  }
}

class _ReconnectButton extends StatelessWidget {
  const _ReconnectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          height: 44, // dokunmatik hedef
          decoration: BoxDecoration(color: MedColors.red, borderRadius: MedRadius.mdAll, boxShadow: MedShadows.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              const SizedBox(width: MedSpacing.sm),
              Text(
                context.l10n.dashboard_cabinConnection_reconnectButton,
                style: MedTextStyles.bodyMd(color: Colors.white, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
