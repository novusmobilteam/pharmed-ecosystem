part of 'medicine_management_view.dart';

// Orderlı işlem yaparken kullanılan view
class HospitalizationGridView extends StatelessWidget {
  const HospitalizationGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineManagementNotifier>(
      builder: (context, notifier, child) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 200,
          ),
          itemCount: notifier.filteredItems.length,
          itemBuilder: (BuildContext context, int index) {
            final hosp = notifier.filteredItems.elementAt(index);
            return GestureDetector(
              onTap: () => _showOperationSelectionView(context, notifier, hospitalization: hosp),
              child: HospitalizationCard(
                hospitalization: hosp,
                isSelected: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showOperationSelectionView(
    BuildContext context,
    MedicineManagementNotifier notifier, {
    required Hospitalization hospitalization,
  }) async {
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => OperationSelectionView(
        hospitalization: hospitalization,
        withdrawType: notifier.viewOrderStatus.withdrawType,
      ),
    );
  }
}
