part of 'unscanned_barcodes_screen.dart';

class _TableView extends StatelessWidget {
  const _TableView({required this.vm});

  final UnscannedBarcodesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<PrescriptionItem>(
      data: vm.dateFilteredItems,
      isLoading: vm.isFetchingBarcodes,
      enableExcel: true,
      enableSearch: true,
      enableDateFilter: true,
      onSearchChanged: vm.search,
      onDateRangeChanged: (range) {
        vm.setStartDate(range?.start);
        vm.setEndDate(range?.end);
      },
      selectionMode: TableSelectionMode.single,
      onSingleSelectionChanged: (selectedItem) => vm.selectedItem = selectedItem,
      columnDefs: _buildColumnDefs(),
      cellBuilder: (item, colIndex, value) => _buildCell(item, colIndex, value),
      actions: [
        TableActionItem(
          icon: PhosphorIcons.qrCode(),
          tooltip: 'Karekod Gir',
          onPressed: (data) => showScanBarcodeView(context, data),
        ),
        TableActionItem.delete(
          onPressed: (data) => showDeleteDescriptionView(context, data),
        )
      ],
    );
  }
}

List<TableColumnDef> _buildColumnDefs() => const [
      TableColumnDef(title: 'Kullanıcı', contentIndex: 0),
      TableColumnDef(title: 'Protokol', contentIndex: 1),
      TableColumnDef(title: 'Hasta Adı', contentIndex: 2),
      TableColumnDef(title: 'Tarih', contentIndex: 3),
      TableColumnDef(title: 'Mal Kodu', contentIndex: 4),
      TableColumnDef(title: 'Malzeme', contentIndex: 5),
      TableColumnDef(title: 'Miktar', contentIndex: 6, numeric: true, flex: 0.7),
      TableColumnDef(title: 'Açıklama', contentIndex: 7, flex: 1.5),
    ];

Widget? _buildCell(PrescriptionItem item, int colIndex, dynamic _) {
  return switch (colIndex) {
    0 => Text(item.approvalUser?.fullName ?? '-'),
    1 => Text(item.protocolNo?.toString() ?? '-'),
    2 => Text(item.patientName ?? '-'),
    3 => Text(item.approvalDate?.formattedDate ?? '-'),
    4 => Text(item.medicine?.barcode?.toString() ?? '-'),
    5 => Text(item.medicine?.name ?? '-'),
    6 => Text(item.returnQuantity.toCustomString()),
    7 => Text(item.description ?? '-'),
    _ => null,
  };
}
