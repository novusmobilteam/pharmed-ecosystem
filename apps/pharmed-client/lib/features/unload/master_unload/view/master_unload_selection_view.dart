import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/cabin_shell_widgets/cabin_overview_panel.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';

class MasterUnloadSelectionView extends ConsumerWidget {
  const MasterUnloadSelectionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterUnloadNotifierProvider);
    final notifier = ref.read(masterUnloadNotifierProvider.notifier);

    final selection = switch (state) {
      MasterUnloadSelection s => s,
      MasterUnloadError(previousState: MasterUnloadSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    final items = selection.visibleMedicines;

    return CabinOperationSelectionLayout(
      left: CabinOverviewPanel.selection(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onToggleDrawer: notifier.toggleDrawer,
      ),

      right: CabinSelectionContentShell(
        searchQuery: selection.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        searchHint: context.l10n.unload_hint_searchMedicine,
        isEmpty: items.isEmpty,
        emptyMessage: context.l10n.unload_hint_noMedicineFound,
        content: items.isEmpty
            ? null
            : _GridView(items: items, selectedItemIds: selection.selectedUnitIds, onToggle: notifier.toggleUnit),
        footer: selection.selectedAssignments.isNotEmpty
            ? MedButton(
                label: context.l10n.unload_action_start,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                onPressed: selection.canStart ? notifier.startUnload : null,
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

    return CabinOperationGrid(itemCount: ordered.length, itemBuilder: (context, i) => _slotCard(context, ordered[i]));
  }

  Widget _slotCard(BuildContext context, MedicineAssignment a) {
    final id = a.cabinDrawerId;

    return MedicineAssignmentCard(
      assignment: a,
      selected: id != null && selectedItemIds.contains(id),
      onTap: (id == null || onToggle == null) ? null : () => onToggle!(id),
    );
  }
}
