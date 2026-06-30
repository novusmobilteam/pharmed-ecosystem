part of 'mobile_intake_dialog.dart';

enum _ItemStatus {
  /// RFID'li item, EPC'si kabinden çıkarıldı (alındı sayıldı)
  taken,

  /// RFID'li item, EPC'si kabinde okunuyor (henüz alınmadı)
  inCabinet,

  /// RFID'li item, baseline'da kabinde bulunamadı (otomatik eksik bildirim)
  notFound,

  /// RFID'li item, rollback sırasında kabine geri kondu
  restored,

  /// RFID'li item, rollback sırasında henüz geri konmadı (kullanıcı koymalı)
  awaitingReturn,

  /// RFID'siz item — manuel tracking, RFID akışı dışı
  nonRfid,
}

_ItemStatus _itemStatusFor(PrescriptionItem item, MobileIntakeReady ready, {required bool isRollbackInProgress}) {
  final isRfid = item.medicine is Drug && (item.medicine as Drug).isRfidEnable && item.rfidTag != null;
  if (!isRfid) return _ItemStatus.nonRfid;

  final epc = item.rfidTag!;

  // Rollback sırasında: bu tag alınmıştı (previouslyTakenEpcs), şimdi
  // kabinde okunuyorsa geri kondu → restored; okunmuyorsa hâlâ bekleniyor.
  if (isRollbackInProgress && ready.previouslyTakenEpcs.contains(epc)) {
    return ready.rfidReadEpcs.contains(epc) ? _ItemStatus.restored : _ItemStatus.awaitingReturn;
  }

  if (ready.takenEpcs.contains(epc)) return _ItemStatus.taken;
  if (ready.notFoundEpcs.contains(epc)) return _ItemStatus.notFound;
  if (ready.rfidReadEpcs.contains(epc)) return _ItemStatus.inCabinet;
  // Baseline öncesi default — inCabinet'a yakın görsel
  return _ItemStatus.inCabinet;
}

class _ItemsList extends ConsumerWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final ready = state.readyContext;
    if (ready == null) return const SizedBox.shrink();

    final isRollbackInProgress = state is MobileIntakeRollbackInProgress;

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

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.status});

  final PrescriptionItem item;
  final _ItemStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bg, border, textColor, mutedColor, badgeBg, badgeFg, badgeLabel, badgeIcon) = switch (status) {
      _ItemStatus.taken => (
        MedColors.greenLight,
        MedColors.green.withValues(alpha: 0.3),
        MedColors.green,
        MedColors.green.withValues(alpha: 0.8),
        MedColors.green,
        MedColors.greenLight,
        'Alındı',
        PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      ),
      _ItemStatus.inCabinet => (
        MedColors.blueLight,
        MedColors.blue.withValues(alpha: 0.3),
        MedColors.blue,
        MedColors.blue.withValues(alpha: 0.8),
        MedColors.blue.withValues(alpha: 0.3),
        MedColors.blue,
        'Kabinde',
        PhosphorIcons.package(PhosphorIconsStyle.bold),
      ),
      _ItemStatus.notFound => (
        MedColors.amberLight,
        MedColors.amber.withValues(alpha: 0.3),
        MedColors.amber,
        MedColors.amber.withValues(alpha: 0.8),
        MedColors.amber,
        MedColors.amberLight,
        'Bulunamadı',
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
      ),
      _ItemStatus.restored => (
        MedColors.greenLight,
        MedColors.green.withValues(alpha: 0.3),
        MedColors.green,
        MedColors.green.withValues(alpha: 0.8),
        MedColors.green,
        MedColors.greenLight,
        'Geri Kondu',
        PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
      ),
      _ItemStatus.awaitingReturn => (
        MedColors.redLight,
        MedColors.red.withValues(alpha: 0.3),
        MedColors.red,
        MedColors.red.withValues(alpha: 0.8),
        MedColors.red,
        MedColors.redLight,
        'Geri Konmalı',
        PhosphorIcons.arrowUDownLeft(PhosphorIconsStyle.bold),
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

    // Manuel eksik stok bildirimi yalnızca RFID'siz item'larda (mutex §7.2).
    // RFID'li item'lar otomatik akışta (notFound → complete'te gider).
    final isNonRfid = status == _ItemStatus.nonRfid;
    final ready = ref.watch(mobileIntakeNotifierProvider).readyContext;
    final isReported = ready != null && item.id != null && ready.reportedMissingItemIds.contains(item.id);
    final isReporting = ready != null && item.id != null && ready.reportingItemIds.contains(item.id);

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
          // ── Manuel eksik stok bildirimi (yalnızca RFID'siz) ──────────
          if (isNonRfid && item.id != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: context.width,
              child: isReported
                  ? _ItemBadge(
                      label: 'Eksik Bildirildi',
                      icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
                      bg: MedColors.amberLight,
                      fg: MedColors.amber,
                    )
                  : MedButton(
                      label: isReporting ? 'Bildiriliyor...' : 'Eksik Stok Bildir',
                      size: MedButtonSize.sm,
                      variant: MedButtonVariant.danger,
                      isLoading: isReporting,
                      onPressed: isReporting
                          ? null
                          : () => ref.read(mobileIntakeNotifierProvider.notifier).reportMissingStock(item.id!),
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
