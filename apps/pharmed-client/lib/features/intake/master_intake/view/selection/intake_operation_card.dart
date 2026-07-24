part of 'master_intake_selection_panel.dart';

class IntakeOperationCard extends StatelessWidget {
  const IntakeOperationCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.checkStatus,
    required this.currentStation,
    required this.onTap,
    required this.onDoseChanged,
    required this.onWitnessTap,
    this.doseMax = 999,
  });

  final IntakeItem item;
  final bool isSelected;
  final IntakeCheckStatus checkStatus;

  /// needsWitness kararı için kullanıcı istasyonu.
  final Station? currentStation;

  /// `null` ise kart tıklanamaz (süreç aktif / kilitli).
  final VoidCallback? onTap;
  final ValueChanged<double> onDoseChanged;
  final VoidCallback onWitnessTap;

  final double doseMax;

  bool get _hasNoStock => item.hasNoStock;
  bool get _needsWitness => item.needsWitness(currentStation: currentStation);
  bool get _isTappable => !_hasNoStock && onTap != null;

  Color get _borderColor {
    if (checkStatus is CheckFailed) return MedColors.red;
    return isSelected ? MedColors.blue : MedColors.border;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? time = item.prescriptionItem?.time;
    String? dose = item.prescriptionDose.formatFractional;
    String? unit = item.medicine?.operationUnitLocalized(context);
    String? doseText = '$dose $unit';
    String? intakeNote = item.prescriptionItem?.medicine?.when(
      drug: (Drug drug) => drug.collectNote,
      consumable: (MedicalConsumable consumable) => '',
    );

    return Opacity(
      opacity: _hasNoStock ? 0.6 : 1.0,
      child: InkWell(
        onTap: _isTappable ? onTap : null,
        borderRadius: MedRadius.lgAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: MedSpacing.insetXl,
          decoration: BoxDecoration(
            color: isSelected ? MedColors.blueLight : MedColors.surface,
            borderRadius: MedRadius.midAll,
            border: Border.all(color: _borderColor, width: isSelected ? 2 : 1),
            boxShadow: MedShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          item.medicine?.name ?? '—',
                          style: MedTextStyles.titleMd(color: isSelected ? MedColors.blue : MedColors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.medicine?.barcode != null)
                          Text(item.medicine!.barcode!, style: MedTextStyles.monoMd(color: MedColors.text3)),
                        SizedBox(height: 6.0),
                        if (doseText.isNotEmpty)
                          Text('${context.l10n.medicine_fieldDose} : $doseText', style: MedTextStyles.titleSm()),
                        if (time != null) Text(time.shortRelativeLabelOf(context), style: MedTextStyles.titleSm()),
                        if (intakeNote != null)
                          Text(
                            '${context.l10n.medicine_fieldCollectNote}: ${intakeNote.trim()}',
                            style: MedTextStyles.monoMd(),
                          ),
                      ],
                    ),
                  ),

                  if (isSelected && !_hasNoStock)
                    MedDoseStepper.compact(
                      value: item.dosePiece ?? 0,
                      unit:
                          item.medicine?.operationUnitLocalized(context) ?? context.l10n.refillList_defaultUnitFallback,
                      onChanged: onDoseChanged,
                      max: doseMax,
                    ),
                ],
              ),

              if (_hasNoStock) const _NoStockChip(),
              RxFlagChips(item: item.prescriptionItem!),
              if (_needsWitness && isSelected && !_hasNoStock) _WitnessRow(item: item, onTap: onWitnessTap),
              if (checkStatus is! CheckIdle) _CheckStatusRow(status: checkStatus),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoStockChip extends StatelessWidget {
  const _NoStockChip();

  @override
  Widget build(BuildContext context) {
    return MedInfoChip(
      backgroundColor: MedColors.redLight,
      foregroundColor: MedColors.red,
      info: context.l10n.intake_hint_noStock,
    );
  }
}

class _WitnessRow extends StatelessWidget {
  const _WitnessRow({required this.item, required this.onTap});

  final IntakeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final witness = item.witness;
    final hasWitness = witness != null;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: hasWitness ? MedColors.greenLight : MedColors.amberLight,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: hasWitness ? MedColors.green : MedColors.amber),
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                hasWitness
                    ? context.l10n.intake_label_witnessName(witness.fullName)
                    : context.l10n.intake_hint_witnessRequired,
                style: MedTextStyles.bodyMd(color: hasWitness ? MedColors.green : MedColors.amber),
              ),
            ),
            if (!hasWitness)
              Icon(PhosphorIcons.caretRight(), size: 14, color: hasWitness ? MedColors.green : MedColors.amber),
          ],
        ),
      ),
    );
  }
}

class _CheckStatusRow extends StatelessWidget {
  const _CheckStatusRow({required this.status});

  final IntakeCheckStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      CheckLoading() => Row(
        spacing: 6,
        children: [
          const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          Text(context.l10n.intake_status_checking, style: MedTextStyles.monoXs(color: MedColors.text3)),
        ],
      ),
      CheckSuccess() => Row(
        spacing: 6,
        children: [
          Icon(PhosphorIcons.check(), size: 14, color: MedColors.green),
          Text(context.l10n.intake_status_readyToTake, style: MedTextStyles.monoXs(color: MedColors.green)),
        ],
      ),
      CheckFailed(:final message) => Row(
        spacing: 6,
        children: [
          Icon(PhosphorIcons.x(), size: 14, color: MedColors.red),
          Expanded(
            child: Text(
              message ?? context.l10n.intake_status_checkFailed,
              style: MedTextStyles.monoXs(color: MedColors.red),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      CheckIdle() => const SizedBox.shrink(),
    };
  }
}
