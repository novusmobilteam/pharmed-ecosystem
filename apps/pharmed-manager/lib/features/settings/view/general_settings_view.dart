part of 'settings_view.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  static final List<int> _hourOptions = List.generate(48, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedDropdownInputField<int>(
          options: _hourOptions,
          initialValue: settings.getInt(SystemParameterKeys.collectOrderTime),
          labelBuilder: (option) => option == null ? null : '$option saat',
          label: context.l10n.settingsGeneral_collectOrderTimeLabel,
          onChanged: (value) {
            if (value != null) settings.setInt(SystemParameterKeys.collectOrderTime, value);
          },
        ),
        MedDropdownInputField<int>(
          options: _hourOptions,
          initialValue: settings.getInt(SystemParameterKeys.wasteDestructionTime),
          labelBuilder: (option) => option == null ? null : '$option saat',
          label: context.l10n.settingsGeneral_wasteDestructionTimeLabel,
          onChanged: (value) {
            if (value != null) settings.setInt(SystemParameterKeys.wasteDestructionTime, value);
          },
        ),
        SizedBox(height: 12),
        MedCheckbox(
          label: context.l10n.settingsGeneral_wasteOrderReactivateLabel,
          size: MedCheckboxSize.sm,
          value: settings.getBool(SystemParameterKeys.wasteOrderMayItFall),
          onChanged: (_) => settings.setBool(
            SystemParameterKeys.wasteOrderMayItFall,
            !settings.getBool(SystemParameterKeys.wasteOrderMayItFall),
          ),
        ),
        MedCheckbox(
          label: context.l10n.settingsGeneral_perCellExpiryDateLabel,
          size: MedCheckboxSize.sm,
          value: settings.isPerCellMiadEnabled,
          onChanged: (_) => settings.togglePerCellMiad(),
        ),
        MedCheckbox(
          label: context.l10n.settingsGeneral_badgeCardPasswordLabel,
          size: MedCheckboxSize.sm,
          value: settings.getBool(SystemParameterKeys.manageCard),
          onChanged: (_) =>
              settings.setBool(SystemParameterKeys.manageCard, !settings.getBool(SystemParameterKeys.manageCard)),
        ),
      ],
    );
  }
}
