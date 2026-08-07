part of 'cabin_design_dialog.dart';

class _BasicSettingsPanel extends StatelessWidget {
  const _BasicSettingsPanel({required this.cabin});

  final Cabin cabin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.cabinDesign_basicSettings_sectionTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.lg),
        Row(
          children: [
            Expanded(
              child: MedTextInputField(
                onChanged: (_) {},
                initialValue: cabin.name,
                label: context.l10n.cabinDesign_basicSettings_nameLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.sm),
        MedDropdownInputField(
          onChanged: (_) {},
          initialValue: cabin.comPort?.label,
          label: context.l10n.cabinDesign_basicSettings_comPortLabel,
          options: SerialPort.availablePorts,
          labelBuilder: (port) => port,
        ),
      ],
    );
  }
}
