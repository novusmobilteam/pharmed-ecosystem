import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/refill_list_notifier.dart';
import '../notifier/refill_list_state.dart';
import 'refill_list_assignment_list_view.dart';
import 'refill_lists_side_panel.dart';

class RefillListSelectionView extends ConsumerWidget {
  const RefillListSelectionView({super.key, required this.stationContext});
  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(refillListNotifierProvider);
    final notifier = ref.read(refillListNotifierProvider.notifier);
    final menu = stationContext.menu;

    final selection = switch (state) {
      RefillListSelection s => s,
      RefillListError(previousState: RefillListSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    return CabinOperationSelectionLayout(
      flex: 2,
      isLoading: false,
      left: RefillListsSidePanel(
        lists: selection.lists,
        selectedListId: selection.selectedList?.id,
        onSelect: notifier.selectList,
      ),
      right: CabinSelectionContentShell(
        menu: menu,
        searchQuery: selection.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        isEmpty: selection.selectedList == null || (!selection.isDetailLoading && selection.visibleRows.isEmpty),
        searchHint: context.l10n.intake_hint_searchMedicine,
        emptyMessage: selection.selectedList == null
            ? context.l10n.refillList_hint_selectListFirst
            : context.l10n.refillList_hint_noRows,
        content: selection.isDetailLoading
            ? const Center(child: MedLoadingIndicator())
            : (selection.visibleRows.isEmpty
                  ? null
                  : RefillListAssignmentListView(
                      items: selection.visibleRows,
                      selectedDrawerIds: selection.selectedDrawerIds,
                      onToggle: notifier.toggleDrawer,
                    )),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.refillList_action_startFilling,
                onPressed: notifier.startFilling,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.lg,
                variant: MedButtonVariant.primary,
              )
            : null,
      ),
    );
  }
}
