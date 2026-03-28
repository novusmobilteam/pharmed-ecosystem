part of 'medicine_activity_screen.dart';

class _TableView extends StatelessWidget {
  const _TableView({required this.vm});

  final MedicineActivityViewModel vm;

  List<TableColumnDef> _buildColumnDefs() => const [
        TableColumnDef(title: 'Tarih', flex: 0.9), // colIndex: 0
        TableColumnDef(title: 'Saat', flex: 0.7), // colIndex: 1
        TableColumnDef(title: 'Hasta', flex: 1.5), // colIndex: 2
        TableColumnDef(title: 'Kullanıcı'), // colIndex: 3
        TableColumnDef(title: 'Malzeme', flex: 1.5), // colIndex: 4
        TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 5
        TableColumnDef(title: 'Hareket', flex: 0.9), // colIndex: 6
      ];

  Widget? _buildCell(PrescriptionItem item, int colIndex, dynamic _) {
    return switch (colIndex) {
      0 => Text(item.activityDate?.formattedDate ?? '-'),
      1 => Text(item.activityDate?.formattedTime ?? '-'),
      2 => Text(item.prescription?.hospitalization?.patient?.fullName ?? '-'),
      3 => Text(item.activityUser?.fullName ?? '-'),
      4 => Text(item.medicine?.name ?? '-'),
      5 => Text('${item.dosePiece.formatFractional} ${item.medicine?.operationUnit ?? ''}'),
      6 => Text(item.status?.label ?? '-'),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<PrescriptionItem>(
      data: vm.filteredItems,
      isLoading: vm.isFetching,
      enableSearch: true,
      enableExcel: true,
      onSearchChanged: vm.search,
      columnDefs: _buildColumnDefs(),
      cellBuilder: _buildCell,
      emptyWidget: vm.hasNoSearchResults ? CommonEmptyStates.searchNotFound() : CommonEmptyStates.noData(),
    );
  }
}
