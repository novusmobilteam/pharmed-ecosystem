import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../widgets/widgets.dart';
import '../../../refill.dart';

class MasterRefillSelectionPanel extends ConsumerWidget {
  const MasterRefillSelectionPanel({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);

    // RootScaffold, bu widget'ı yalnızca RootSelection fazındayken build
    // eder — yani state burada her zaman MasterRefillSelection ya da
    // MasterRefillError(previousState: MasterRefillSelection) olur.
    final selection = switch (state) {
      MasterRefillSelection s => s,
      MasterRefillError(previousState: MasterRefillSelection s) => s,
      _ => null,
    };

    // Savunma amaçlı — normalde buraya düşülmemeli (bkz. yukarıdaki not).
    if (selection == null) return const SizedBox.shrink();

    return CabinOperationPanelLayout(
      left: CabinDrawerSelectionGuide(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onToggleDrawer: notifier.toggleDrawer,
      ),
      right: CabinSelectionContentShell(
        onSearchQueryChanged: notifier.onSearchChanged,
        searchQuery: selection.search,
        isEmpty: selection.visibleMedicines.isEmpty,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: selection.visibleMedicines.isEmpty
            ? null
            : _GridView(
                items: selection.visibleMedicines,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: notifier.toggleUnit,
              ),
        footer: selection.selectedAssignments.isNotEmpty
            ? MedButton(
                label: context.l10n.refill_action_startAuto,
                onPressed: notifier.startAutoRefill,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.md,
                variant: MedButtonVariant.primary,
              )
            : null,
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  const _GridView({required this.items, required this.selectedItemIds, required this.onToggle});

  final List<MedicineAssignment> items;
  final Set<int> selectedItemIds;
  final ValueChanged<int>? onToggle;

  @override
  Widget build(BuildContext context) {
    // Gözleri medicine.id sırasını koruyarak düz listeye aç.
    final ordered = <MedicineAssignment>[];
    final seen = <int>{};
    for (final a in items) {
      final mid = a.medicine?.id;
      if (mid == null) continue;
      if (!seen.contains(mid)) {
        seen.add(mid);
        ordered.addAll(items.where((x) => x.medicine?.id == mid));
      }
    }

    return CabinOperationCellGrid(
      itemCount: ordered.length,
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
      selected: id != null && selectedItemIds.contains(id),
      onTap: (id == null || onToggle == null) ? null : () => onToggle!(id),
    );
  }
}
