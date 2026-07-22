// [SWREQ-CLI-MCENSUS-002] [IEC 62304 §5.5]
// Sayım seçim ekranı. allGroups artık dışarıdan (View'dan, execution
// panel'deki gibi) geliyor — state taşımıyor.
//
// Sınıf: Class B

part of 'master_census_view.dart';

class MasterCensusSelectionPanel extends ConsumerWidget {
  const MasterCensusSelectionPanel({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterCensusNotifierProvider);
    final notifier = ref.read(masterCensusNotifierProvider.notifier);

    final selection = switch (state) {
      MasterCensusSelection s => s,
      MasterCensusError(previousState: MasterCensusSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    return CabinOperationBody(
      locationGuide: CabinDrawerSelectionGuide(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onToggleDrawer: notifier.toggleDrawer,
      ),
      child: CabinSelectionPanelShell(
        onSearchQueryChanged: notifier.onSearchChanged,
        searchQuery: selection.search,
        content: selection.visibleMedicines.isEmpty
            ? EmptyStateWidget(title: context.l10n.census_hint_noMedicines)
            : _CensusSlotGrid(selection: selection, notifier: notifier),
        footer: MedButton(
          label: context.l10n.census_action_start,
          onPressed: selection.canStart ? notifier.startCensus : null,
          suffixIcon: Icon(PhosphorIcons.arrowRight()),
          size: MedButtonSize.md,
          variant: MedButtonVariant.primary,
        ),
      ),
    );
  }
}

class _CensusSlotGrid extends StatelessWidget {
  const _CensusSlotGrid({required this.selection, required this.notifier});

  final MasterCensusSelection selection;
  final MasterCensusNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
