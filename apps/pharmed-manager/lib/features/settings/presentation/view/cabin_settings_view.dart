part of 'settings_view.dart';

class CabinSettingsView extends StatelessWidget {
  const CabinSettingsView({super.key});

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
          label: context.l10n.settingsCabin_drawerOpenWaitLabel,
        ),
        Row(
          spacing: 10,
          children: [
            Icon(PhosphorIcons.info()),
            Expanded(
              child: Text(
                context.l10n.settingsCabin_drawerOpenWaitDescription,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
