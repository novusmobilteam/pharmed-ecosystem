part of 'unapplied_prescriptions_screen.dart';

/// Yardımcı fonksiyon: Detay ekranını açar
void showPrescriptionDetailView(BuildContext context, {required Prescription prescription}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => ChangeNotifierProvider(
      create: (context) => UnappliedPrescriptionDetailViewModel(
        prescriptionRepository: context.read(),
      )..getPrescriptionDetail(prescription.id ?? 0),
      child: const PrescriptionDetailView(),
    ),
  );
}

class PrescriptionDetailView extends StatelessWidget {
  const PrescriptionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnappliedPrescriptionDetailViewModel>(
      builder: (context, vm, _) {
        return CustomDialog(
          title: 'Malzeme Listesi',
          width: context.width * 0.9,
          maxHeight: 1000,
          isLoading: vm.isFetching,
          child: UnifiedTableView<PrescriptionItem>(
            data: vm.filteredItems,
            enableSearch: true,
            enableExcel: true,
            exportFileName: 'Recete_Malzemeleri',
            horizontalScroll: true,
            isLoading: false,
            onSearchChanged: vm.search,
            minTableWidth: 3000,
          ),
        );
      },
    );
  }
}
