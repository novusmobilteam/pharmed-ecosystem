import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_refill_execution_notifier.dart';
import '../notifier/master_refill_selection_notifier.dart';

/// İstasyon geneli dolum seçimi: solda kabin şeridi + görüntülenen kabinin
/// iç yerleşimi, sağda tüm kabinlerin ilaç listesi.
class MasterRefillSelectionView extends ConsumerWidget {
  const MasterRefillSelectionView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(masterRefillSelectionNotifierProvider);
    final scope = selection.scope;
    final visible = selection.visibleAssignments;

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
                cabinLabelOf: scope.cabins.length > 1 ? scope.cabinNameOf : null,
                showMiad: true,
              ),
        footer: selection.canStart
            ? MedButton(
                label: context.l10n.refill_action_startAuto,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.lg,
                variant: MedButtonVariant.primary,
                onPressed: () => selection.startRefill(
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
