part of 'master_refill_view.dart';

class MasterRefillSelectionPanel extends ConsumerWidget {
  const MasterRefillSelectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);

    final selection = switch (state) {
      MasterRefillSelection s => s,
      MasterRefillError(previousState: MasterRefillSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    return CabinSelectionPanelShell(
      onSearchQueryChanged: notifier.onSearchChanged,
      searchQuery: selection.search,

      content: selection.visibleMedicines.isEmpty
          ? EmptyStateWidget(title: context.l10n.refill_hint_noMedicines)
          : _SlotGrid(selection: selection, notifier: notifier),
      footer: MedButton(
        label: context.l10n.refill_action_startAuto,
        onPressed: notifier.startAutoRefill,
        suffixIcon: Icon(PhosphorIcons.arrowRight()),
        size: MedButtonSize.md,
        variant: MedButtonVariant.primary,
      ),
    );
  }
}

// ── Göz grid'i (medicine.id bazında sıralı, düz göz kartları) ───────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.selection, required this.notifier});

  final MasterRefillSelection selection;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Gözleri medicine.id sırasını koruyarak düz listeye aç.
    final ordered = <MedicineAssignment>[];
    final seen = <int>{};
    for (final a in selection.visibleMedicines) {
      final mid = a.medicine?.id;
      if (mid == null) continue;
      if (!seen.contains(mid)) {
        seen.add(mid);
        ordered.addAll(selection.visibleMedicines.where((x) => x.medicine?.id == mid));
      }
    }

    return CabinOperationCellGrid(
      itemCount: ordered.length,
      singleColumnThreshold: 0,
      targetItemWidth: 300,
      gap: 14,
      minColumns: 1,
      maxColumns: 4,
      itemBuilder: (context, i) => _slotCard(context, ordered[i]),
    );
  }

  Widget _slotCard(BuildContext context, MedicineAssignment a) {
    final slot = a.drawerUnit?.drawerSlot;
    final cellNo = a.drawerUnit?.orderNo ?? a.drawerUnit?.compartmentNo;
    final address = slot?.address ?? '?';
    final isKubik = a.isKubikType;

    final current = a.toDisplayQuantity(a.totalQuantity);
    final maxQty = a.maxQuantityFromBackend;
    final critQty = a.critQuantityFromBackend;
    final minQty = a.minQuantityFromBackend;

    final statusLabel = current <= critQty
        ? context.l10n.refill_status_stockCritical
        : (current <= minQty ? context.l10n.refill_status_stockLow : context.l10n.refill_status_stockOk);

    final addressLabel = isKubik
        ? context.l10n.refill_chip_drawerCell(address, '${cellNo ?? '-'}')
        : context.l10n.refill_chip_drawer(address);

    final id = a.cabinDrawerId;

    return CabinSelectionGridCard(
      title: a.medicine?.name ?? '—',
      addressLabel: addressLabel,
      current: current,
      maxQty: maxQty,
      minQty: minQty,
      critQty: critQty,
      statusLabel: statusLabel,
      selected: id != null && selection.selectedUnitIds.contains(id),
      onTap: id == null ? null : () => notifier.toggleUnit(id),
    );
  }
}
