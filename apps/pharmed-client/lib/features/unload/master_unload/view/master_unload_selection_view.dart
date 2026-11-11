import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_execution_notifier.dart';
import '../notifier/master_unload_selection_notifier.dart';

class MasterUnloadSelectionView extends ConsumerWidget {
  const MasterUnloadSelectionView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterUnloadSelectionNotifierProvider);
    final items = selection.visibleAssignments;
    final scope = selection.scope;

    SearchDataSource<Medicine> equivalentsSource(int medicineId) => (skip, take, search) async {
      final result = await ref
          .read(getEquivalentMedicinesUseCaseProvider)
          .execute(
            medicineId,
            params: PagedQueryParams(skip: skip, take: take, searchQuery: search),
          );
      return result.when(ok: Result.ok, error: Result.error);
    };

    SearchDataSource<Medicine> allMedicinesSource() => (skip, take, search) async {
      final result = await ref
          .read(getMedicinesUseCaseProvider)
          .call(PagedQueryParams(skip: skip, take: take, searchQuery: search));
      return result.when(ok: Result.ok, error: Result.error);
    };

    void showSuccess() {
      if (context.mounted) MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
    }

    void showFailure(String? message) {
      if (context.mounted) MessageUtils.showErrorSnackbar(context, message);
    }

    return CabinOperationSelectionLayout(
      isLoading: selection.isLoadingAssignments,
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
          onDrawerTap: selection.toggleDrawer,
          onCellTap: (unit) {
            final id = unit.id;
            if (id != null) selection.toggleUnit(id);
          },
          selectedCellIds: selection.selectedSerumCellIds,
          onSerumTrayTap: (shelf, tray) {
            final id = tray.id;
            if (id == null) return;
            if (!tray.size.isOpenShelf) {
              selection.toggleSerumTray(id);
              return;
            }
            // Açık Raf: raftaki ilaçlar listelenir, her biri ayrı seçilir.
            showOpenShelfDialog(
              context: context,
              shelfNo: shelf.orderNo ?? 0,
              assignments: AssignmentSelection.serumAssignments(id, selection.assignments),
              isSelected: selection.isSelected,
                canSelect: selection.canSelect,
              onToggle: selection.toggleAssignment,
            );
          },
        ),
      ),
      right: CabinSelectionContentShell(
        menu: menu,
        extra: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: StationCabinFilterBar(
            cabins: scope.cabins,
            selectedCabinId: scope.cabinFilter,
            onChanged: selection.setCabinFilter,
          ),
        ),
        searchQuery: selection.search,
        onSearchQueryChanged: selection.onSearchChanged,
        searchHint: context.l10n.unload_hint_searchMedicine,
        isEmpty: items.isEmpty,
        emptyMessage: context.l10n.unload_hint_noMedicineFound,
        content: items.isEmpty
            ? null
            : CabinAssignmentListView(
                items: items,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: selection.toggleUnit,
                selectedCellIds: selection.selectedSerumCellIds,
                onToggleCell: selection.toggleSerumTray,
                isAssignmentSelected: selection.isSelected,
                onToggleAssignment: selection.toggleAssignment,
                cabinLabelOf: scope.cabins.length > 1 ? scope.cabinNameOf : null,
                onDelete: (assignment) => MessageUtils.showConfirmDeleteDialog(
                  context: context,
                  itemName: assignment.medicine?.name,
                  onConfirm: () =>
                      selection.deleteAssignment(assignment, onSuccess: showSuccess, onFailed: showFailure),
                ),
                onReplace: (assignment) async {
                  final medicineId = assignment.medicine?.id;
                  if (medicineId == null) return;

                  final selected = await SelectionDialog.showWithFallback<Medicine>(
                    context,
                    title: context.l10n.unload_replaceMedicine_dialogTitle,
                    primaryDataSource: equivalentsSource(medicineId),
                    secondaryDataSource: allMedicinesSource(),
                    secondaryToggleLabel: context.l10n.unload_replaceMedicine_allMedicinesButton,
                    labelBuilder: (m) => m.name,
                  );
                  if (selected == null || !context.mounted) return;

                  selection.replaceAssignment(assignment, selected, onSuccess: showSuccess, onFailed: showFailure);
                },
              ),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.unload_action_start,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                onPressed: () => selection.startUnload(
                  onQueueReady: (jobs, skipped) {
                    ref.read(masterUnloadExecutionNotifierProvider).start(jobs);
                  },
                  onFailed: (failure) => MessageUtils.showErrorSnackbar(context, failure.message(context)),
                ),
              )
            : null,
      ),
    );
  }
}
