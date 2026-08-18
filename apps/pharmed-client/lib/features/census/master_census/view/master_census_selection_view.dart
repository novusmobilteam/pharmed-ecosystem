import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/master_census_notifier.dart';
import '../notifier/master_census_state.dart';

class MasterCensusSelectionView extends ConsumerWidget {
  const MasterCensusSelectionView({super.key, required this.allGroups, required this.menu});

  final List<DrawerGroup> allGroups;
  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterCensusNotifierProvider);
    final notifier = ref.read(masterCensusNotifierProvider.notifier);

    final selection = switch (state) {
      MasterCensusSelection s => s,
      MasterCensusError(previousState: MasterCensusSelection s) => s,
      _ => null,
    };

    if (selection == null) return const SizedBox.shrink();

    final isDrawerMode = selection.censusMode == CensusMode.byDrawer;
    final isMedicineMode = selection.censusMode == CensusMode.byMedicine;

    return CabinOperationSelectionLayout(
      leftWidth: 320,
      isLoading: state is MasterCensusLoading,
      left: CabinOverviewSelectionPanel(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onDrawerTap: isDrawerMode ? notifier.toggleDrawer : null,
        onCellTap: (unit) {
          final id = unit.id;
          if (id == null) return;
          notifier.toggleUnit(id);
        },
      ),

      // TODO : Localization
      right: CabinSelectionContentShell(
        menu: menu,
        extra: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SizedBox(
            width: 600,
            child: MedSegmentedButton(
              labels: const ['Tüm Kabin', 'Çekmece Bazlı', 'İlaç Bazlı'],
              selectedIndex: CensusMode.values.indexOf(selection.censusMode),
              onChanged: (index) => notifier.setCensusMode(CensusMode.values[index]),
            ),
          ),
        ),
        onSearchQueryChanged: notifier.onSearchChanged,
        searchQuery: selection.search,
        searchHint: context.l10n.intake_hint_searchMedicine,
        isEmpty: selection.visibleMedicines.isEmpty,
        emptyMessage: context.l10n.census_hint_noMedicines,
        content: selection.visibleMedicines.isEmpty
            ? null
            : CabinAssignmentListView(
                items: selection.visibleMedicines,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: isMedicineMode ? notifier.toggleUnit : null,
              ),
        footer: selection.selectedAssignments.isNotEmpty
            ? MedButton(
                label: context.l10n.census_action_start,
                onPressed: selection.canStart ? notifier.startCensus : null,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.md,
                variant: MedButtonVariant.primary,
              )
            : null,
      ),
    );
  }
}
