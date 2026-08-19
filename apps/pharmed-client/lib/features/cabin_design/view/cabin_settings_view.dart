part of 'cabin_design_dialog.dart';

class CabinSettingsView extends StatelessWidget {
  const CabinSettingsView({super.key, this.ready, required this.notifier});

  final CabinDesignReady? ready;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (ready == null) return SizedBox.shrink();
    final errorText = ready?.error?.userMessage;

    return Container(
      padding: MedSpacing.insetXl * 2,
      alignment: Alignment.topCenter,
      color: MedColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ready?.selectedGroup?.isSerum != true) ...[_BasicSettingsPanel(notifier: notifier, ready: ready!)],
          switch (ready?.selectedGroup) {
            null => Text(context.l10n.cabinDesign_noSelectionHint, style: MedTextStyles.bodySm(color: MedColors.text4)),
            final g when g.isSerum => _SerumManualLayoutPanel(group: g),
            final g => _DrawerDetailPanel(group: g, ready: ready!, cabin: ready!.cabin, notifier: notifier),
          },
          Spacer(),

          if (errorText != null) ...[
            Text(
              errorText,
              style: MedTextStyles.bodyMd(color: MedColors.red, weight: FontWeight.bold),
            ),
            const SizedBox(height: MedSpacing.md),
          ],

          if (ready!.hasPendingConnectionChange && ready?.selectedGroup?.isSerum != true) ...[
            GestureDetector(
              onTap: ready!.isScanning ? null : notifier.rescanCabin,
              child: Row(
                spacing: 8.0,
                children: [
                  ready!.isScanning
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(PhosphorIcons.arrowsClockwise(), size: 16, color: MedColors.blue),
                  Text(
                    context.l10n.cabinDesign_basicSettings_rescanButton,
                    style: MedTextStyles.titleSm(color: MedColors.blue),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
