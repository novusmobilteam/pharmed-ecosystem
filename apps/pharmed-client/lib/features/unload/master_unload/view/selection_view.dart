part of 'master_unload_view.dart';

class MasterUnloadSelectionView extends StatelessWidget {
  const MasterUnloadSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterUnloadNotifier>(
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
                title: 'İlaç Boşaltma',
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
                    label: 'Boşaltmayı Başlat',
                    onTap: () => notifier.startUnload(),
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
