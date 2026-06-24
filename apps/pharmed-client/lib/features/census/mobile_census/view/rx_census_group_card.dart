part of 'mobile_census_panel.dart';

class RxCensusGroupCard extends StatefulWidget {
  const RxCensusGroupCard({
    super.key,
    required this.group,
    required this.isProcessActive,
    required this.isSelectionLocked,
    required this.onToggleItem,
  });

  final CensusMedicineGroup group;
  final bool isProcessActive;
  final bool isSelectionLocked;
  final ValueChanged<int> onToggleItem;

  @override
  State<RxCensusGroupCard> createState() => _RxCensusGroupCardState();
}

class _RxCensusGroupCardState extends State<RxCensusGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        children: [
          // Başlık (her zaman görünür)
          InkWell(
            borderRadius: MedRadius.lgAll,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: MedSpacing.insetLg,
              child: Row(
                children: [
                  Expanded(child: Text(g.medicine.name ?? '—', style: MedTextStyles.titleSm())),
                  _CountBadge(counted: g.countedCount, total: g.totalCount),
                  const SizedBox(width: MedSpacing.sm),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: MedColors.text3),
                ],
              ),
            ),
          ),

          // Alt liste (genişletildiğinde)
          if (_expanded) ...[
            const Divider(height: 1, color: MedColors.border),
            ...g.items.map((item) {
              // Burada mevcut RxOperationCard.census kullan veya
              // census'a özel kompakt bir item satırı çiz.
              return _CensusItemRow(
                item: item,
                isSelected: item.id != null && g.selectedItemIds.contains(item.id),
                isPresent: item.id != null && g.presentItemIds.contains(item.id),
                isProcessActive: widget.isProcessActive,
                onTap: widget.isSelectionLocked || item.id == null || item.rfidTag != null
                    ? null
                    : () => widget.onToggleItem(item.id!),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.counted, required this.total});

  final int counted;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isFull = counted == total;
    final bg = isFull ? MedColors.greenLight : MedColors.surface2;
    final fg = isFull ? MedColors.green : MedColors.text2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.smAll),
      child: Text('$counted / $total', style: MedTextStyles.bodySm().copyWith(color: fg)),
    );
  }
}

class _CensusItemRow extends StatelessWidget {
  const _CensusItemRow({
    required this.item,
    required this.isSelected,
    required this.isPresent,
    required this.isProcessActive,
    required this.onTap,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final bool isPresent;
  final bool isProcessActive;
  final VoidCallback? onTap;

  String get _doseText {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? 'Adet';
    return '$piece $unit';
  }

  @override
  Widget build(BuildContext context) {
    final time = item.lastMovement?.createdAt?.shortRelativeLabel;
    final hasRfid = item.rfidTag != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.sm),
      child: Row(
        children: [
          MedCheckbox(value: isSelected, onChanged: onTap == null ? null : (_) => onTap!()),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time ?? '—', style: MedTextStyles.bodyLg()),
                Text(
                  _doseText,
                  style: MedTextStyles.bodyMd(color: MedColors.text2, weight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Sağ: RFID rozeti
          if (hasRfid) _RfidBadge(isPresent: isPresent),
        ],
      ),
    );
  }
}

class _RfidBadge extends StatelessWidget {
  const _RfidBadge({required this.isPresent});

  final bool isPresent;

  @override
  Widget build(BuildContext context) {
    final bg = isPresent ? MedColors.greenLight : MedColors.surface2;
    final fg = isPresent ? MedColors.green : MedColors.text3;
    final icon = isPresent ? Icons.wifi_tethering : Icons.wifi_tethering_off;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.smAll),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}
