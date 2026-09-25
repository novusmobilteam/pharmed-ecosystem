import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Seçim ekranının sol panelinde tek bir dolum listesini temsil eden kart.
/// Salt görüntüleme — tıklanınca notifier.selectList çağrılır, kartın
/// kendisi hiçbir state taşımaz.
class RefillListCard extends StatelessWidget {
  const RefillListCard({super.key, required this.refillList, required this.onTap, this.isSelected = false});

  final RefillList refillList;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final status = refillList.status;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 1.5 : 1),
          borderRadius: MedRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${refillList.id.toString()}', style: MedTextStyles.titleSm()),
                if (status != null)
                  MedChip(
                    label: status.label,
                    background: MedColors.blue,
                    foreground: MedColors.blueLight,
                    showBorder: false,
                  ),
              ],
            ),
            SizedBox(height: 6.0),
            Text(context.l10n.enumCore_prescriptionMovementPendingApprovalActorLabel, style: MedTextStyles.bodySm()),
            Text(refillList.user?.fullName ?? '—', style: MedTextStyles.titleMd(color: MedColors.text)),
            SizedBox(height: 8.0),
            Text(
              context.l10n.refillList_createdDateLabel(refillList.date!.formattedDate.toString()),
              style: MedTextStyles.monoSm(),
            ),
          ],
        ),
      ),
    );
  }
}
