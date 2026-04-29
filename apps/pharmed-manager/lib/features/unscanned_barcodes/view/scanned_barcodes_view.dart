part of 'unscanned_barcodes_screen.dart';

void showScannedBarcodes(BuildContext context) {
  final notifier = context.read<UnscannedBarcodesNotifier>();

  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(value: notifier, child: const DeletedBarcodesView()),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.getScannedBarcodes();
  });
}

class ScannedBarcodesView extends StatelessWidget {
  const ScannedBarcodesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      width: context.width * 0.8,
      maxHeight: 900,
      title: 'Okutulan Karekodlar',
      child: Consumer<UnscannedBarcodesNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading(notifier.fetchScannedOp)) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (!notifier.isLoading(notifier.fetchScannedOp) && notifier.deletedBarcodes.isEmpty) {
            return CommonEmptyStates.noData();
          }

          return UnifiedTableView<PrescriptionItem>(
            data: notifier.scannedBarcodes,
            horizontalScroll: true,
            minTableWidth: 3000,
            columnDefs: buildColumnDefs(),
            cellBuilder: buildCell,
          );
        },
      ),
    );
  }
}
