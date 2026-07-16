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

  pending,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileIntakeReady ready) {
  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  if (!ready.baselineCompleted) {
    return _ItemStatus.pending;
  }

  final epc = item.rfidTag!;

  if (ready.takenEpcs.contains(epc)) return _ItemStatus.taken;
  if (ready.notFoundEpcs.contains(epc)) return _ItemStatus.notFound;
  // Baseline'da var ve çıkmadı → hâlâ kabinde
  return _ItemStatus.inCabinet;
}

MedChip _intakeItemBadge(BuildContext context, _ItemStatus status) {
  final (bg, fg, icon, label) = switch (status) {
    _ItemStatus.taken => (
      MedColors.green,
      MedColors.greenLight,
      PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      context.l10n.rfidStatus_taken,
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
    _ItemStatus.nonRfid => (
      MedColors.surface3,
      MedColors.text3,
      PhosphorIcons.minusCircle(),
      context.l10n.intake_label_noRfid,
    ),
  };
  return MedChip(background: bg, foreground: fg, icon: icon, label: label);
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
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
    final ready = ref.watch(mobileIntakeNotifierProvider).readyContext;

    final isNonRfid = status == _ItemStatus.nonRfid;
    final itemId = item.id;

    final isMarkedMissing = ready != null && itemId != null && ready.markedMissingItemIds.contains(itemId);

    final colors = isNonRfid
        ? (isMarkedMissing ? ItemCardColors.red : (ItemCardColors.green))
        : switch (status) {
            _ItemStatus.taken => ItemCardColors.green,
            _ItemStatus.inCabinet => ItemCardColors.blue,
            _ItemStatus.notFound => ItemCardColors.amber,
            _ItemStatus.nonRfid => ItemCardColors.green,
            _ItemStatus.pending => ItemCardColors.neutral,
          };

    return OperationItemCard(
      item: item,
      bg: colors.bg,
      border: colors.border,
      textColor: colors.text,
      mutedColor: colors.muted,

      // RFID'siz → eksik toggle; RFID'li → durum rozeti
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
          : _intakeItemBadge(context, status),
    );
  }
}
