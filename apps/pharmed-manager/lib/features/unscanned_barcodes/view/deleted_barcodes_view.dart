part of 'unscanned_barcodes_screen.dart';

void showDeletedBarcodes(BuildContext context) {
  final notifier = context.read<UnscannedBarcodesNotifier>();

  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(value: notifier, child: const DeletedBarcodesView()),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.getDeletedBarcodes();
  });
}

class DeletedBarcodesView extends StatelessWidget {
  const DeletedBarcodesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      width: context.width * 0.7,
      height: 1000,
      title: 'Silinen Karekodlar',
      child: Consumer<UnscannedBarcodesNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading(notifier.fetchDeletedOp)) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (!notifier.isLoading(notifier.fetchDeletedOp) && notifier.deletedBarcodes.isEmpty) {
            return CommonEmptyStates.noData();
          }

          return MedTable<PrescriptionItem>(
            data: notifier.deletedBarcodes,
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
