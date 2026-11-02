import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_census_execution_notifier.dart';
import '../notifier/master_census_selection_notifier.dart';

class MasterCensusSelectionView extends ConsumerWidget {
  const MasterCensusSelectionView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterCensusSelectionNotifierProvider);
    final isDrawerMode = selection.censusMode == CensusMode.byDrawer;
    final isMedicineMode = selection.censusMode == CensusMode.byMedicine;
    final visible = selection.visibleAssignments;
    final scope = selection.scope;

    return CabinOperationSelectionLayout(
      isLoading: selection.isLoadingAssignments,
      flex: 3,
      left: StationCabinSelectionPanel(
        cabins: scope.cabins,
        viewedCabinId: scope.viewedCabinId,
        selectedCountByCabin: selection.selectedCountByCabin,
        onCabinTap: selection.viewCabin,
        interior: CabinOverviewSelectionPanel(
          key: ValueKey(scope.viewedCabinId),
          cabin: scope.viewedCabin,
          groups: scope.viewedGroups,
          assignments: selection.assignments,
          selectedUnitIds: selection.selectedUnitIds,
          onDrawerTap: isDrawerMode ? selection.toggleDrawer : null,
          onCellTap: (unit) {
            final id = unit.id;
            if (id != null) selection.toggleUnit(id);
          },
          selectedCellIds: selection.selectedSerumCellIds,
          onSerumTrayTap: (_, tray) {
            final id = tray.id;
            if (id != null) selection.toggleSerumTray(id);
          },
        ),
      ),
      right: CabinSelectionContentShell(
        menu: menu,
        extra: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(
                child: MedSegmentedButton(
                  labels: [
                    context.l10n.census_mode_byMedicine,
                    context.l10n.census_mode_byDrawer,
                    context.l10n.census_mode_allCabin,
                  ],
                  selectedIndex: CensusMode.values.indexOf(selection.censusMode),
                  onChanged: (index) => selection.setCensusMode(CensusMode.values[index]),
                ),
              ),
              if (scope.cabins.length > 1)
                Expanded(
                  child: StationCabinFilterBar(
                    cabins: scope.cabins,
                    selectedCabinId: scope.cabinFilter,
                    onChanged: selection.setCabinFilter,
                  ),
                ),
            ],
          ),
        ),
        onSearchQueryChanged: selection.onSearchChanged,
        searchQuery: selection.search,
        searchHint: context.l10n.intake_hint_searchMedicine,
        isEmpty: visible.isEmpty,
        emptyMessage: context.l10n.census_hint_noMedicines,
        content: visible.isEmpty
            ? null
            : CabinAssignmentListView(
                items: visible,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: isMedicineMode ? selection.toggleUnit : null,
                selectedCellIds: selection.selectedSerumCellIds,
                onToggleCell: isMedicineMode ? selection.toggleSerumTray : null,
                cabinLabelOf: scope.cabins.length > 1 ? scope.cabinNameOf : null,
              ),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.census_action_start,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.md,
                variant: MedButtonVariant.primary,
                onPressed: () => selection.startCensus(
                  onQueueReady: (jobs, skipped) {
                    ref.read(masterCensusExecutionNotifierProvider).start(jobs);
                  },
                  onFailed: (failure) => MessageUtils.showErrorSnackbar(context, failure.message(context)),
                ),
              )
            : null,
      ),
    );
  }
}
