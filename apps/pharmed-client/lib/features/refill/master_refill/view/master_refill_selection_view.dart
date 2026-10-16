import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../notifier/master_refill_execution_notifier.dart';
import '../notifier/master_refill_selection_notifier.dart';

class MasterRefillSelectionView extends ConsumerWidget {
  const MasterRefillSelectionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterRefillSelectionNotifierProvider);
    final visible = selection.visibleAssignments;
    final groups = cabinContext.cabinData?.groups ?? const <DrawerGroup>[];

    return CabinOperationSelectionLayout(
      isLoading: selection.isLoadingAssignments,
      left: CabinOverviewSelectionPanel(
        cabin: cabinContext.cabin,
        onChangeCabin: () => ref.read(dashboardNotifierProvider.notifier).changeCabin(),
        groups: groups,
        assignments: selection.assignments,
        selectedUnitIds: selection.selectedUnitIds,
        selectedCellIds: selection.selectedSerumCellIds,
        onSerumTrayTap: (_, tray) {
          final id = tray.id;
          if (id != null) selection.toggleSerumTray(id);
        },
        onDrawerTap: selection.toggleDrawer,
        onCellTap: (unit) {
          final id = unit.id;
          if (id != null) selection.toggleUnit(id);
        },
      ),
      right: CabinSelectionContentShell(
        menu: cabinContext.menu,
        searchQuery: selection.search,
        onSearchQueryChanged: selection.onSearchChanged,
        searchHint: context.l10n.intake_hint_searchMedicine,
        isEmpty: visible.isEmpty,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: visible.isEmpty
            ? null
            : CabinAssignmentListView(
                items: visible,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: selection.toggleUnit,
                selectedCellIds: selection.selectedSerumCellIds,
                onToggleCell: selection.toggleSerumTray,
              ),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.refill_action_startAuto,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.lg,
                variant: MedButtonVariant.primary,
                onPressed: () => selection.startRefill(
                  groups: groups,
                  onQueueReady: (jobs, skipped) {
                    ref.read(masterRefillExecutionNotifierProvider).start(jobs);
                  },
                  onFailed: (failure) => MessageUtils.showErrorSnackbar(context, failure.message(context)),
                ),
              )
            : null,
      ),
    );
  }
}
