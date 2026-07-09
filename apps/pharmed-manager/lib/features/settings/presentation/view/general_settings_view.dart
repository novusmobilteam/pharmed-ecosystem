part of 'settings_view.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = List.generate(12, (index) => (index + 1) * 5);
    final settings = context.watch<SettingsNotifier>();

    return Column(
      spacing: 10,
      children: [
        MedDropdownInputField(
          options: options,
          onChanged: (_) {},
          labelBuilder: (option) => option?.toString(),
          label: context.l10n.settingsGeneral_autoStandbyDurationLabel,
        ),
        MedTextInputField(
          label: context.l10n.settingsGeneral_expiryWarningLabel,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {},
        ),
        MedCheckbox(label: context.l10n.settingsGeneral_hbysStockControlLabel, value: true, onChanged: (_) {}),
        MedCheckbox(label: context.l10n.settingsGeneral_fingerprintOnlyLabel, value: false, onChanged: (_) {}),
        MedCheckbox(label: context.l10n.settingsGeneral_allowOutOfWindowOrdersLabel, value: true, onChanged: (_) {}),
        MedCheckbox(
          label: context.l10n.settingsGeneral_perCellExpiryDateLabel,
          value: settings.isPerCellMiadEnabled, // 2 ise checked
          onChanged: (_) => settings.togglePerCellMiad(),
        ),
      ],
    );
  }
}
