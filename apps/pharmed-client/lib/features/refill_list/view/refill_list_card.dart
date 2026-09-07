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
          boxShadow: isSelected ? null : MedShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.enumCore_prescriptionMovementPendingApprovalActorLabel,
                    style: MedTextStyles.monoMd(),
                  ),
                  Text(refillList.user?.fullName ?? '—', style: MedTextStyles.titleSm(color: MedColors.text)),
                  Text(
                    context.l10n.refillList_createdDateLabel(refillList.date!.formattedDate.toString()),
                    style: MedTextStyles.monoSm(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                if (status != null) _badge(label: status.label, color: MedColors.blue, bg: MedColors.blueLight),
                if (refillList.isCancel)
                  _badge(label: context.l10n.refillList_badge_cancelled, color: MedColors.red, bg: MedColors.redLight),
                if (refillList.isFilled)
                  _badge(label: context.l10n.refillList_badge_filled, color: MedColors.green, bg: MedColors.greenLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({required String label, required Color color, required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.smAll),
      child: Text(label, style: MedTextStyles.monoSm(color: color)),
    );
  }
}
