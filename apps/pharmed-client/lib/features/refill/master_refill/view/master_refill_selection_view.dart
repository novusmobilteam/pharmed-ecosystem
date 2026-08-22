import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../../refill.dart';

class MasterRefillSelectionView extends ConsumerWidget {
  const MasterRefillSelectionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final cabin = cabinContext.cabin;
    final groups = cabinContext.cabinData?.groups;
    final menu = cabinContext.menu;

    final selection = switch (state) {
      MasterRefillSelection s => s,
      MasterRefillError(previousState: MasterRefillSelection s) => s,
      _ => null,
    };

    if (selection == null) return const SizedBox.shrink();

    return CabinOperationSelectionLayout(
      isLoading: state is MasterRefillLoading,
      left: Column(
        children: [
          Expanded(
            child: CabinOverviewSelectionPanel(
              cabin: cabin,
              onChangeCabin: () => ref.read(dashboardNotifierProvider.notifier).changeCabin(),
              groups: groups ?? [],
              assignments: selection.medicines,
              selectedUnitIds: selection.selectedUnitIds,
              onDrawerTap: notifier.toggleDrawer,
              onCellTap: (unit) {
                final id = unit.id;
                if (id == null) return;
                notifier.toggleUnit(id);
              },
            ),
          ),
        ],
      ),

      right: CabinSelectionContentShell(
        menu: menu,
        searchQuery: selection.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        isEmpty: selection.visibleMedicines.isEmpty,
        searchHint: context.l10n.intake_hint_searchMedicine,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: selection.visibleMedicines.isEmpty
            ? null
            : CabinAssignmentListView(
                items: selection.visibleMedicines,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: notifier.toggleUnit,
              ),
        footer: selection.selectedAssignments.isNotEmpty
            ? MedButton(
                label: context.l10n.refill_action_startAuto,
                onPressed: notifier.startAutoRefill,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.lg,
                variant: MedButtonVariant.primary,
              )
            : null,
      ),
    );
  }
}
