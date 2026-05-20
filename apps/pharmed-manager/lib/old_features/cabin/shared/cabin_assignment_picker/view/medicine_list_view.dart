part of 'cabin_assignment_picker_view.dart';

class MedicineListView extends StatelessWidget {
  const MedicineListView({super.key, required this.type});

  final CabinInventoryType type;

  @override
  Widget build(BuildContext context) {
    return Consumer<CabinAssignmentPickerNotifier>(
      builder: (context, notifier, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: notifier.filteredItems.length,
          itemBuilder: (context, index) {
            final item = notifier.filteredItems[index];
            final medicine = item.medicine;
            final isExpanded = notifier.expandedMedicineId == medicine?.id;

            return Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              margin: EdgeInsets.only(bottom: 6.0),
              decoration: AppDimensions.cardDecoration(context),
              child: ExpansionTile(
                key: PageStorageKey(medicine?.id),
                initiallyExpanded: isExpanded,
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
                collapsedShape: RoundedRectangleBorder(
                  side: BorderSide.none,
                ),
                onExpansionChanged: (_) => notifier.toggleExpansion(medicine.id!),
                title: Text(
                  medicine?.name ?? '-',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExpanded ? context.colorScheme.primary : context.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  medicine?.barcode ?? '-',
                  style: context.textTheme.labelSmall,
                ),
                children: [
                  _buildDrawersGrid(context, notifier, medicine!.id!),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawersGrid(BuildContext context, CabinAssignmentPickerNotifier vm, int medicineId) {
    final assignments = vm.getAssignmentsForMedicine(medicineId);

    return Column(
      children: assignments.map((assignment) {
        final isSelected = vm.selectedAssignmentIds.contains(assignment.id);
        final overrideQuantity = assignment.toDisplayQuantity(assignment.totalQuantity);

        return InkWell(
          onTap: () => vm.toggleDrawerSelection(assignment.id!),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? context.colorScheme.primaryContainer.withAlpha(125) : context.colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      assignment.isKubikType ? 'Kübik Çekmece' : 'Birim Doz Çekmece',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => vm.toggleDrawerSelection(assignment.id!),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                RatioProgressIndicator(
                  assignment: assignment,
                  overrideQuantity: overrideQuantity,
                ),
                if (type == CabinInventoryType.refillList)
                  Text(
                    'Dolum Yapılacak Miktar: ${assignment.fillingQuantity?.formatFractional}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
