part of 'cabin_design_dialog.dart';

class _BasicSettingsPanel extends StatelessWidget {
  const _BasicSettingsPanel({required this.notifier, required this.cabin});

  final CabinDesignNotifier notifier;
  final Cabin cabin;

  @override
  Widget build(BuildContext context) {
    final isMaster = cabin.type == CabinType.master;
    final errorText = notifier.inlineError;
    final isRescanning = notifier.isRescanning;
    final isTogglingStatus = notifier.isTogglingStatus;

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
            const Spacer(),
            // Bağlantı değişikliği varsa yeni bağlantıyı, yoksa çekmece
            // değişimini (aynı adreste tip değişimi) tarar.
            MedButton(
              label: notifier.pending.hasConnectionChange
                  ? context.l10n.cabinDesign_basicSettings_rescanButton
                  : context.l10n.cabinDesign_replace_scanButton,
              onPressed: notifier.canRescan ? notifier.rescanCabin : null,
              isLoading: isRescanning,
              size: MedButtonSize.sm,
              variant: MedButtonVariant.secondary,
            ),
            const SizedBox(width: 4.0),
            if (!isMaster)
              MedButton(
                label: cabin.status == Status.passive
                    ? context.l10n.cabinDesign_basicSettings_activateButton
                    : context.l10n.cabinDesign_basicSettings_deactivateButton,
                onPressed: isTogglingStatus ? null : notifier.toggleCabinActiveStatus,
                isLoading: isTogglingStatus,
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
        if (notifier.replacements.isNotEmpty) ...[
          const SizedBox(height: MedSpacing.md),
          _DrawerReplacementSummary(replacements: notifier.replacements),
        ] else if (notifier.scanFoundNoChange) ...[
          const SizedBox(height: MedSpacing.md),
          Text(context.l10n.cabinDesign_replace_noChangeInfo, style: MedTextStyles.bodySm(color: MedColors.text3)),
        ],
        const SizedBox(height: MedSpacing.lg),
        MedTextInputField(
          onChanged: notifier.updatePendingName,
          initialValue: cabin.name,
          label: context.l10n.cabinDesign_basicSettings_nameLabel,
        ),
        const SizedBox(height: MedSpacing.sm),
        if (isMaster)
          MedDropdownInputField(
            onChanged: (value) {
              if (value != null) notifier.updatePendingComPort(value);
            },
            initialValue: notifier.effectiveComPortLabel,
            label: context.l10n.cabinDesign_basicSettings_comPortLabel,
            options: SerialPort.availablePorts,
            labelBuilder: (port) => port,
          )
        else
          MedDropdownInputField(
            onChanged: (address) {
              if (address != null) notifier.updatePendingAddressChar(address);
            },
            initialValue: notifier.effectiveAddressChar,
            label: context.l10n.cabinDesign_newCabin_addressLabel,
            options: notifier.availableAddressCharsForEdit,
            labelBuilder: (address) => address,
          ),
        const SizedBox(height: MedSpacing.sm),
        _CabinCameraRow(notifier: notifier, cabin: cabin),
        const SizedBox(height: MedSpacing.xl),
      ],
    );
  }
}

/// "Bu kabine hangi kamera bakıyor?" — kamera tarafındaki atamanın kabin
/// tarafından görünümü. Atama kamera formundan yapılır.
class _CabinCameraRow extends StatelessWidget {
  const _CabinCameraRow({required this.notifier, required this.cabin});

  final CabinDesignNotifier notifier;
  final Cabin cabin;

  @override
  Widget build(BuildContext context) {
    final camera = notifier.cameraForCabin(cabin.id);
    return Container(
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.smAll,
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.videoCamera(),
            size: 16,
            color: camera?.enabled == true ? MedColors.blue : MedColors.text4,
          ),
          const SizedBox(width: MedSpacing.sm),
          Expanded(
            child: Text(
              camera == null
                  ? context.l10n.cabinDesign_basicSettings_cameraNone
                  : context.l10n.cabinDesign_basicSettings_cameraAssigned(camera.name),
              style: MedTextStyles.bodyMd(color: camera == null ? MedColors.text4 : MedColors.text),
            ),
          ),
          MedButton(
            label: camera == null
                ? context.l10n.cabinDesign_cameraList_addCameraButton
                : context.l10n.cabinDesign_basicSettings_cameraOpenButton,
            size: MedButtonSize.sm,
            variant: MedButtonVariant.ghost,
            onPressed: camera == null
                ? () => notifier.startAddCamera(forCabinId: cabin.id)
                : () => notifier.selectCamera(camera.id),
          ),
        ],
      ),
    );
  }
}

/// Çekmece değişimi taramasının sonucu: aynı adreste tipi değişen çekmeceler
/// ve (varsa) sökülen çekmecede kalan atama/stoklar. Engel varsa kayıt kapalıdır.
class _DrawerReplacementSummary extends StatelessWidget {
  const _DrawerReplacementSummary({required this.replacements});

  final List<DrawerReplacement> replacements;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocked = replacements.any((r) => r.isBlocked);
    final accent = blocked ? MedColors.red : MedColors.blue;

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: blocked ? MedColors.redLight : MedColors.blueLight,
        border: Border.all(color: accent),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cabinDesign_replace_sectionTitle,
            style: MedTextStyles.bodyMd(color: MedColors.text).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: MedSpacing.sm),
          for (final r in replacements) ...[
            Text(
              l10n.cabinDesign_replace_changeItem(r.address, r.currentTypeName ?? '—', r.scannedTypeName ?? '—'),
              style: MedTextStyles.monoMd(color: MedColors.text),
            ),
            for (final b in r.blockers)
              Padding(
                padding: const EdgeInsets.only(left: MedSpacing.lg, top: 2),
                child: Text(
                  b.hasStock
                      ? l10n.cabinDesign_replace_blockerWithStock(b.medicineName, b.stockLabel)
                      : l10n.cabinDesign_replace_blockerAssignmentOnly(b.medicineName),
                  style: MedTextStyles.bodySm(color: MedColors.red),
                ),
              ),
            const SizedBox(height: MedSpacing.xs),
          ],
          const SizedBox(height: MedSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  blocked ? l10n.cabinDesign_replace_blockedInfo : l10n.cabinDesign_replace_readyInfo,
                  style: MedTextStyles.bodySm(color: blocked ? MedColors.red : MedColors.text2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
