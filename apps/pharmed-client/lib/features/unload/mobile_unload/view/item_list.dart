part of 'mobile_unload_dialog.dart';

enum _ItemStatus {
  inCabinet, // RFID'li, kabinde okunuyor (boşaltılmayı bekliyor)
  unloaded, // RFID'li, çıkarıldı (boşaltıldı)
  notFound, // RFID'li, baseline'da yok → otomatik eksik
  restored, // RFID'li, rollback'te geri kondu
  awaitingReturn, // RFID'li, rollback'te henüz geri konmadı
  nonRfid, // RFID'siz, checkbox + eksik bildir
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileUnloadReady ready, {required bool isRollbackInProgress}) {
  final epc = item.rfidTag;
  if (epc == null) return _ItemStatus.nonRfid;

  if (isRollbackInProgress && ready.previouslyTakenEpcs.contains(epc)) {
    return ready.rfidReadEpcs.contains(epc) ? _ItemStatus.restored : _ItemStatus.awaitingReturn;
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
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage; // ← ekle
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final isRollbackInProgress = state is MobileUnloadRollbackInProgress;

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
        final status = _itemStatusFor(item, ready, isRollbackInProgress: isRollbackInProgress);
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
    final isExcluded = ready != null && item.id != null && ready.excludedItemIds.contains(item.id);
    final isReported = ready != null && item.id != null && ready.reportedMissingItemIds.contains(item.id);
    final isReporting = ready != null && item.id != null && ready.reportingItemIds.contains(item.id);
    final canReport = item.status?.canReportShortage ?? false;
    final canToggle = drawerStage is MobileDrawerOpened && !isReported;

    // RFID'siz + excluded → soluk; değilse duruma göre
    final colors = isNonRfid
        ? (isExcluded ? ItemCardColors.mutedNeutral : ItemCardColors.neutral)
        : switch (status) {
            _ItemStatus.unloaded || _ItemStatus.restored => ItemCardColors.green,
            _ItemStatus.inCabinet => ItemCardColors.blue,
            _ItemStatus.notFound => ItemCardColors.amber,
            _ItemStatus.awaitingReturn => ItemCardColors.red,
            _ItemStatus.nonRfid => ItemCardColors.neutral,
          };

    return OperationItemCard(
      item: item,
      bg: colors.bg,
      border: colors.border,
      textColor: colors.text,
      mutedColor: colors.muted,
      // RFID'siz → boşaltma checkbox'ı (işaretli = boşaltılacak)
      leading: isNonRfid
          ? MedCheckbox(
              value: !isExcluded,
              onChanged: canToggle && item.id != null ? (_) => notifier.toggleExclude(item.id!) : null,
            )
          : null,
      // RFID'li → durum rozeti
      trailing: isNonRfid ? null : _unloadItemBadge(status),
      // RFID'siz + eksik bildirilebilir + boşaltma dışı DEĞİL + çekmece açık → buton
      footer: (isNonRfid && canReport && !isExcluded && drawerStage is MobileDrawerOpened && item.id != null)
          ? (isReported
                ? reportedMissingBadge()
                : Align(
                    alignment: Alignment.centerRight,
                    child: MedButton(
                      label: isReporting ? 'Bildiriliyor...' : 'Eksik Stok Bildir',
                      size: MedButtonSize.sm,
                      variant: MedButtonVariant.danger,
                      isLoading: isReporting,
                      onPressed: isReporting ? null : () => notifier.reportMissingStock(item.id!),
                    ),
                  ))
          : null,
    );
  }
}

StatusBadge _unloadItemBadge(_ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.unloaded => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      'Boşaltıldı',
    ),
    _ItemStatus.inCabinet => (
      MedColors.blue.withValues(alpha: 0.3),
      MedColors.blue,
      PhosphorIcons.package(PhosphorIconsStyle.bold),
      'Kabinde',
    ),
    _ItemStatus.notFound => (
      MedColors.amber,
      MedColors.amberLight,
      PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
      'Bulunamadı',
    ),
    _ItemStatus.restored => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      'Geri Kondu',
    ),
    _ItemStatus.awaitingReturn => (
      MedColors.red,
      MedColors.redLight,
      PhosphorIcons.arrowUDownLeft(PhosphorIconsStyle.bold),
      'Geri Konmalı',
    ),
    _ => (MedColors.surface3, MedColors.text3, PhosphorIcons.minusCircle(), '—'),
  };
  return StatusBadge(bg: bg, fg: fg, icon: icon, label: label);
}
