part of 'cabin_design_dialog.dart';

class _NewCabinPanel extends StatelessWidget {
  const _NewCabinPanel({required this.draft, required this.notifier});

  final NewCabinDraft draft;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final errorText = notifier.newCabinError;
    final addresses = notifier.availableAddressCharsForNew;

    return Container(
      padding: EdgeInsets.symmetric(vertical: MedSpacing.insetXl.top * 2, horizontal: MedSpacing.insetXl.left * 6),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.cabinDesign_cabinList_addCabinButton, style: MedTextStyles.titleMd()),
          MedTextInputField(
            onChanged: notifier.updateNewCabinName,
            label: context.l10n.cabinDesign_basicSettings_nameLabel,
          ),
          Text(
            context.l10n.cabinDesign_newCabin_typeLabel,
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              for (final type in CabinType.creatableTypes)
                _CabinTypeContainer(
                  type: type,
                  isSelected: type == draft.type,
                  onTap: () => notifier.selectNewCabinType(type),
                ),
            ],
          ),
          Text(
            context.l10n.cabinDesign_newCabin_addressLabel,
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          if (addresses.isEmpty)
            Text(
              context.l10n.cabinDesign_newCabin_noAddressAvailableWarning,
              style: MedTextStyles.bodySm(color: MedColors.red),
            )
          else
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                for (final address in addresses)
                  _CabinAddressContainer(
                    address: address,
                    isSelected: address == draft.addressChar,
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
          Row(
            children: [
              TextButton(
                onPressed: draft.isSaving ? null : notifier.cancelAddCabin,
                child: Text(context.l10n.common_cancelButton),
              ),
              const SizedBox(width: MedSpacing.sm),
              MedButton(
                label: context.l10n.cabinDesign_newCabin_saveAndScanButton,
                prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
                isLoading: draft.isSaving,
                onPressed: notifier.canSaveNewCabin ? notifier.saveNewCabin : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mevcut kabinin bilgilerini düzenleme formu — yeni kabin formuyla aynı
/// düzen, mevcut bilgilerle dolu. Master'ın adresi (A) ve ek kabinlerin COM
/// portu salt okunur; adres / port / tip değişikliği kayıttan önce yeni
/// bağlantıda taranarak doğrulanır.
class _EditCabinPanel extends StatelessWidget {
  const _EditCabinPanel({required this.form, required this.notifier});

  final EditCabinForm form;
  final CabinDesignNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errorText = notifier.inlineError;
    final saving = notifier.isSaving;
    final labelStyle = MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600);

    // Mevcut adres seçilebilir listede yoksa da (ör. çakışan kayıt) gösterilsin.
    final addresses = {
      ...notifier.availableAddressCharsForEdit,
      ?form.addressChar,
    }.toList()..sort();
    final types = form.isMaster ? [?form.type] : CabinType.creatableTypes;
    final ports = {...SerialPort.availablePorts, ?form.comPortLabel}.toList()..sort();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: MedSpacing.insetXl.top * 2, horizontal: MedSpacing.insetXl.left * 6),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cabinDesign_editCabin_title, style: MedTextStyles.titleMd()),
          MedTextInputField(
            key: ValueKey('edit-name-${form.cabinId}'),
            initialValue: form.name,
            enabled: !saving,
            onChanged: notifier.updateEditCabinName,
            label: l10n.cabinDesign_basicSettings_nameLabel,
          ),
          Text(l10n.cabinDesign_newCabin_typeLabel, style: labelStyle),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              for (final type in types)
                _CabinTypeContainer(
                  type: type,
                  isSelected: type == form.type,
                  onTap: form.isMaster || saving ? null : () => notifier.selectEditCabinType(type),
                ),
            ],
          ),
          Text(l10n.cabinDesign_newCabin_addressLabel, style: labelStyle),
          if (form.isMaster) ...[
            _CabinAddressContainer(address: 'A', isSelected: true, onTap: null),
            Text(l10n.cabinDesign_editCabin_addressLockedHint, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ] else
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                for (final address in addresses)
                  _CabinAddressContainer(
                    address: address,
                    isSelected: address == form.addressChar,
                    onTap: saving ? null : () => notifier.selectEditCabinAddress(address),
                  ),
              ],
            ),
          SizedBox(
            width: 320,
            child: form.isMaster
                ? MedDropdownInputField<String>(
                    key: ValueKey('edit-port-${form.cabinId}'),
                    initialValue: form.comPortLabel,
                    enabled: !saving,
                    label: l10n.cabinDesign_basicSettings_comPortLabel,
                    options: ports,
                    labelBuilder: (port) => port,
                    onChanged: (port) {
                      if (port != null) notifier.selectEditCabinComPort(port);
                    },
                  )
                : MedTextInputField(
                    key: ValueKey('edit-port-ro-${form.cabinId}'),
                    initialValue: form.comPortLabel ?? '—',
                    enabled: false,
                    readOnly: true,
                    onChanged: (_) {},
                    label: l10n.cabinDesign_basicSettings_comPortLabel,
                  ),
          ),
          if (!form.isMaster)
            Text(l10n.cabinDesign_editCabin_comPortLockedHint, style: MedTextStyles.bodySm(color: MedColors.text3)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: MedColors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.cabinDesign_editCabin_verifyInfo, style: MedTextStyles.bodySm(color: MedColors.text2)),
              ),
            ],
          ),
          if (errorText != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline_rounded, size: 14, color: MedColors.red),
                const SizedBox(width: 6),
                Expanded(child: Text(errorText, style: MedTextStyles.bodySm(color: MedColors.red))),
              ],
            ),
          const SizedBox(height: MedSpacing.sm),
          Row(
            children: [
              TextButton(
                onPressed: saving ? null : notifier.cancelEditCabin,
                child: Text(l10n.common_cancelButton),
              ),
              const SizedBox(width: MedSpacing.sm),
              MedButton(
                label: l10n.cabinDesign_newCabin_saveAndScanButton,
                prefixIcon: Icon(PhosphorIcons.arrowsClockwise()),
                isLoading: saving,
                onPressed: notifier.canSaveEditCabin ? notifier.saveEditCabin : null,
              ),
            ],
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

  /// null: salt okunur (düzenlemede değiştirilemeyen alan).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : (onTap == null ? MedColors.surface2 : null),
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Text(type.label, style: MedTextStyles.bodyMd(color: onTap == null && !isSelected ? MedColors.text4 : null)),
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
