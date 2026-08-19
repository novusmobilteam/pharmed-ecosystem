part of 'cabin_design_dialog.dart';

class _NewCabinPanel extends StatelessWidget {
  const _NewCabinPanel({required this.creating, required this.notifier});

  final CabinDesignCreating creating;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final errorText = creating.error?.userMessage;

    return Container(
      padding: EdgeInsets.symmetric(vertical: MedSpacing.insetXl.top * 2, horizontal: MedSpacing.insetXl.left * 6),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.cabinDesign_cabinList_addCabinButton, style: MedTextStyles.titleMd()),
          MedTextInputField(
            onChanged: (value) => notifier.updateNewCabinName(value),
            label: context.l10n.cabinDesign_basicSettings_nameLabel,
          ),
          Text(
            'Kabin Tipi',
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: [
              for (final type in CabinType.creatableTypes)
                _CabinTypeContainer(
                  type: type,
                  isSelected: type == creating.selectedType,
                  onTap: () => notifier.selectNewCabinType(type),
                ),
            ],
          ),
          Text(
            context.l10n.cabinDesign_newCabin_addressLabel,
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          if (creating.availableAddressChars.isEmpty)
            Text(
              context.l10n.cabinDesign_newCabin_noAddressAvailableWarning,
              style: MedTextStyles.bodySm(color: MedColors.red),
            )
          else
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: [
                for (final address in creating.availableAddressChars)
                  _CabinAddressContainer(
                    address: address,
                    isSelected: address == creating.selectedAddressChar,
                    onTap: () => notifier.selectNewCabinAddress(address),
                  ),
              ],
            ),

          if (errorText != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded, size: 14, color: MedColors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(errorText, style: MedTextStyles.bodySm(color: MedColors.red)),
                ),
              ],
            ),
          const SizedBox(height: MedSpacing.sm),
          MedButton(
            label: context.l10n.cabinDesign_newCabin_saveAndScanButton,
            prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
            isLoading: creating.isSaving,
            onPressed: creating.canSave ? notifier.saveNewCabin : null,
          ),
        ],
      ),
    );
  }
}

class _CabinTypeContainer extends StatelessWidget {
  const _CabinTypeContainer({required this.type, required this.isSelected, required this.onTap});

  final CabinType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : null,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Text(type.label, style: MedTextStyles.bodyMd()),
      ),
    );
  }
}

class _CabinAddressContainer extends StatelessWidget {
  const _CabinAddressContainer({required this.address, required this.isSelected, required this.onTap});

  final String address;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : null,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Text(address, style: MedTextStyles.bodyMd()),
      ),
    );
  }
}
