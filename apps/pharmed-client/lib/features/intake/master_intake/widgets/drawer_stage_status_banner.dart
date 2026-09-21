import 'package:flutter/material.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_stage.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DrawerStageStatusCard extends StatelessWidget {
  const DrawerStageStatusCard({super.key, required this.stage, this.isLastJob = false});

  final MasterDrawerStage stage;
  final bool isLastJob;

  @override
  Widget build(BuildContext context) {
    final info = _info(context, stage);

    final (Color bg, Color border, Color fg, IconData icon) = switch (info.variant) {
      _CardVariant.ready => (
        MedColors.greenLight,
        MedColors.green,
        MedColors.green,
        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
      ),
      _CardVariant.error => (
        MedColors.redLight,
        MedColors.red,
        MedColors.red,
        PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
      ),
      _CardVariant.pending => (
        MedColors.blueLight,
        MedColors.blue,
        MedColors.blue,
        PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
      ),
    };

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (info.variant == _CardVariant.pending)
            const SizedBox(width: 22, height: 22, child: MedLoadingIndicator())
          else
            Icon(icon, size: 22, color: fg),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.title, style: MedTextStyles.titleMd(color: fg)),
                const SizedBox(height: 4),
                Text(info.subtitle, style: MedTextStyles.bodyMd(color: fg)),
              ],
            ),
          ),
          if (info.pillLabel != null) ...[
            const SizedBox(width: 12),
            _MonitoringPill(label: info.pillLabel!, color: fg),
          ],
        ],
      ),
    );
  }

  _StageInfo _info(BuildContext context, MasterDrawerStage stage) {
    if (stage is MasterDrawerOpened) {
      return _StageInfo(
        title: context.l10n.masterDrawer_status_openedTitle,
        subtitle: context.l10n.masterDrawer_status_openedSubtitle,
        pillLabel: context.l10n.masterDrawer_status_openedPill,
        variant: _CardVariant.ready,
      );
    }

    if (stage is MasterDrawerIdle || stage is MasterDrawerClosed) {
      return _StageInfo(
        title: isLastJob
            ? context.l10n.masterDrawer_status_completingTitle
            : context.l10n.masterDrawer_status_openingTitle,
        subtitle: isLastJob
            ? context.l10n.masterDrawer_status_completingSubtitle
            : context.l10n.masterDrawer_status_openingSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      );
    }

    return switch (stage) {
      MasterDrawerOpening(step: MasterDrawerOpeningStep.lockOpening) => _StageInfo(
        title: context.l10n.masterDrawer_status_lockOpeningTitle,
        subtitle: context.l10n.masterDrawer_status_lockOpeningSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      ),
      MasterDrawerOpening() => _StageInfo(
        title: context.l10n.masterDrawer_status_devicePreparingTitle,
        subtitle: context.l10n.masterDrawer_status_devicePreparingSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      ),
      MasterDrawerWaitingForPull() => _StageInfo(
        title: context.l10n.masterDrawer_status_waitingPullTitle,
        subtitle: context.l10n.masterDrawer_status_waitingPullSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      ),
      MasterDrawerOpeningLid() => _StageInfo(
        title: context.l10n.masterDrawer_status_openingLidTitle,
        subtitle: context.l10n.masterDrawer_status_openingLidSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      ),
      MasterDrawerWaitingForClose() => _StageInfo(
        title: context.l10n.masterDrawer_status_waitingCloseTitle,
        subtitle: context.l10n.masterDrawer_status_waitingCloseSubtitle,
        pillLabel: context.l10n.masterDrawer_status_closureMonitoredPill,
        variant: _CardVariant.pending,
      ),
      MasterDrawerFailed() => _StageInfo(
        title: context.l10n.masterDrawer_status_failedTitle,
        subtitle: context.l10n.masterDrawer_status_failedSubtitle,
        pillLabel: null,
        variant: _CardVariant.error,
      ),
      _ => _StageInfo(
        title: context.l10n.masterDrawer_status_openingTitle,
        subtitle: context.l10n.masterDrawer_status_openingSubtitle,
        pillLabel: context.l10n.masterDrawer_status_workingPill,
        variant: _CardVariant.pending,
      ),
    };
  }
}

class _StageInfo {
  const _StageInfo({required this.title, required this.subtitle, required this.pillLabel, required this.variant});
  final String title;
  final String subtitle;
  final String? pillLabel;
  final _CardVariant variant;
}

enum _CardVariant { pending, ready, error }

/// Ekranın sağında, o an canlı olarak izlenen bir donanım durumunu (örn.
/// "çekmece kapanışı izleniyor") gösteren pill — yanıp sönen bir nokta ile
/// "aktif izleme sürüyor" hissini verir.
class _MonitoringPill extends StatefulWidget {
  const _MonitoringPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  State<_MonitoringPill> createState() => _MonitoringPillState();
}

class _MonitoringPillState extends State<_MonitoringPill> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.xl3All,
        border: Border.all(color: widget.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _controller,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Text(widget.label, style: MedTextStyles.bodySm(color: widget.color)),
        ],
      ),
    );
  }
}
