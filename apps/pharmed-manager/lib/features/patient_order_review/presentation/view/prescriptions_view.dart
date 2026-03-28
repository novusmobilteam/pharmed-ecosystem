part of 'patient_order_review_view.dart';

void showPrescriptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<PatientOrderReviewNotifier>(),
      child: const PrescriptionsView(),
    ),
  );
}

class PrescriptionsView extends StatefulWidget {
  const PrescriptionsView({super.key});

  @override
  State<PrescriptionsView> createState() => _PrescriptionsViewState();
}

class _PrescriptionsViewState extends State<PrescriptionsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PatientOrderReviewNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          title: 'Hastaya Verilmiş İstemler',
          width: context.width * 0.9,
          showSearch: true,
          onSearchChanged: (value) => notifier.setPrescriptionSearchQuery(value),
          child: _buildContent(notifier),
        );
      },
    );
  }

  Widget _buildContent(PatientOrderReviewNotifier notifier) {
    if (notifier.filteredGroupedPrescriptions.isEmpty) {
      return Center(
        child: CommonEmptyStates.noData(),
      );
    }

    return ListView.separated(
      itemCount: notifier.filteredGroupedPrescriptions.length,
      itemBuilder: (context, index) {
        final prescriptionId = notifier.groupedPrescriptions.keys.elementAt(index);
        final items = notifier.groupedPrescriptions[prescriptionId]!;

        return PrescriptionGroupCard(
          items: items,
          prescriptionId: prescriptionId,
        );
      },
      separatorBuilder: (context, index) => Padding(padding: EdgeInsets.only(bottom: 8.0)),
    );
  }
}
