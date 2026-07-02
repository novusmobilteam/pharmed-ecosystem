part of 'mobile_intake_dialog.dart';

enum _ItemStatus {
  /// RFID'li item, EPC'si kabinden çıkarıldı (alındı sayıldı)
  taken,

  /// RFID'li item, EPC'si kabinde okunuyor (henüz alınmadı)
  inCabinet,

  /// RFID'li item, baseline'da kabinde bulunamadı (otomatik eksik bildirim)
  notFound,

  /// RFID'siz item — manuel tracking, RFID akışı dışı
  nonRfid,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileIntakeReady ready) {
  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  final epc = item.rfidTag!;

  if (ready.takenEpcs.contains(epc)) return _ItemStatus.taken;
  if (ready.notFoundEpcs.contains(epc)) return _ItemStatus.notFound;
  // Baseline'da var ve çıkmadı → hâlâ kabinde
  return _ItemStatus.inCabinet;
}

class _ItemsList extends ConsumerWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
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

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.status});

  final PrescriptionItem item;
  final _ItemStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = switch (status) {
      _ItemStatus.taken => ItemCardColors.green,
      _ItemStatus.inCabinet => ItemCardColors.blue,
      _ItemStatus.notFound => ItemCardColors.amber,
      _ItemStatus.nonRfid => ItemCardColors.neutral,
    };

    final isNonRfid = status == _ItemStatus.nonRfid;
    final ready = ref.watch(mobileIntakeNotifierProvider).readyContext;
    final isReported = ready != null && item.id != null && ready.reportedMissingItemIds.contains(item.id);
    final isReporting = ready != null && item.id != null && ready.reportingItemIds.contains(item.id);

    return OperationItemCard(
      item: item,
      bg: colors.bg,
      border: colors.border,
      textColor: colors.text,
      mutedColor: colors.muted,
      trailing: _intakeItemBadge(status),
      footer: (isNonRfid && item.id != null)
          ? (isReported
                ? reportedMissingBadge()
                : Align(
                    alignment: Alignment.centerRight,
                    child: MedButton(
                      label: isReporting ? 'Bildiriliyor...' : 'Eksik Stok Bildir',
                      size: MedButtonSize.sm,
                      variant: MedButtonVariant.danger,
                      isLoading: isReporting,
                      onPressed: isReporting
                          ? null
                          : () => ref.read(mobileIntakeNotifierProvider.notifier).reportMissingStock(item.id!),
                    ),
                  ))
          : null,
    );
  }
}

StatusBadge _intakeItemBadge(_ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.taken => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      'Alındı',
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
    _ItemStatus.nonRfid => (MedColors.surface3, MedColors.text3, PhosphorIcons.minusCircle(), 'RFID yok'),
  };
  return StatusBadge(bg: bg, fg: fg, icon: icon, label: label);
}
