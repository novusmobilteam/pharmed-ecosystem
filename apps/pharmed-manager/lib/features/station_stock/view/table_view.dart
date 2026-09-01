part of 'station_stock_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationStockNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<StationStock>(
      data: notifier.items,
      enableExcel: true,
      enableSearch: false,

      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<StationStock>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.stationStock_table_cabinNameColumn, displayValue: (item) => item.cabin?.name),
  TableColumnDef(title: context.l10n.medicine_fieldName, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.stationStock_table_maxQuantityColumn,
    displayValue: (item) => '${item.maxQuantity?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_currentQuantityColumn,
    displayValue: (item) =>
        '${item.currentQuantity?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_reservedColumn,
    displayValue: (item) =>
        '${item.reservedQuantity?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
];
