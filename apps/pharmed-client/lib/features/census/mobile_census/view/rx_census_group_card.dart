part of 'mobile_census_panel.dart';

enum _CensusItemStatus {
  present, // RFID'li, kabinde okundu (sayıldı)
  missing, // RFID'li, baseline'da okunmadı → otomatik eksik
  markedMissing, // RFID'siz, kullanıcı eksik işaretledi
  pending, // RFID'siz, henüz işaretlenmedi (nötr)
}

_CensusItemStatus _censusItemStatus(PrescriptionItem item, CensusMedicineGroup group) {
  final epc = item.rfidTag;
  if (epc != null) {
    return group.rfidReadEpcs.contains(epc) ? _CensusItemStatus.present : _CensusItemStatus.missing;
  }
  if (item.id != null && group.markedMissingItemIds.contains(item.id)) {
    return _CensusItemStatus.markedMissing;
  }
  return _CensusItemStatus.pending;
}

class RxCensusGroupCard extends StatefulWidget {
  const RxCensusGroupCard({super.key, required this.group, required this.onToggleMissing});

  final CensusMedicineGroup group;

  /// RFID'siz item için "eksik" toggle. RFID'li item'larda kullanılmaz.
  final ValueChanged<int> onToggleMissing;

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
          if (_expanded) ...[
            const Divider(height: 1, color: MedColors.border),
            ...g.items.map((item) {
              final status = _censusItemStatus(item, g);
              return _CensusItemRow(
                item: item,
                status: status,
                // RFID'li item'da toggle yok (null); RFID'siz'de toggle aktif
                onToggleMissing: item.rfidTag != null || item.id == null
                    ? null
                    : () => widget.onToggleMissing(item.id!),
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
  const _CensusItemRow({required this.item, required this.status, required this.onToggleMissing});

  final PrescriptionItem item;
  final _CensusItemStatus status;
  final VoidCallback? onToggleMissing;

  String get _doseText {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? 'Adet';
    return '$piece $unit';
  }

  @override
  Widget build(BuildContext context) {
    final time = item.lastMovement?.createdAt?.shortRelativeLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.sm),
      child: Row(
        children: [
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

          // RFID'li → otomatik durum rozeti; RFID'siz → "Eksik İşaretle" toggle
          if (item.rfidTag != null)
            _CensusStatusBadge(status: status)
          else
            _MissingToggle(isMarked: status == _CensusItemStatus.markedMissing, onTap: onToggleMissing),
        ],
      ),
    );
  }
}

class _MissingToggle extends StatelessWidget {
  const _MissingToggle({required this.isMarked, required this.onTap});

  final bool isMarked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isMarked ? MedColors.redLight : MedColors.surface2;
    final fg = isMarked ? MedColors.red : MedColors.text2;
    final label = isMarked ? 'Eksik Stok Çıkar' : 'Eksik Stok Ekle';
    final icon = isMarked
        ? PhosphorIcons.minusCircle(PhosphorIconsStyle.bold)
        : PhosphorIcons.plusCircle(PhosphorIconsStyle.bold);

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.smAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
        decoration: BoxDecoration(color: bg, borderRadius: MedRadius.smAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _CensusStatusBadge extends StatelessWidget {
  const _CensusStatusBadge({required this.status});

  final _CensusItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (status) {
      _CensusItemStatus.present => (
        MedColors.greenLight,
        MedColors.green,
        PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
        'Sayıldı',
      ),
      _CensusItemStatus.missing => (
        MedColors.amberLight,
        MedColors.amber,
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        'Eksik',
      ),
      _ => (MedColors.surface2, MedColors.text3, PhosphorIcons.minusCircle(), '—'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.smAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
