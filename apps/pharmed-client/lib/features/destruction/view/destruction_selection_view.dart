import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/cabin_overview_panel.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../auth/auth.dart';
import '../notifier/destruction_notifier.dart';
import '../notifier/destruction_state.dart';

class DestructionSelectionView extends ConsumerWidget {
  const DestructionSelectionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(destructionNotifierProvider);
    final notifier = ref.read(destructionNotifierProvider.notifier);

    final selection = switch (state) {
      DestructionSelection s => s,
      DestructionError(previousState: DestructionSelection s) => s,
      _ => null,
    };

    if (selection == null) return const SizedBox.shrink();

    return CabinOperationSelectionLayout(
      leftWidth: 320,
      isLoading: state is DestructionLoading,
      left: CabinOverviewPanel.selection(
        groups: allGroups,
        assignments: selection.medicines,
        selectedUnitIds: selection.selectedUnitIds,
        onToggleDrawer: notifier.toggleDrawer,
      ),
      right: CabinSelectionContentShell(
        onSearchQueryChanged: notifier.onSearchChanged,
        searchQuery: selection.search,
        isEmpty: selection.visibleMedicines.isEmpty,
        emptyMessage: context.l10n.census_hint_noMedicines,
        content: selection.visibleMedicines.isEmpty
            ? null
            : _GridView(
                items: selection.visibleMedicines,
                selectedItemIds: selection.selectedUnitIds,
                onToggle: notifier.toggleUnit,
              ),
        footer: selection.selectedAssignments.isNotEmpty
            ? MedButton(
                label: context.l10n.waste_action_destruction,
                onPressed: selection.canStart ? notifier.startDestruction : null,
                suffixIcon: Icon(PhosphorIcons.arrowRight()),
                size: MedButtonSize.md,
                variant: MedButtonVariant.secondary,
              )
            : null,
      ),
    );
  }
}

class _GridView extends ConsumerWidget {
  const _GridView({required this.items, required this.selectedItemIds, required this.onToggle});

  final List<MedicineAssignment> items;
  final Set<int> selectedItemIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;

    final ordered = <MedicineAssignment>[];
    final seen = <int>{};
    for (final a in items) {
      final mid = a.medicine?.id;
      if (mid == null) continue;
      if (!seen.contains(mid)) {
        seen.add(mid);
        ordered.addAll(items.where((x) => x.medicine?.id == mid));
      }
    }

    return CabinOperationGrid(
      itemCount: ordered.length,
      itemBuilder: (context, i) => _slotCard(context, ordered[i], currentUserId),
    );
  }

  Widget _slotCard(BuildContext context, MedicineAssignment a, int? currentUserId) {
    final id = a.cabinDrawerId;
    final medicine = a.medicine;

    // Drug değilse (örn. MedicalConsumable) yetki kısıtı uygulanmaz.
    final isActive = medicine is! Drug || currentUserId == null
        ? true
        : medicine.destroyableUsers.any((u) => u.id == currentUserId);

    return MedicineAssignmentCard(
      assignment: a,
      selected: id != null && selectedItemIds.contains(id),
      onTap: (id == null || !isActive) ? null : () => onToggle(id),
      isActive: isActive,
      extra: isActive
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
  }
}
