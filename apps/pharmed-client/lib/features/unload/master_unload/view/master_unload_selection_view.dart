import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_unload_execution_notifier.dart';
import '../notifier/master_unload_selection_notifier.dart';

class MasterUnloadSelectionView extends ConsumerWidget {
  const MasterUnloadSelectionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterUnloadSelectionNotifierProvider);
    final items = selection.visibleAssignments;

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
      left: CabinOverviewSelectionPanel(
        cabin: cabinContext.cabin,
        groups: cabinContext.cabinData?.groups ?? const [],
        assignments: selection.assignments,
        selectedUnitIds: selection.selectedUnitIds,
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
        searchHint: context.l10n.unload_hint_searchMedicine,
        isEmpty: items.isEmpty,
        emptyMessage: context.l10n.unload_hint_noMedicineFound,
        content: items.isEmpty
            ? null
            : CabinAssignmentListView(
                items: items,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: selection.toggleUnit,
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
