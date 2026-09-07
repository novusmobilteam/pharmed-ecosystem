import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RefillListDetailRow extends StatelessWidget {
  const RefillListDetailRow({super.key, required this.row, required this.isSelected, required this.onToggle});

  final RefillListDetail row;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cabinName = row.cabinAssignment?.drawerUnit?.drawerSlot?.cabin?.name;
    final unit = row.medicine?.fillingUnitLocalized(context) ?? '';

    return InkWell(
      onTap: onToggle,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            MedCheckbox(value: isSelected, onChanged: (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    row.medicine?.name ?? '—',
                    style: MedTextStyles.titleSm(color: MedColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [?cabinName, row.position].join(' • '),
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 4,
              children: [
                Text(
                  context.l10n.refillList_label_plannedQuantity(row.quantity?.toStringAsFixed(0) ?? '-', unit),
                  style: MedTextStyles.monoSm(color: MedColors.text3),
                ),
                if (row.isFilled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: MedColors.greenLight, borderRadius: MedRadius.smAll),
                    child: Text(
                      context.l10n.refillList_badge_filled,
                      style: MedTextStyles.monoSm(color: MedColors.green),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
