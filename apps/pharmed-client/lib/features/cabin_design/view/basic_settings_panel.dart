part of 'cabin_design_dialog.dart';

class _BasicSettingsPanel extends StatelessWidget {
  const _BasicSettingsPanel({required this.ready, required this.notifier});

  final CabinDesignReady ready;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cabin = ready.cabin;
    final isMaster = cabin.type == CabinType.master;
    final errorText = ready.error?.userMessage;

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
            if (ready.hasPendingConnectionChange && ready.selectedGroup?.isSerum != true) ...[
              MedButton(
                label: context.l10n.cabinDesign_basicSettings_rescanButton,
                onPressed: ready.isScanning ? null : notifier.rescanCabin,
                isLoading: ready.isScanning,
                size: MedButtonSize.sm,
                variant: MedButtonVariant.secondary,
              ),
              SizedBox(width: 4.0),
            ],
            if (!isMaster)
              MedButton(
                label: ready.cabin.status == Status.passive
                    ? context.l10n.cabinDesign_basicSettings_activateButton
                    : context.l10n.cabinDesign_basicSettings_deactivateButton,
                onPressed: ready.isTogglingStatus ? null : notifier.toggleCabinActiveStatus,
                isLoading: ready.isTogglingStatus,
                size: MedButtonSize.sm,
                variant: MedButtonVariant.ghost,
              ),
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
