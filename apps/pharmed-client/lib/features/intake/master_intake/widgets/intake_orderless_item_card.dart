import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/master_intake_selection_notifier.dart';
import '../view/master_intake_view.dart';

class IntakeOrderlessItemCard extends StatelessWidget {
  const IntakeOrderlessItemCard({super.key, required this.notifier, required this.item});

  final MasterIntakeSelectionNotifier notifier;
  final IntakeItem item;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = notifier.isSelected(item.id);
    final bool hasNoStock = item.hasNoStock;
    final bool isRedirected = item.isRedirected;
    final witnessContext = notifier.witnessContextOf(item);
    final needsWitness = notifier.needsWitness(item);
    final missingWitness = needsWitness && witnessContext.witness == null;
    final canInteract = !hasNoStock && !missingWitness && !isRedirected;

    return GestureDetector(
      onTap: canInteract ? () => notifier.selectItem(item.id) : null,
      child: Opacity(
        opacity: (hasNoStock || isRedirected) ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 12.0,
            children: [
              MedCheckbox(
                value: isSelected,
                onChanged: canInteract ? (_) => notifier.selectItem(item.id) : null,
                size: MedCheckboxSize.md,
              ),
              Expanded(
                child: Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.medicine?.name ?? '', style: MedTextStyles.titleSm()),
                    Row(
                      spacing: 6.0,
                      children: [
                        Text(item.medicine?.barcode ?? '', style: MedTextStyles.monoSm()),
                        Text('-', style: MedTextStyles.monoSm()),
                        if (item.medicine?.dailyMax != null)
                          Text(
                            'Günlük Maks. Kullanım Miktarı: ${item.medicine?.dailyMax}',
                            style: MedTextStyles.monoSm(),
                          ),
                        Text('-', style: MedTextStyles.monoSm()),
                        if (item.medicine?.collectNote != null)
                          Text('Alım Notu: ${item.medicine?.collectNote}', style: MedTextStyles.monoSm()),
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
              ),
              if (isRedirected)
                const SizedBox.shrink()
              else if (hasNoStock)
                MedChip(
                  label: context.l10n.intake_hint_noStock,
                  background: MedColors.red,
                  foreground: MedColors.redLight,
                  showBorder: false,
                  size: MedChipSize.lg,
                )
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
        ),
      ),
    );
  }
}
