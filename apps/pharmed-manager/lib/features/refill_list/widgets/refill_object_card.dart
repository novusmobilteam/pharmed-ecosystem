// Dolum listesi formunun satır bileşenleri:
//   • RefillCandidateRow — sol "İlaç Ekle" bölümünde aday ilaç (işaretlenir).
//   • RefillSelectionRow — sağ "Listedeki İlaçlar" bölümünde ilaç (miktar, sil).

import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/core.dart';

String _qty(num value) => value.formatFractional;

/// Mevcut stok + atama eşikleri tek satır: "Mevcut: 3 · Min 2 · Kritik 1 · Maks 12".
String _stockLine(BuildContext context, num? current, MedicineAssignment? limits) {
  final l10n = context.l10n;
  final parts = <String>[
    if (current != null) l10n.refillList_form_currentStockLabel(_qty(current)),
    if (limits != null) ...[
      '${l10n.common_minLabel} ${_qty(limits.minQuantity)}',
      '${l10n.common_criticalLabel} ${_qty(limits.criticalQuantity)}',
      '${l10n.common_maxLabel} ${_qty(limits.maxQuantity)}',
    ],
  ];
  return parts.join(' · ');
}

class RefillCandidateRow extends StatelessWidget {
  const RefillCandidateRow({
    super.key,
    required this.object,
    required this.suggestedQuantity,
    required this.isChecked,
    required this.isInList,
    required this.onToggle,
  });

  final RefillObject object;
  final num suggestedQuantity;
  final bool isChecked;

  /// Zaten listede — işaretlenemez, "Listede" rozeti gösterilir.
  final bool isInList;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final limits = object.assignment;
    final isCritical = limits != null && object.quantity <= limits.criticalQuantity;

    return InkWell(
      onTap: isInList ? null : onToggle,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isChecked ? MedColors.blueLight : MedColors.surface,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: isChecked ? MedColors.blue : MedColors.border),
        ),
        child: Row(
          spacing: 12,
          children: [
            MedCheckbox(value: isChecked || isInList, enabled: !isInList, onChanged: isInList ? null : (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    object.medicine?.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                  ),
                  Text(
                    _stockLine(context, object.quantity, limits),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MedTextStyles.bodySm(color: isCritical ? MedColors.amber : MedColors.text3),
                  ),
                ],
              ),
            ),
            if (isInList)
              MedChip(label: context.l10n.refillList_form_inListBadge, style: MedChipStyle.success, size: MedChipSize.sm)
            else
              Text(
                context.l10n.refillList_form_suggestedLabel(_qty(suggestedQuantity)),
                style: MedTextStyles.monoSm(color: MedColors.blue, weight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

class RefillSelectionRow extends StatelessWidget {
  const RefillSelectionRow({
    super.key,
    required this.object,
    required this.currentStock,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  /// quantity = dolum miktarı.
  final RefillObject object;

  /// Güncel mevcut stok (aday verisinden); bilinmiyorsa null.
  final num? currentStock;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  object.medicine?.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                ),
                Text(
                  _stockLine(context, currentStock, object.assignment),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ],
            ),
          ),
          MedDoseStepper.compact(
            value: object.quantity.toDouble(),
            unit: object.medicine?.fillingUnit ?? context.l10n.refillList_defaultUnitFallback,
            onChanged: onQuantityChanged,
            // 0'a inmek ilacı listeden çıkarır — silme ayrıca çöp kutusuyla.
            min: 0,
            step: 1.0,
            platform: DoseStepperPlatform.desktop,
          ),
          IconButton(
            tooltip: context.l10n.refillList_form_removeTooltip,
            icon: Icon(PhosphorIcons.trash(), size: 18, color: MedColors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
