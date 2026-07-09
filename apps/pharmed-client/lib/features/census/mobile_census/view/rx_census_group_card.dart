part of 'mobile_census_panel.dart';

enum _CensusItemStatus {
  present, // RFID'li, kabinde okundu (sayıldı)
  missing, // RFID'li, baseline'da okunmadı → otomatik eksik
  markedMissing, // RFID'siz, kullanıcı eksik işaretledi
  pending, // RFID'siz, henüz işaretlenmedi (nötr)
}

_CensusItemStatus _censusItemStatus(PrescriptionItem item, CensusMedicineGroup group, bool baselineCompleted) {
  final epc = item.rfidTag;
  if (epc != null) {
    // Baseline bitmeden "eksik" deme — henüz taranıyor.
    if (!baselineCompleted) return _CensusItemStatus.pending;
    return group.rfidReadEpcs.contains(epc) ? _CensusItemStatus.present : _CensusItemStatus.missing;
  }
  if (item.id != null && group.markedMissingItemIds.contains(item.id)) {
    return _CensusItemStatus.markedMissing;
  }

  return _CensusItemStatus.present;
}

class RxCensusGroupCard extends StatefulWidget {
  const RxCensusGroupCard({
    super.key,
    required this.group,
    required this.onToggleMissing,
    required this.baselineCompleted,
  });

  final CensusMedicineGroup group;

  /// RFID'siz item için "eksik" toggle. RFID'li item'larda kullanılmaz.
  final ValueChanged<int> onToggleMissing;
  final bool baselineCompleted;

  @override
  State<RxCensusGroupCard> createState() => _RxCensusGroupCardState();
}

class _RxCensusGroupCardState extends State<RxCensusGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
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
                  Icon(_expanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown()),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: MedSpacing.xs),
            ...g.items.map((item) {
              final status = _censusItemStatus(item, g, widget.baselineCompleted);
              return _CensusItemRow(
                item: item,
                status: status,
                onToggleMissing: item.rfidTag != null || item.id == null
                    ? null
                    : () => widget.onToggleMissing(item.id!),
              );
            }),
            const SizedBox(height: MedSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _CensusItemRow extends StatelessWidget {
  const _CensusItemRow({required this.item, required this.status, required this.onToggleMissing});

  final PrescriptionItem item;
  final _CensusItemStatus status;
  final VoidCallback? onToggleMissing;

  String _doseText(BuildContext context) {
    final piece = item.dosePiece?.formatFractional ?? '-';
    final unit = item.medicine?.operationUnit ?? context.l10n.refillList_defaultUnitFallback;
    return '$piece $unit';
  }

  ItemCardColors get _colors => switch (status) {
    _CensusItemStatus.present => ItemCardColors.green,
    _CensusItemStatus.missing => ItemCardColors.red,
    _CensusItemStatus.markedMissing => ItemCardColors.red,
    _CensusItemStatus.pending => ItemCardColors.mutedNeutral,
  };

  @override
  Widget build(BuildContext context) {
    final time = item.time?.shortRelativeLabel;
    final c = _colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: MedSpacing.xs),
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        spacing: 12.0,
        children: [
          if (item.rfidTag == null)
            MedCheckbox(
              value: status != _CensusItemStatus.markedMissing,
              onChanged: (_) => onToggleMissing!(),
              activeColor: MedColors.green,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time ?? '—',
                  style: MedTextStyles.bodyMd(color: c.text, weight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(_doseText(context), style: MedTextStyles.bodySm(color: c.muted)),
              ],
            ),
          ),
          const SizedBox(width: MedSpacing.sm),
          if (item.rfidTag != null) _CensusStatusBadge(status: status),
        ],
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
        context.l10n.census_label_counted,
      ),
      _CensusItemStatus.missing => (
        MedColors.redLight,
        MedColors.red,
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        context.l10n.rfidStatus_missing,
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
