part of 'settings_view.dart';

class PrescriptionSettingsView extends StatelessWidget {
  const PrescriptionSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final options = List.generate(12, (index) => (index + 1) * 5);

    return Column(
      spacing: 10,
      children: [
        MedDropdownInputField(
          options: options,
          onChanged: (_) {},
          labelBuilder: (option) => option?.toString(),
          label: context.l10n.settingsPrescription_accessDurationLabel,
        ),
        Row(
          spacing: 10,
          children: [
            Icon(PhosphorIcons.info()),
            Expanded(
              child: Text(
                context.l10n.settingsPrescription_accessDurationDescription,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
