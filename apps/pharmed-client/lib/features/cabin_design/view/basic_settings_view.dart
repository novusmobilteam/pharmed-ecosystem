part of 'cabin_design_dialog.dart';

class BasicSettingsView extends StatelessWidget {
  const BasicSettingsView({super.key, required this.notifier});

  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cabin = notifier.selectedCabin;
    final isMaster = cabin.type == CabinType.master;

    const rescanKey = OperationKey.custom('rescanCabin');
    const toggleStatusKey = OperationKey.custom('toggleStatus');

    final errorText = notifier.isFailed(rescanKey)
        ? notifier.message(rescanKey)
        : notifier.isFailed(toggleStatusKey)
        ? notifier.message(toggleStatusKey)
        : null;

    return Column(
      key: ValueKey(cabin.id),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              context.l10n.cabinDesign_basicSettings_sectionTitle,
              style: MedTextStyles.titleSm(color: MedColors.text3),
            ),
            Spacer(),
            if (notifier.hasPendingConnectionChange && notifier.selectedGroup?.isSerum != true) ...[
              MedButton(
                label: context.l10n.cabinDesign_basicSettings_rescanButton,
                onPressed: notifier.isScanning ? null : notifier.rescanCabin,
                isLoading: notifier.isScanning,
                size: MedButtonSize.sm,
                variant: MedButtonVariant.secondary,
              ),
              SizedBox(width: 4.0),
            ],
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: MedSpacing.md),
          Container(
            padding: MedSpacing.insetMd,
            decoration: BoxDecoration(
              color: MedColors.redLight,
              borderRadius: MedRadius.mdAll,
              border: Border.all(color: MedColors.red),
            ),
            child: Text(
              errorText,
              style: MedTextStyles.bodyMd(color: MedColors.red, weight: FontWeight.bold),
            ),
          ),
        ],

        const SizedBox(height: MedSpacing.lg),
        MedTextInputField(
          onChanged: (value) => notifier.updateCabinName(value),
          initialValue: cabin.name,
          label: context.l10n.cabinDesign_basicSettings_nameLabel,
        ),
        const SizedBox(height: MedSpacing.sm),
        if (isMaster) ...[
          MedDropdownInputField(
            onChanged: (value) {
              if (value != null) notifier.updateCabinComPort(value);
            },
            initialValue: cabin.comPort?.label,
            label: context.l10n.cabinDesign_basicSettings_comPortLabel,
            options: SerialPort.availablePorts,
            labelBuilder: (port) => port,
          ),
        ] else ...[
          MedDropdownInputField(
            onChanged: (address) {
              if (address != null && !notifier.isScanning) notifier.updateCabinAddress(address);
            },
            initialValue: cabin.no?.toUpperCase(),
            label: context.l10n.cabinDesign_newCabin_addressLabel,
            options: notifier.availableAddressCharsForEdit,
            labelBuilder: (address) => address,
          ),
        ],

        const SizedBox(height: MedSpacing.xl),
      ],
    );
  }
}
