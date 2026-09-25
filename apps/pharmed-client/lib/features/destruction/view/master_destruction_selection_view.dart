import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../../core/hardware/hardware.dart';
import '../../dashboard/dashboard.dart';

import '../notifier/master_destruction_execution_notifier.dart';
import '../notifier/master_destruction_selection_notifier.dart';

class MasterDestructionSelectionView extends ConsumerWidget {
  const MasterDestructionSelectionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterDestructionSelectionNotifierProvider);
    final visible = selection.visibleAssignments;

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
        onSearchQueryChanged: selection.onSearchChanged,
        searchQuery: selection.search,
        isEmpty: visible.isEmpty,
        emptyMessage: context.l10n.census_hint_noMedicines,
        content: visible.isEmpty ? null : _AssignmentGrid(items: visible, selection: selection),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.waste_action_destruction,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.md,
                variant: MedButtonVariant.secondary,
                onPressed: () => selection.startDestruction(
                  onQueueReady: (jobs, skipped) {
                    ref.read(masterDestructionExecutionNotifierProvider).start(jobs);
                  },
                  onFailed: (failure) => MessageUtils.showErrorSnackbar(context, failure.message(context)),
                ),
              )
            : null,
      ),
    );
  }
}

/// İlaçlara göre gruplanmış göz kartları — yetki ve stok kuralı notifier'dan.
class _AssignmentGrid extends StatelessWidget {
  const _AssignmentGrid({required this.items, required this.selection});

  final List<MedicineAssignment> items;
  final MasterDestructionSelectionNotifier selection;

  @override
  Widget build(BuildContext context) {
    // Aynı ilacın gözleri yan yana gelsin — ilk görülme sırasıyla.
    final ordered = <MedicineAssignment>[];
    final seen = <int>{};
    for (final a in items) {
      final medicineId = a.medicine?.id;
      if (medicineId == null || !seen.add(medicineId)) continue;
      ordered.addAll(items.where((x) => x.medicine?.id == medicineId));
    }

    return CabinOperationGrid(
      maxColumns: 3,
      itemCount: ordered.length,
      itemBuilder: (context, i) {
        final a = ordered[i];
        final id = a.cabinDrawerId;
        final isAuthorized = selection.isAuthorized(a);

        return MedicineAssignmentCard(
          assignment: a,
          selected: id != null && selection.selectedUnitIds.contains(id),
          onTap: selection.canSelect(a) ? () => selection.toggleUnit(id!) : null,
          isActive: isAuthorized,
          extra: isAuthorized
              ? const []
              : [
                  MedChip(
                    label: context.l10n.waste_hint_notAuthorized,
                    background: MedColors.red,
                    foreground: MedColors.redLight,
                    showBorder: false,
                  ),
                ],
        );
      },
    );
  }
}
