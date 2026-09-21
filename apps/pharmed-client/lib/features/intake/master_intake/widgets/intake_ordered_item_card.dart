import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/master_intake_selection_notifier.dart';
import '../view/master_intake_view.dart';

class IntakeOrderedItemCard extends StatelessWidget {
  const IntakeOrderedItemCard({super.key, required this.notifier, required this.item});

  final MasterIntakeSelectionNotifier notifier;
  final IntakeItem item;

  @override
  Widget build(BuildContext context) {
    final isSelected = notifier.isSelected(item.id);
    final hasNoStock = item.hasNoStock;
    final witnessContext = notifier.witnessContextOf(item);
    final needsWitness = notifier.needsWitness(item);
    final missingWitness = needsWitness && witnessContext.witness == null;
    final canInteract = !hasNoStock && !missingWitness;
    final foreground = isSelected ? Colors.white : MedColors.text;

    // Muadil sorgusu başlatıldıysa (idle değilse) alt bölüm açılır.
    final equivalentCheckStarted = hasNoStock && notifier.equivalentOptionsFor(item.id) != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Opacity(
                opacity: hasNoStock ? 0.6 : 1.0,
                child: Row(
                  spacing: 12.0,
                  children: [
                    /// MARK: Checkbox
                    MedCheckbox(
                      value: isSelected,
                      onChanged: (_) {
                        if (canInteract) notifier.selectItem(item.id);
                      },
                      size: MedCheckboxSize.md,
                    ),

                    /// MARK: Doz bilgisi
                    Container(
                      height: 45,
                      width: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? MedColors.blue : MedColors.surface2,
                        borderRadius: MedRadius.lgAll,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.prescriptionDose.formatFractional.toString(),
                            style: MedTextStyles.titleMd(color: foreground),
                          ),
                          Text(
                            item.medicine?.operationUnitLocalized(context) ?? '',
                            style: MedTextStyles.bodySm(color: foreground),
                          ),
                        ],
                      ),
                    ),

                    /// MARK: Metadata
                    Column(
                      spacing: 4.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.medicine?.name ?? '', style: MedTextStyles.titleSm()),
                        Row(
                          spacing: 6.0,
                          children: [
                            Text(item.medicine?.barcode ?? '', style: MedTextStyles.monoSm()),
                            Text('-', style: MedTextStyles.monoSm()),
                            Text('Reçete Tarihi: ${item.time.formattedDateTime}', style: MedTextStyles.monoSm()),
                            Text('-', style: MedTextStyles.monoSm()),
                            Text(
                              'Reçete Eden: ${item.lastMovement?.performedBy?.fullName}',
                              style: MedTextStyles.monoSm(),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),

                        /// MARK: Chips
                        Row(
                          spacing: 6.0,
                          children: [
                            if (item.firstDoseEmergency)
                              MedInfoChip(
                                info: context.l10n.common_flagFirstDoseEmergency,
                                backgroundColor: MedColors.red,
                                foregroundColor: MedColors.redLight,
                              ),
                            if (item.askDoctor)
                              MedInfoChip(
                                info: context.l10n.common_flagAskDoctor,
                                backgroundColor: MedColors.purple,
                                foregroundColor: MedColors.blueLight,
                              ),
                            if (item.inCaseOfNecessity)
                              MedInfoChip(
                                info: context.l10n.common_flagInCaseOfNecessity,
                                backgroundColor: MedColors.amber,
                                foregroundColor: MedColors.amberLight,
                              ),
                            if (witnessContext.witness != null)
                              MedChip(
                                icon: PhosphorIcons.user(),
                                label: context.l10n.intake_label_witnessName(witnessContext.witness!.fullName),
                                shape: MedChipShape.pill,
                                background: MedColors.greenLight,
                                foreground: MedColors.green,
                                showBorder: false,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// MARK: Stok bilgileri
              Spacer(),
              if (item.isRedirected)
                MedChip(
                  icon: PhosphorIcons.arrowBendUpRight(),
                  label: item.lastMovement?.type.label(context) ?? '',
                  shape: MedChipShape.pill,
                  background: MedColors.purple,
                  foreground: Colors.white,
                  showBorder: false,
                )
              else if (hasNoStock && !item.isEquivalentIntake && !equivalentCheckStarted)
                MedChip(
                  label: '${context.l10n.intake_hint_noStock} (${context.l10n.intake_action_checkEquivalent})',
                  background: MedColors.red,
                  foreground: MedColors.redLight,
                  showBorder: false,
                  size: MedChipSize.lg,
                  onTap: () => notifier.checkEquivalent(item.id),
                )
              else if (hasNoStock && !item.isEquivalentIntake)
                const SizedBox.shrink()
              else if (missingWitness)
                MedChip(
                  icon: PhosphorIcons.userPlus(),
                  label: context.l10n.intake_hint_witnessRequired,
                  shape: MedChipShape.pill,
                  background: MedColors.amberLight,
                  foreground: MedColors.amber,
                  showBorder: false,
                  onTap: () => openIntakeWitnessDialog(context, notifier, item),
                )
              else
                SizedBox(
                  width: 130,
                  child: MedDoseStepper(
                    type: DoseStepperType.compact,
                    value: item.dosePiece ?? 0,
                    min: notifier.doseBoundsFor(item.id).min,
                    max: notifier.doseBoundsFor(item.id).max,
                    onChanged: (v) => notifier.updateDose(item.id, v),
                    unit: item.medicine?.operationUnitLocalized(context) ?? '',
                  ),
                ),
            ],
          ),

          /// MARK: Muadil / diğer istasyon çözümü — genişleyerek açılır.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: equivalentCheckStarted
                ? _StockResolutionSection(notifier: notifier, item: item)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StockResolutionSection extends StatelessWidget {
  const _StockResolutionSection({required this.notifier, required this.item});

  final MasterIntakeSelectionNotifier notifier;
  final IntakeItem item;

  Widget _loadingRow(BuildContext context, String text) => Row(
    spacing: MedSpacing.xs,
    children: [
      const MedLoadingIndicator(),
      Text(text, style: MedTextStyles.bodySm(color: MedColors.text3)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final itemId = item.id;
    final eqOp = notifier.equivalentOpFor(itemId);
    final eqOptions = notifier.equivalentOptionsFor(itemId)!;

    if (notifier.isLoading(eqOp)) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: _loadingRow(context, context.l10n.intake_status_checking),
      );
    }
    if (notifier.isFailed(eqOp)) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: MedChip(label: notifier.message(eqOp) ?? context.l10n.intake_status_checkFailed),
      );
    }

    if (eqOptions.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: MedSpacing.md,
          children: [
            Text(context.l10n.intake_label_equivalentOptions, style: MedTextStyles.titleSm(color: MedColors.text)),
            for (final eq in eqOptions)
              _EquivalentRow(
                eq: eq,
                isChosen: item.selectedEquivalent?.materialId == eq.materialId,
                onTap: () => notifier.toggleEquivalentSelection(itemId, eq),
                displayedQuantity: item.selectedEquivalent?.materialId == eq.materialId
                    ? (item.dosePiece ?? eq.purchaseQuantity ?? 0)
                    : (eq.purchaseQuantity ?? 0),
              ),
          ],
        ),
      );
    }

    // Muadil yok — diğer istasyon durumuna geç.
    final stOp = notifier.otherStationOpFor(itemId);
    final stations = notifier.otherStationOptionsFor(itemId);
    final redirected = notifier.redirectedStationFor(itemId);

    if (redirected != null || item.isRedirected) return const SizedBox.shrink();

    late Widget content;
    if (stations == null || notifier.isLoading(stOp)) {
      content = _loadingRow(context, context.l10n.intake_hint_searchingOtherStations);
    } else if (notifier.isFailed(stOp)) {
      content = MedChip(label: notifier.message(stOp) ?? context.l10n.intake_status_checkFailed);
    } else if (stations.isEmpty) {
      content = MedChip(
        label: context.l10n.intake_hint_noStockAnywhere,
        background: MedColors.red,
        foreground: MedColors.redLight,
        showBorder: false,
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: MedSpacing.md,
        children: [
          Text(context.l10n.intake_label_otherStationOptions, style: MedTextStyles.titleSm(color: MedColors.text)),
          for (final s in stations)
            _OtherStationRow(
              station: s,
              isLoading: notifier.isLoading(notifier.redirectOpFor(itemId)),
              onTap: () => notifier.redirectToStation(itemId, s),
            ),
        ],
      );
    }

    return Padding(padding: const EdgeInsets.only(top: 12.0), child: content);
  }
}

class _EquivalentRow extends StatelessWidget {
  const _EquivalentRow({
    required this.eq,
    required this.isChosen,
    required this.displayedQuantity,
    required this.onTap,
  });

