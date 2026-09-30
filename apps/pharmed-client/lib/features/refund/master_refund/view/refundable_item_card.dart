part of 'master_refund_view.dart';

/// İade seçim listesindeki tek kalem. Üç görünümü var:
/// - donanımlı iade → checkbox (satıra dokununca seçilir)
/// - donanımsız iade → şimşek ikonu + "İade Et" butonu (satır seçilmez)
/// - iade edilemez → yalnızca bilgi, etkileşim yok
///
/// Seçilebilirlik kuralı notifier'da ([MasterRefundSelectionNotifier.isSelectable])
/// tek noktada tutulur; kart onu sadece okur.
class RefundableItemCard extends StatelessWidget {
  const RefundableItemCard({super.key, required this.notifier, required this.item});

  final MasterRefundSelectionNotifier notifier;
  final CabinTargetedPrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final isRefundable = notifier.isRefundable(item);
    final isSelectable = notifier.isSelectable(item);
    final isDirect = notifier.isDirectRefundable(item);
    final isSelected = notifier.isSelected(item);

    final returnType = isRefundable ? item.medicine?.returnType : ReturnType.nonRefundable;
    final unitLabel = item.medicine?.operationUnitLocalized(context) ?? '';

    final isDirectLoading = notifier.itemStatuses[item.id] is RefundCheckLoading;
    final isLocked = notifier.isStartingRefund;

    return InkWell(
      onTap: isSelectable && !isLocked ? () => notifier.toggleItem(item) : null,
      child: Padding(
        padding: MedSpacing.insetXl,
        child: Row(
          spacing: MedSpacing.lg,
          children: [
            _LeadingIndicator(isSelectable: isSelectable, isDirect: isDirect, isSelected: isSelected),
            _DoseBadge(dose: item.dosePiece, unitLabel: unitLabel, isSelected: isSelected),
            Expanded(
              child: _MedicineInfo(item: item, returnType: returnType),
            ),
            if (isRefundable)
              SizedBox(
                width: 130,
                child: MedDoseStepper(
                  type: DoseStepperType.compact,
                  value: notifier.amountFor(item.id).toDouble(),
                  min: 0.01,
                  max: notifier.maxAmountFor(item.id).toDouble(),
                  onChanged: (v) => notifier.updateAmount(
                    item.id,
                    v,
                    onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  ),
                  unit: unitLabel,
                ),
              ),
            if (isDirect)
              MedButton(
                label: isDirectLoading
                    ? context.l10n.refund_directReturnSendingLabel
                    : context.l10n.refund_directReturnButton,
                size: MedButtonSize.sm,
                variant: MedButtonVariant.success,
                prefixIcon: Icon(PhosphorIcons.arrowUUpLeft()),
                isLoading: isDirectLoading,
                onPressed: isDirectLoading || isLocked
                    ? null
                    : () => notifier.completeDirectRefund(
                        item.id,
                        onSuccess: () {
                          if (!context.mounted) return;
                          MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                        },
                        onFailed: (msg) {
                          if (!context.mounted) return;
                          MessageUtils.showErrorSnackbar(context, msg ?? context.l10n.refund_error_genericCheckFailed);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIndicator extends StatelessWidget {
  const _LeadingIndicator({required this.isSelectable, required this.isDirect, required this.isSelected});

  final bool isSelectable;
  final bool isDirect;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isSelectable) {
      // Dokunma satırın kendisinden gelir; checkbox yalnızca durumu gösterir.
      return IgnorePointer(
        child: MedCheckbox(value: isSelected, onChanged: (_) {}, size: MedCheckboxSize.md),
      );
    }
    if (isDirect) {
      return MedRectangleIconButton(
        iconData: PhosphorIcons.lightning(),
        size: 22,
        color: MedColors.greenLight,
        iconColor: MedColors.green,
      );
    }
    return const SizedBox.shrink();
  }
}

class _DoseBadge extends StatelessWidget {
  const _DoseBadge({required this.dose, required this.unitLabel, required this.isSelected});

  final num dose;
  final String unitLabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : MedColors.text;
    return Container(
      height: 45,
      width: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: isSelected ? MedColors.blue : MedColors.surface2, borderRadius: MedRadius.lgAll),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dose.formatFractional.toString(), style: MedTextStyles.titleMd(color: foreground)),
          Text(unitLabel, style: MedTextStyles.bodySm(color: foreground)),
        ],
      ),
    );
  }
}

class _MedicineInfo extends StatelessWidget {
  const _MedicineInfo({required this.item, required this.returnType});

  final CabinTargetedPrescriptionItem item;
  final ReturnType? returnType;

  @override
  Widget build(BuildContext context) {
    final performedBy = item.lastMovement?.performedBy?.fullName;
    final meta = [
      item.medicineBarcode,
      context.l10n.refund_appliedDateLabel(item.time.formattedDateTime),
      if (performedBy != null && performedBy.isNotEmpty) context.l10n.refund_performedByLabel(performedBy),
    ].join('  -  ');

    return Column(
      spacing: MedSpacing.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.medicineName, style: MedTextStyles.titleSm(), overflow: TextOverflow.ellipsis),
        Text(meta, style: MedTextStyles.monoSm(), overflow: TextOverflow.ellipsis),
        Wrap(
          spacing: MedSpacing.sm,
          runSpacing: MedSpacing.xs,
          children: [
            MedChip(
              label: returnType?.label ?? '-',
              background: returnType?.bakcgroundColor,
              foreground: returnType?.foregroundColor,
              showBorder: false,
              shape: MedChipShape.pill,
            ),
            if (item.collectStationName case final station?)
              MedChip(
                label: station,
                background: MedColors.purple,
                foreground: Colors.white,
                showBorder: false,
                shape: MedChipShape.pill,
              ),
          ],
        ),
      ],
    );
  }
}
