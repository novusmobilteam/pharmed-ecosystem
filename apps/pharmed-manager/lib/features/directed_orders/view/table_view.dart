part of 'directed_orders_screen.dart';

class _TableView extends StatelessWidget {
  const _TableView({required this.vm});

  final DirectedOrdersViewModel vm;

  List<TableColumnDef> _buildColumnDefs() => const [
        TableColumnDef(title: 'Hasta', flex: 1.5), // colIndex: 0
        TableColumnDef(title: 'Protokol No'), // colIndex: 1
        TableColumnDef(title: 'Yatak', flex: 0.7), // colIndex: 2
        TableColumnDef(title: 'Oda', flex: 0.7), // colIndex: 3
      ];

  Widget? _buildCell(Hospitalization item, int colIndex, dynamic _) {
    return switch (colIndex) {
      0 => Text(item.patient?.fullName ?? '-'),
      1 => Text(item.patient?.protocolNo ?? '-'),
      2 => Text(item.bedNo ?? '-'),
      3 => Text(item.roomNo ?? '-'),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Hospitalization>(
      data: vm.filteredItems,
      isLoading: vm.isFetching,
      enableSearch: true,
      enableExcel: true,
      onSearchChanged: vm.search,
      columnDefs: _buildColumnDefs(),
      cellBuilder: _buildCell,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.dotsThreeVertical(),
          tooltip: 'İlaçlar',
          onPressed: (hosp) => showMedicineTableDialog(context, hosp),
        ),
      ],
      emptyWidget: vm.hasNoSearchResults ? CommonEmptyStates.searchNotFound() : CommonEmptyStates.noData(),
    );
  }
}
