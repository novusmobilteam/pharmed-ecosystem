part of 'mobile_refill_dialog.dart';

enum _ItemStatus {
  /// RFID'li item, EPC'si kabinde okundu (yerleştirilmiş)
  placed,

  /// RFID'li item, EPC'si henüz kabinde değil (kullanıcı yerleştirmeli)
  awaiting,

  /// RFID'siz item — manuel tracking, RFID akışı dışı
  nonRfid,

  pending,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileRefillReady ready) {
  if (!ready.baselineCompleted) {
    return _ItemStatus.pending;
  }

  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  final epc = item.rfidTag!;

  if (ready.placedEpcs.contains(epc)) return _ItemStatus.placed;
  return _ItemStatus.awaiting;
}

MedChip _refillItemBadge(BuildContext context, _ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.placed => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      context.l10n.refill_label_placed,
    ),
    _ItemStatus.awaiting => (
      MedColors.blue.withValues(alpha: 0.3),
      MedColors.blue,
      PhosphorIcons.hourglassMedium(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_waiting,
    ),
    _ItemStatus.pending => (
      MedColors.surface2,
      MedColors.text3,
      PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_scanning,
    ),

    _ItemStatus.nonRfid => (Colors.transparent, Colors.transparent, PhosphorIcons.minusCircle(), ''),
  };
  return MedChip(background: bg, foreground: fg, icon: icon, label: label);
}

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
      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    final colors = switch (status) {
      _ItemStatus.placed => ItemCardColors.green,
      _ItemStatus.awaiting => ItemCardColors.blue,
      _ItemStatus.nonRfid => ItemCardColors.green,
      _ItemStatus.pending => ItemCardColors.neutral,
    };

    return OperationItemCard(
      item: item,
      bg: colors.bg,
      border: colors.border,
      textColor: colors.text,
      mutedColor: colors.muted,
      trailing: _refillItemBadge(context, status),
    );
  }
}
