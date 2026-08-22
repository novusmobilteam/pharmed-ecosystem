import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class MedDrugActivityCard extends StatelessWidget {
  const MedDrugActivityCard({super.key, required this.movement});

  final PrescriptionItemMovement movement;

  String _doseText(BuildContext context) {
    final piece = movement.quantity?.formatFractional ?? '-';
    final unit =
        movement.prescriptionItem?.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;
    return '$piece $unit';
  }

  String get _medicine => movement.prescriptionItem?.medicine?.name ?? '-';
  String get _patient => movement.prescriptionItem?.prescription?.hospitalization?.patient?.fullName ?? '-';
  String get _performedBy => movement.performedBy?.fullName ?? '-';
  String get _dateTime => movement.createdAt?.formattedDateTime ?? '-';
  PrescriptionMovementType get _type => movement.type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MedSpacing.md, right: MedSpacing.md, left: MedSpacing.md),
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon + ilaç adı + doz
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MedRectangleIconButton(
                color: _type.foregroundColor,
                iconColor: _type.backgroundColor,
                iconData: _type.icon,
                borderColor: Colors.transparent,
                dimWhenDisabled: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_medicine, style: MedTextStyles.titleSm(), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                _doseText(context),
                style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
              ),
            ],
          ),

          // Ayraç
          const SizedBox(height: 12),
          const Divider(height: 1, color: MedColors.border2),
          const SizedBox(height: 12),

          // Bilgi satırları
          MedInfoRow(label: context.l10n.assignment_patientLabel, value: '').runtimeType == Null
              ? const SizedBox()
              : const SizedBox(), // placeholder kaldırılacak
          MedInfoRow(label: context.l10n.assignment_patientLabel, value: _patient),
          const SizedBox(height: 6),
          MedInfoRow(
            label: context.l10n.movement_performedBy,
            value: _performedBy,
          ), // TODO(l10n): no all-caps ARB key exists for this label yet; see migration report
          const SizedBox(height: 6),
          MedInfoRow(label: context.l10n.dashboard_drugActivityDateTimeLabel, value: _dateTime),
          const SizedBox(height: 12),

          // Hareket tipi chip'i — eylem etiketiyle
          MedRxMovementChip(status: _type, useActionLabel: true),
        ],
      ),
    );
  }
}
