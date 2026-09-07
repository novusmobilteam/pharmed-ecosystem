import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/core.dart';

class RefillObjectCard extends StatelessWidget {
  final RefillObject object;
  final double selectedQuantity;
  final Function(double) onQuantityChanged;
  final VoidCallback onTap;

  const RefillObjectCard({
    super.key,
    required this.object,
    required this.selectedQuantity,
    required this.onQuantityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedQuantity > 0;
    final current = object.quantity;
    final isCritical = current <= (object.assignment?.minQuantityFromBackend ?? 0);

    return Container(
      margin: EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (isSelected)
              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: context.colorScheme.primary)
            else
              Icon(PhosphorIcons.circle(), color: context.colorScheme.outline),

            const SizedBox(width: 12),

            // Orta: İsim ve Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object.medicine?.name ?? '-',
                    style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _infoText(
                    context,
                    context.l10n.refill_label_current(current.formatFractional),
                    isCritical ? Colors.orange : null,
                  ),
                  _infoText(context, _quantity(context), null),
                ],
              ),
            ),

            // Sağ: Modern Stepper
            MedDoseStepper.compact(
              value: selectedQuantity,
              unit: object.medicine?.fillingUnit ?? context.l10n.refillList_defaultUnitFallback,
              onChanged: (newVal) => onQuantityChanged(newVal),
              min: 0,
              step: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(BuildContext context, String text, Color? color) {
    return Text(text, style: context.textTheme.bodySmall?.copyWith());
  }

  String _quantity(BuildContext context) {
    final assignment = object.assignment;
    if (assignment == null) return '-';

    return '${context.l10n.common_minLabel}: ${assignment.quantityWithDoseLabel(context, assignment.minQuantity)} - '
        '${context.l10n.common_maxLabel} ${assignment.quantityWithDoseLabel(context, assignment.maxQuantity)} - '
        '${context.l10n.common_criticalLabel}: ${assignment.quantityWithDoseLabel(context, assignment.criticalQuantity)}';
  }
}
