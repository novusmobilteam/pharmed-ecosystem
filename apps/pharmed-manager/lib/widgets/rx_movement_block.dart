import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RxMovementBlock extends StatelessWidget {
  const RxMovementBlock({
    super.key,
    required this.lastMovement,
    required this.medicine,
    this.movements,
    this.isLoading = false,
  });

  final PrescriptionItemMovement? lastMovement;
  final Medicine? medicine;
  final List<PrescriptionItemMovement>? movements;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final displayList = movements ?? (lastMovement != null ? [lastMovement!] : []);

    if (displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MedSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.clockCounterClockwise(), size: 14, color: MedColors.text4),
            const SizedBox(width: MedSpacing.sm),
            Text(context.l10n.movement_noHistory, style: MedTextStyles.monoSm(color: MedColors.text4)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < displayList.length; i++) ...[
          if (i > 0) const SizedBox(height: MedSpacing.xl),
          _MovementGroup(movement: displayList[i], medicine: medicine),
        ],
      ],
    );
  }
}

class _MovementGroup extends StatelessWidget {
  const _MovementGroup({required this.movement, required this.medicine});

  final PrescriptionItemMovement movement;
  final Medicine? medicine;

  String _doseText(BuildContext context) {
    if (movement.quantity == null) return '-';
    return '${movement.quantity!.formatFractional} ${medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback}';
  }

  @override
  Widget build(BuildContext context) {
    final type = movement.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailGroupTitle(label: type.actorLabel(context)),
        const SizedBox(height: 6),
        _DetailRow(
          fields: [
            _Field(context.l10n.movement_performedBy, movement.performedBy?.fullName),
            _Field(context.l10n.movement_dateLabel, movement.createdAt.formattedDateTime),
            if (movement.quantity != null) _Field(context.l10n.movement_quantityLabel, _doseText(context)),
          ],
        ),
      ],
    );
  }
}

class _DetailGroupTitle extends StatelessWidget {
  const _DetailGroupTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(label.toUpperCase(), style: MedTextStyles.monoSm(color: MedColors.text4)),
        ),
        Expanded(child: Divider(color: MedColors.border2, height: 1)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.fields});

  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 6, children: fields.map((f) => _DetailCell(field: f)).toList());
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({required this.field});

  final _Field field;

  @override
  Widget build(BuildContext context) {
    final isEmpty = field.value == null || field.value == '-';
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: MedTextStyles.monoXs()),
          const SizedBox(height: 2),
          Text(
            isEmpty ? '—' : field.value!,
            style: MedTextStyles.bodySm(color: isEmpty ? MedColors.text4 : MedColors.text2, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Field {
  const _Field(this.label, this.value);
  final String label;
  final String? value;
}
