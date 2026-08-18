import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';

class MasterUnloadSelectionView extends ConsumerWidget {
  const MasterUnloadSelectionView({super.key, required this.allGroups, required this.menu});

  final List<DrawerGroup> allGroups;
  final MenuItem menu;

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
      left: CabinOverviewSelectionPanel(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onDrawerTap: notifier.toggleDrawer,
        onCellTap: (unit) {
          final id = unit.id;
          if (id == null) return;
          notifier.toggleUnit(id);
        },
      ),

      right: CabinSelectionContentShell(
        menu: menu,
        searchQuery: selection.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        searchHint: context.l10n.unload_hint_searchMedicine,
        isEmpty: items.isEmpty,
        emptyMessage: context.l10n.unload_hint_noMedicineFound,
        content: items.isEmpty
            ? null
            : CabinAssignmentListView(
                items: items,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: notifier.toggleUnit,
              ),
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
