part of 'cabin_design_dialog.dart';

class _BasicSettingsPanel extends StatelessWidget {
  const _BasicSettingsPanel({required this.ready, required this.notifier});

  final CabinDesignReady ready;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cabin = ready.cabin;
    final isMaster = cabin.type == CabinType.master;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.cabinDesign_basicSettings_sectionTitle, style: MedTextStyles.titleSm(color: MedColors.text3)),
        const SizedBox(height: MedSpacing.lg),
        MedTextInputField(
          onChanged: (value) => notifier.updatePendingName(value),
          initialValue: cabin.name,
          label: context.l10n.cabinDesign_basicSettings_nameLabel,
        ),
        const SizedBox(height: MedSpacing.sm),
        if (isMaster) ...[
          MedDropdownInputField(
            onChanged: (value) {
              if (value != null) notifier.updatePendingComPort(value);
            },
            initialValue: ready.pendingComPort?.label ?? cabin.comPort?.label,
            label: context.l10n.cabinDesign_basicSettings_comPortLabel,
            options: SerialPort.availablePorts,
            labelBuilder: (port) => port,
          ),
        ] else ...[
          MedDropdownInputField(
            onChanged: (address) {
              if (address != null && !ready.isScanning) notifier.updatePendingAddressChar(address);
            },
            initialValue: ready.pendingAddressChar ?? cabin.no?.toUpperCase(),
            label: context.l10n.cabinDesign_newCabin_addressLabel,
            options: ready.availableAddressCharsForEdit,
            labelBuilder: (address) => address,
          ),
        ],

        const SizedBox(height: MedSpacing.xl),
      ],
    );
  }
}
