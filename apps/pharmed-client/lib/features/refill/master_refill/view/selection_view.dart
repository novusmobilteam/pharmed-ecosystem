part of 'master_refill_view.dart';

class MasterRefillSelectionView extends StatelessWidget {
  const MasterRefillSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterRefillNotifier>(
      builder: (context, notifier, child) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: CabinOperationWidget(
                groups: notifier.groups,
                assignments: notifier.assignments,
                selectedUnitIds: notifier.selectedUnitIds,
                onCellTap: notifier.onCellTap,
                onDrawerTap: (g) => notifier.onDrawerTap(g),
              ),
            ),
            VerticalDivider(color: MedColors.text3, width: 1, thickness: 1),
            Expanded(
              flex: 7,
              child: CabinOperationSelectionView(
                title: 'İlaç Dolum',
                onSearch: notifier.onSearchChanged,
                assignments: notifier.visibleAssignments,
                isAllSelected: notifier.isAllSelected,
                toggleSelectAll: notifier.toggleSelectAll,
                onAssignmentTap: notifier.onAssignmentTap,
                isAssignmentSelected: notifier.isAssignmentSelected,
                footer: Align(
                  alignment: Alignment.centerRight,
                  child: MedRectangleButton(
                    width: 250,
                    label: context.l10n.refill_action_start,
                    onTap: () => notifier.startRefill(),
                    isActive: notifier.canStart,
                    foregroundColor: Colors.white,
                    suffixIcon: PhosphorIcons.arrowRight(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
