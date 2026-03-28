part of 'unscanned_barcodes_screen.dart';

void showDeletedBarcodes(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesViewModel>(),
      child: DeletedBarcodesView(),
    ),
  );
}

class DeletedBarcodesView extends StatelessWidget {
  const DeletedBarcodesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      width: context.width * 0.8,
      maxHeight: 800,
      title: 'Silinen Karekodlar',
      child: FutureBuilder(
        future: context.read<IPrescriptionRepository>().getDeletedBarcodes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: CommonEmptyStates.noData(),
            );
          }

          final items = (snapshot.data as Ok<List<PrescriptionItem>>).value;

          return UnifiedTableView<PrescriptionItem>(
            data: items,
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
