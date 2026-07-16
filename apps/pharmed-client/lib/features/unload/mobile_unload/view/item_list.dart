part of 'mobile_unload_dialog.dart';

enum _ItemStatus {
  inCabinet, // RFID'li, kabinde okunuyor (boşaltılmayı bekliyor)
  unloaded, // RFID'li, çıkarıldı (boşaltıldı)
  notFound, // RFID'li, baseline'da yok → otomatik eksik
  nonRfid, // RFID'siz, checkbox + eksik bildir toggle
  pending,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileUnloadReady ready) {
  final epc = item.rfidTag;
  if (epc == null) return _ItemStatus.nonRfid;

  if (!ready.baselineCompleted) {
    return _ItemStatus.pending;
  }

  if (ready.takenEpcs.contains(epc)) return _ItemStatus.unloaded;
  if (ready.notFoundEpcs.contains(epc)) return _ItemStatus.notFound;
  return _ItemStatus.inCabinet; // okundu veya henüz okunmadı → kabinde
}

class _ItemsList extends ConsumerWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileUnloadNotifierProvider);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final items = ready.prescriptionItems.where((i) => i.id != null).toList()
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
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = items[i];
        final status = _itemStatusFor(item, ready);
        return _ItemCard(item: item, status: status, drawerStage: drawerStage);
      },
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.status, required this.drawerStage});

  final PrescriptionItem item;
  final _ItemStatus status;
  final MobileDrawerStage drawerStage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(mobileUnloadNotifierProvider.notifier);
    final ready = ref.watch(mobileUnloadNotifierProvider).readyContext;

    final isNonRfid = status == _ItemStatus.nonRfid;
    final itemId = item.id;

    final isIncluded = ready != null && itemId != null && ready.isUnloadIncluded(itemId);
    final isMarkedMissing = ready != null && itemId != null && ready.markedMissingItemIds.contains(itemId);

    // RFID'siz: boşaltmaya dahil değilse VE eksik değilse soluk (skipped).
    // Eksik işaretlendiyse amber, dahilse nötr.
    final colors = isNonRfid
        ? (isMarkedMissing ? ItemCardColors.red : (isIncluded ? ItemCardColors.green : ItemCardColors.mutedNeutral))
        : switch (status) {
            _ItemStatus.unloaded => ItemCardColors.green,
            _ItemStatus.inCabinet => ItemCardColors.blue,
            _ItemStatus.notFound => ItemCardColors.amber,
            _ItemStatus.nonRfid => ItemCardColors.neutral,
            _ItemStatus.pending => ItemCardColors.neutral,
          };

    return OperationItemCard(
      item: item,
      bg: colors.bg,
      border: colors.border,
      textColor: colors.text,
      mutedColor: colors.muted,
      // RFID'siz → boşaltma checkbox'ı (işaretli = boşaltmaya dahil)
      leading: isNonRfid
          ? MedCheckbox(
              value: isIncluded,
              onChanged: itemId != null ? (_) => notifier.toggleUnloadInclude(itemId) : null,
              activeColor: MedColors.green,
            )
          : null,
      // RFID'li → durum rozeti
      trailing: (isNonRfid && itemId != null)
          ? Align(
              alignment: Alignment.centerRight,
              child: MedToggle(
                value: isMarkedMissing,
                color: MedColors.red,
                label: context.l10n.intake_action_reportMissingStock,
                textStyle: MedTextStyles.monoSm(),
                onChanged: (_) => notifier.toggleMarkMissing(itemId),
              ),
            )
          : _unloadItemBadge(context, status),

      // RFID'siz + eksik bildirilebilir + çekmece açık → "Eksik Bildir" toggle
    );
  }
}

MedChip _unloadItemBadge(BuildContext context, _ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.unloaded => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      context.l10n.unload_label_unloaded,
    ),
    _ItemStatus.inCabinet => (
      MedColors.blue.withValues(alpha: 0.3),
      MedColors.blue,
      PhosphorIcons.package(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_inCabin,
    ),
    _ItemStatus.notFound => (
      MedColors.amber,
      MedColors.amberLight,
      PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_notFound,
    ),
    _ItemStatus.pending => (
      MedColors.surface2,
      MedColors.text3,
      PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_scanning,
    ),
    _ => (MedColors.surface3, MedColors.text3, PhosphorIcons.minusCircle(), '—'),
  };
  return MedChip(background: bg, foreground: fg, icon: icon, label: label);
}
