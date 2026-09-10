part of 'cabin_design_dialog.dart';

class CabinSettingsView extends StatelessWidget {
  const CabinSettingsView({super.key, required this.notifier});

  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl * 2,
      alignment: Alignment.topCenter,
      color: MedColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notifier.selectedGroup?.isSerum != true) ...[BasicSettingsView(notifier: notifier)],
          switch (notifier.selectedGroup) {
            null => Text(context.l10n.cabinDesign_noSelectionHint, style: MedTextStyles.bodySm(color: MedColors.text4)),
            final g when g.isSerum => _SerumManualLayoutPanel(group: g),
            final g => _DrawerDetailPanel(group: g, cabin: notifier.selectedCabin, notifier: notifier),
          },
        ],
      ),
    );
  }
}
