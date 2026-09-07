import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';

class MasterUnloadSelectionView extends ConsumerWidget {
  const MasterUnloadSelectionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterUnloadNotifierProvider);
    final notifier = ref.read(masterUnloadNotifierProvider.notifier);
    final cabin = cabinContext.cabin;
    final groups = cabinContext.cabinData?.groups;
    final menu = cabinContext.menu;

    final selection = switch (state) {
      MasterUnloadSelection s => s,
      MasterUnloadError(previousState: MasterUnloadSelection s) => s,
      _ => null,
    };
    if (selection == null) return const SizedBox.shrink();

    final items = selection.visibleMedicines;

    SearchDataSource<Medicine> _equivalentsSource(int medicineId) {
      return (skip, take, search) async {
        final result = await ref
            .read(getEquivalentMedicinesUseCaseProvider)
            .execute(
              medicineId,
              params: PagedQueryParams(skip: skip, take: take, searchQuery: search),
            );
        return result.when(ok: (response) => Result.ok(response), error: (e) => Result.error(e));
      };
    }

    SearchDataSource<Medicine> _allMedicinesSource() {
      return (skip, take, search) async {
        final result = await ref
            .read(getMedicinesUseCaseProvider)
            .call(PagedQueryParams(skip: skip, take: take, searchQuery: search));
        return result.when(ok: (response) => Result.ok(response), error: (e) => Result.error(e));
      };
    }

    return CabinOperationSelectionLayout(
      left: CabinOverviewSelectionPanel(
        cabin: cabin,
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
                onDelete: (assignment) => MessageUtils.showConfirmDeleteDialog(
                  context: context,
                  itemName: assignment.medicine?.name,
                  onConfirm: () => notifier.deleteAssignment(
                    assignment,
                    onSuccess: (_) {
                      if (!context.mounted) return;
                      MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                    },
                    onFailed: (msg) {
                      if (!context.mounted) return;
                      MessageUtils.showErrorSnackbar(context, msg);
                    },
                  ),
                ),

                onReplace: (assignment) async {
                  final medicineId = assignment.medicine?.id;
                  if (medicineId == null) return;

                  final selected = await SelectionDialog.showWithFallback<Medicine>(
                    context,
                    title: context.l10n.unload_replaceMedicine_dialogTitle,
                    primaryDataSource: _equivalentsSource(medicineId),
                    secondaryDataSource: _allMedicinesSource(),
                    secondaryToggleLabel: context.l10n.unload_replaceMedicine_allMedicinesButton,
                    labelBuilder: (m) => m.name,
                  );

                  if (selected == null || !context.mounted) return;
                  notifier.replaceAssignment(
                    assignment,
                    selected,
                    onSuccess: (_) {
                      if (!context.mounted) return;
                      MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                    },
                    onFailed: (msg) {
                      if (!context.mounted) return;
                      MessageUtils.showErrorSnackbar(context, msg);
                    },
                  );
                },
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
