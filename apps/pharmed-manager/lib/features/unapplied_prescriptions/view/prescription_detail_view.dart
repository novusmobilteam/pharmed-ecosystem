part of 'unapplied_prescriptions_screen.dart';

void showPrescriptionDetailView(BuildContext context, {required Prescription prescription}) {
  final notifier = context.read<UnappliedPrescriptionsNotifier>();

  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(value: notifier, child: const PrescriptionDetailView()),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.getUnappliedPrescriptionDetail(prescription.id ?? 0);
  });
}

class PrescriptionDetailView extends StatelessWidget {
  const PrescriptionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnappliedPrescriptionsNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          title: 'Malzeme Listesi',
          width: context.width * 0.7,
          height: 1000,
          isLoading: notifier.isFetching,
          child: UnifiedTableView<PrescriptionItem>(
            data: notifier.prescriptionItems,
            isLoading: notifier.isFetchingDetail,
            enableSearch: false,
            enableExcel: true,
            exportFileName: 'Recete_Malzemeleri',
            horizontalScroll: true,
            minTableWidth: 3000,
          ),
        );
      },
    );
  }
}
