part of 'dashboard_screen.dart';

/// Kabin görselleştirmesi + bağlantı durumu.
///
/// Bağlantı durumu panel başlığında rozet olarak yaşar; hata varsa
/// gövdeye "yeniden bağlan" butonu düşer.
class CabinView extends StatelessWidget {
  const CabinView({super.key, required this.cabin, required this.notifier});

  final CabinVisualizerData cabin;
  final DashboardNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final conn = ref.watch(cabinConnectionProvider);
        final tone = _ConnectionTone.of(conn.status);
        final isError = conn.status == CabinConnectionStatus.error;

        return Container(
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: isError ? MedColors.red : MedColors.border, width: isError ? 1.5 : 1),
            borderRadius: MedRadius.lgAll,
            boxShadow: MedShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelHeader(
                title: context.l10n.dashboard_cabinStatusHeader,
                leading: _ConnectionIndicator(status: conn.status, color: tone.color),
                trailing: Text(
                  tone.label(context),
                  style: MedTextStyles.bodySm(color: tone.color, weight: FontWeight.w500),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(MedSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CabinSummaryView(slots: cabin.slots, cabinId: ''),

                    if (isError) ...[
                      const SizedBox(height: MedSpacing.lg),
                      _ReconnectButton(onTap: () => ref.read(cabinConnectionProvider.notifier).reconnect()),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bağlanıyor durumunda spinner, diğerlerinde durum noktası.
class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator({required this.status, required this.color});

  final CabinConnectionStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (status == CabinConnectionStatus.connecting) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
      );
    }
    return StatusDot(color: color, size: 8);
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
          height: MedSpacing.touchTarget,
          decoration: BoxDecoration(color: MedColors.red, borderRadius: MedRadius.mdAll, boxShadow: MedShadows.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.arrowClockwise(), size: 16, color: Colors.white),
              const SizedBox(width: MedSpacing.sm),
              Text(
                context.l10n.dashboard_cabinConnection_reconnectButton,
                style: MedTextStyles.bodyMd(color: Colors.white, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bağlantı durumu → renk + etiket.
enum _ConnectionTone {
  connected(MedColors.green),
  connecting(MedColors.amber),
  error(MedColors.red),
  disconnected(MedColors.text3);

  const _ConnectionTone(this.color);

  final Color color;

  static _ConnectionTone of(CabinConnectionStatus status) => switch (status) {
    CabinConnectionStatus.connected => _ConnectionTone.connected,
    CabinConnectionStatus.connecting => _ConnectionTone.connecting,
    CabinConnectionStatus.error => _ConnectionTone.error,
    CabinConnectionStatus.disconnected => _ConnectionTone.disconnected,
  };

  String label(BuildContext context) => switch (this) {
    _ConnectionTone.connected => context.l10n.dashboard_cabinConnectionStatus_connected,
    _ConnectionTone.connecting => context.l10n.dashboard_cabinConnectionStatus_connecting,
    _ConnectionTone.error => context.l10n.dashboard_cabinConnectionStatus_error,
    _ConnectionTone.disconnected => context.l10n.dashboard_cabinConnectionStatus_disconnected,
  };
}