  final EquivalentMedicine eq;
  final bool isChosen;
  final VoidCallback onTap;
  final double displayedQuantity;

  @override
  Widget build(BuildContext context) {
    final unit = eq.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;
    final qty = displayedQuantity;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetLg,
        decoration: BoxDecoration(
          color: isChosen ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: isChosen ? MedColors.blue : MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            if (isChosen) ...[
              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: MedColors.blue, size: 18),
              const SizedBox(width: MedSpacing.xs),
            ],
            Expanded(
              child: Text(
                eq.materialName ?? '—',
                style: MedTextStyles.titleSm(color: isChosen ? MedColors.blue : MedColors.text),
              ),
            ),
            Text(
              '${qty == qty.toInt() ? qty.toInt() : qty} $unit',
              style: MedTextStyles.monoMd(color: isChosen ? MedColors.blue : MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherStationRow extends StatelessWidget {
  const _OtherStationRow({required this.station, this.onTap, this.isLoading = false});

  final OtherStationMedicine station;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.l10n.wizard_summaryLabelStation}: ${station.stationName}',
                    style: MedTextStyles.titleSm().copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (station.serviceName != null)
                    Text(
                      '${context.l10n.stationSetup_station_serviceLabel}: ${station.serviceName!}',
                      style: MedTextStyles.monoMd(color: MedColors.text3),
                    ),
                  if (station.isEquivalent)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: MedChip(
                        label: station.materialName ?? context.l10n.intake_label_equivalentOptions,
                        background: MedColors.purple,
                        foreground: MedColors.greenLight,
                        showBorder: false,
                        size: MedChipSize.lg,
                      ),
                    ),
                ],
              ),
            ),
            if (isLoading)
              const MedLoadingIndicator()
            else
              MedButton(
                label: context.l10n.intake_action_redirect,
                size: MedButtonSize.sm,
                onPressed: onTap,
                variant: MedButtonVariant.success,
              ),
          ],
        ),
      ),
    );
  }
}
