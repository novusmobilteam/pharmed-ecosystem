part of 'mobile_refill_dialog.dart';

enum _ItemStatus {
  /// RFID'li item, EPC'si kabinde okundu (yerleştirilmiş)
  placed,

  /// RFID'li item, EPC'si henüz kabinde değil (kullanıcı yerleştirmeli)
  awaiting,

  /// RFID'li item, Error sonrası kullanıcı kabinden çıkardı
  removed,

  /// RFID'siz item — manuel tracking, RFID akışı dışı
  nonRfid,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileRefillReady ready, {required bool isRollbackInProgress}) {
  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  final epc = item.rfidTag!;

  // Rollback sırasında: önceden yerleştirilmişti, şimdi yoksa → removed.
  // previouslyPlacedEpcs Ready'de tutulur; rollback başlatılınca yerleştirilen
  // tüm tag'ler buraya kopyalanır, sonra kullanıcı çıkardıkça rfidReadEpcs
  // boşalır → fark "Kabinden Çıkarıldı" rozetiyle gösterilir.
  if (isRollbackInProgress && ready.previouslyPlacedEpcs.contains(epc) && !ready.rfidReadEpcs.contains(epc)) {
    return _ItemStatus.removed;
  }

  if (ready.rfidReadEpcs.contains(epc)) return _ItemStatus.placed;
  return _ItemStatus.awaiting;
}

class _ItemsList extends ConsumerWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final isRollbackInProgress = state is MobileRefillRollbackInProgress;

    final selectedItems =
        ready.prescriptionItems.where((i) => i.id != null && ready.selectedItemIds.contains(i.id)).toList()
          ..sort((a, b) {
            final aRfid = (a.medicine is Drug) && (a.medicine as Drug).isRfidEnable;
            final bRfid = (b.medicine is Drug) && (b.medicine as Drug).isRfidEnable;
            if (aRfid && !bRfid) return -1;
            if (!aRfid && bRfid) return 1;
            return 0;
          });

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Seçilenler (${selectedItems.length})', style: MedTextStyles.monoXs(color: MedColors.text3)),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: MedSpacing.insetMd.top),
              itemCount: selectedItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = selectedItems[i];
                final status = _itemStatusFor(item, ready, isRollbackInProgress: isRollbackInProgress);
                return _ItemCard(item: item, status: status);
              },
            ),
          ),
        ],
      ),
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
      _ItemStatus.removed => (
        MedColors.redLight,
        MedColors.red.withValues(alpha: 0.3),
        MedColors.red,
        MedColors.red.withValues(alpha: 0.8),
        MedColors.red,
        MedColors.redLight,
        'Kabinden Çıkarıldı',
        PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
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
              _ItemBadge(label: badgeLabel, icon: badgeIcon, bg: badgeBg, fg: badgeFg),
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
                    child: Text(_formatEpc(item.rfidTag!), style: MedTextStyles.monoXs(color: mutedColor)),
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

class _ItemBadge extends StatelessWidget {
  const _ItemBadge({required this.label, required this.icon, required this.bg, required this.fg});

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.mdAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
