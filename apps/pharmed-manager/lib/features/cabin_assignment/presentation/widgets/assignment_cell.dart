import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/widgets/cabin_editor/cabin_editor_view.dart';
import '../../domain/entity/cabin_assignment.dart';

class AssignmentCell extends StatelessWidget {
  const AssignmentCell({super.key, required this.assignment, this.onTap, this.onIconTap, required this.unit});

  final CabinAssignment assignment;
  final DrawerUnit unit;
  final VoidCallback? onTap;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    final material = assignment.medicine;
    final hasMaterial = material != null;
    final colorScheme = context.colorScheme;

    return BaseUnitCell(
      onTap: onTap,
      workingStatus: unit.workingStatus,
      //backgroundColor: hasMaterial ? colorScheme.primaryContainer : colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 3. Ana İçerik
          if (hasMaterial)
            _DrawerCellContent(assignment)
          else
            Center(
              child: Icon(PhosphorIcons.plus(), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4), size: 28),
            ),

          // 4. Silme Butonu (X)
          if (hasMaterial) Positioned(top: 6, right: 6, child: _DeleteButton(onTap: onIconTap)),
        ],
      ),
    );
  }
}

class _DrawerCellContent extends StatelessWidget {
  const _DrawerCellContent(this.quantity);

  final CabinAssignment quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medicine = quantity.medicine;

    if (medicine == null) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          medicine.name.toString(),
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuantityBadge(label: 'Min', value: quantity.minQuantityFromBackend.toInt(), unit: 'Adet'),
              const SizedBox(width: 4),
              QuantityBadge(label: 'Max', value: quantity.maxQuantityFromBackend.toInt(), unit: 'Adet'),
            ],
          ),
        ),
        SizedBox(height: 4),
        QuantityBadge(label: 'Krt', value: quantity.critQuantityFromBackend.toInt(), isCritical: true, unit: 'Adet'),
      ],
    );
  }
}

class QuantityBadge extends StatelessWidget {
  final String label;
  final num? value;
  final bool isCritical;
  final String unit;

  const QuantityBadge({
    super.key,
    required this.label,
    required this.value,
    this.isCritical = false,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isCritical ? colorScheme.errorContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isCritical ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: ${value ?? 0} $unit',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isCritical ? colorScheme.onErrorContainer : colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _DeleteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(PhosphorIcons.x(), size: 14, color: colorScheme.error),
      ),
    );
  }
}
