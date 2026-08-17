part of 'master_census_view.dart';

class MasterCensusSelectionView extends StatelessWidget {
  const MasterCensusSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterCensusNotifier>(
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
                title: 'İlaç Sayım',
                onSearch: notifier.onSearchChanged,
                assignments: notifier.visibleAssignments,
                isAllSelected: notifier.isAllSelected,
                showSearch: notifier.mode == CensusMode.byMedicine,
                toggleSelectAll: notifier.mode != CensusMode.wholeCabin ? notifier.toggleSelectAll : null,
                onAssignmentTap: notifier.mode != CensusMode.byMedicine ? null : notifier.onAssignmentTap,
                isAssignmentSelected: notifier.isAssignmentSelected,

                footer: Align(
                  alignment: Alignment.centerRight,
                  child: MedRectangleButton(
                    width: 250,
                    label: 'Sayımı Başlat',
                    onTap: () => notifier.startCensus(),
                    isActive: notifier.canStart,
                    foregroundColor: Colors.white,
                    suffixIcon: PhosphorIcons.arrowRight(),
                  ),
                ),
                extra: Row(
                  children: List.generate(CensusMode.values.length, (index) {
                    final mode = CensusMode.values.elementAt(index);
                    final isSelected = notifier.mode == mode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => notifier.setCensusMode(mode),
                        child: Container(
                          padding: MedSpacing.insetLg,
                          decoration: BoxDecoration(
                            color: isSelected ? MedColors.blue : null,
                            border: Border(bottom: BorderSide(), left: BorderSide()),
                          ),
                          height: 70,
                          child: Column(
                            spacing: 4.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mode.title, style: MedTextStyles.titleLg(color: isSelected ? Colors.white : null)),
                              Text(
                                mode.description,
                                style: MedTextStyles.bodyMd(color: isSelected ? Colors.white : null),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
