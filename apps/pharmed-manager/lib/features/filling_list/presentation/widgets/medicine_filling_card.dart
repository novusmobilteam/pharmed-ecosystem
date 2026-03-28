import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/dose_stepper.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../domain/entity/filling_object.dart';

class MedicineFillingCard extends StatelessWidget {
  final FillingObject object;
  final double selectedQuantity;
  final Function(double) onQuantityChanged;
  final VoidCallback onTap;

  const MedicineFillingCard({
    super.key,
    required this.object,
    required this.selectedQuantity,
    required this.onQuantityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedQuantity > 0;
    final current = object.medicine?.fromFillingBackendValue(object.quantity) ?? 0.0;
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
            // Sol: Durum ve İkon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCritical ? Colors.red : context.colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PhosphorIcons.pill(),
                color: isCritical ? context.colorScheme.onPrimary : context.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Orta: İsim ve Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object.medicine?.name ?? '-',
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _infoText(
                    context,
                    'Mevcut: ${current.formatFractional}',
                    isCritical ? Colors.orange : null,
                  ),
                  _infoText(context, object.assignment?.quantityText ?? '-', null),
                ],
              ),
            ),

            // Sağ: Modern Stepper
            DoseStepper.compact(
              value: selectedQuantity,
              unit: object.medicine?.operationUnit ?? 'Adet',
              // onChanged doğrudan yeni değeri (double) döndürür
              onChanged: (newVal) => onQuantityChanged(newVal),
              // Minimum ve adım değerlerini de buradan kontrol edebilirsin (Opsiyonel)
              min: 0,
              step: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(BuildContext context, String text, Color? color) {
    return Text(
      text,
      style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
