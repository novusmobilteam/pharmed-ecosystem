part of 'mobile_refill_dialog.dart';

class _ItemsList extends ConsumerWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final selectedItems =
        ready.prescriptionItems.where((i) => i.id != null && ready.selectedItemIds.contains(i.id)).toList()
          ..sort((a, b) {
            final aRfid = (a.medicine is Drug) && (a.medicine as Drug).isRfidEnable;
            final bRfid = (b.medicine is Drug) && (b.medicine as Drug).isRfidEnable;
            if (aRfid && !bRfid) return -1;
            if (!aRfid && bRfid) return 1;
            return 0;
          });

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: MedSpacing.insetMd.top),
      itemCount: selectedItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = selectedItems[i];
        final status = _itemStatusFor(item, ready);
        return _ItemCard(item: item, status: status);
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.status});

  final PrescriptionItem item;
  final _ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, border, textColor, mutedColor, badgeBg, badgeFg, badgeLabel, badgeIcon) = switch (status) {
      _ItemStatus.placed => (
        MedColors.greenLight,
        MedColors.green.withValues(alpha: 0.3),
        MedColors.green,
        MedColors.green.withValues(alpha: 0.8),
        MedColors.green,
        MedColors.greenLight,
        'Yerleştirildi',
        PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      ),
      _ItemStatus.awaiting => (
        MedColors.blueLight,
        MedColors.blue.withValues(alpha: 0.3),
        MedColors.blue,
        MedColors.blue.withValues(alpha: 0.8),
        MedColors.blue.withValues(alpha: 0.3),
        MedColors.blue,
        'Bekleniyor',
        PhosphorIcons.hourglassMedium(PhosphorIconsStyle.bold),
      ),

      _ItemStatus.nonRfid => (
        MedColors.bg,
        MedColors.border,
        MedColors.text,
        MedColors.text3,
        MedColors.surface3,
        MedColors.text3,
        'RFID yok',
        PhosphorIcons.minusCircle(PhosphorIconsStyle.bold),
      ),
    };

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.medicine?.name ?? '-',
                      style: MedTextStyles.bodyMd(color: textColor, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(item.medicine?.barcode ?? '', style: MedTextStyles.monoXs(color: mutedColor)),
                  ],
                ),
              ),
              _refillItemBadge(status),
            ],
          ),
          if (item.rfidTag != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.tag(), size: 13, color: mutedColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(formatEpc(item.rfidTag!), style: MedTextStyles.monoXs(color: mutedColor)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _ItemStatus {
  /// RFID'li item, EPC'si kabinde okundu (yerleştirilmiş)
  placed,

  /// RFID'li item, EPC'si henüz kabinde değil (kullanıcı yerleştirmeli)
  awaiting,

  /// RFID'siz item — manuel tracking, RFID akışı dışı
  nonRfid,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileRefillReady ready) {
  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  final epc = item.rfidTag!;

  if (ready.placedEpcs.contains(epc)) return _ItemStatus.placed;
  return _ItemStatus.awaiting;
}

StatusBadge _refillItemBadge(_ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.placed => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      'Yerleştirildi',
    ),
    _ItemStatus.awaiting => (
      MedColors.blue.withValues(alpha: 0.3),
      MedColors.blue,
      PhosphorIcons.hourglassMedium(PhosphorIconsStyle.bold),
      'Bekleniyor',
    ),
    _ItemStatus.nonRfid => (MedColors.surface3, MedColors.text3, PhosphorIcons.minusCircle(), 'RFID yok'),
  };
  return StatusBadge(bg: bg, fg: fg, icon: icon, label: label);
}
