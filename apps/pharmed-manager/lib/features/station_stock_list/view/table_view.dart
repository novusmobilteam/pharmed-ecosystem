part of 'station_stock_list_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationStockListNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final columnDefs = _buildColumnDefs(context);

    return MedTable<StationStock>(
      data: notifier.items,
      enableExcel: true,
      enableSearch: false,

      categories: notifier.tableCategories,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      selectedCategoryId: notifier.selectedCategoryId,

      selectionMode: TableSelectionMode.multi,
      onSelectionChanged: notifier.onSelectionChanged,
      toolbarActions: [
        // Seçim yokken pasif — nedenini tooltip söyler.
        Tooltip(
          message: notifier.canPrint
              ? context.l10n.stationStock_printButton
              : context.l10n.stationStock_printHint,
          child: MedButton(
            label: context.l10n.stationStock_printButton,
            prefixIcon: Icon(PhosphorIcons.printer(), size: 16),
            size: MedButtonSize.sm,
            variant: MedButtonVariant.secondary,
            onPressed: notifier.canPrint ? () => _printSelected(context) : null,
          ),
        ),
      ],

      columnDefs: columnDefs,
    );
  }

  /// [SWREQ-MGR-STATIONSTOCK-002] Seçili satırları istasyon stok çıktısı
  /// formatında (barkodlu) sistem yazdırma diyaloğuna gönderir.
  Future<void> _printSelected(BuildContext context) async {
    final rows = notifier.selectedItems;
    if (rows.isEmpty) return;

    await printStationStockList(context: context, stationName: notifier.selectedStation?.name, stocks: rows);
  }
}

String _qty(num? value, StationStock item) => '${(value ?? 0).formatFractional} ${item.medicine?.pieceUnitLabel}';

List<TableColumnDef<StationStock>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.stationStock_table_cabinNameColumn, displayValue: (item) => item.cabin?.name),
  TableColumnDef(title: context.l10n.stationStock_table_codeColumn, displayValue: StationStockListNotifier.codeOf),
  TableColumnDef(title: context.l10n.stationStock_table_barcodeColumn, displayValue: (item) => item.medicine?.barcode),
  TableColumnDef(title: context.l10n.medicine_fieldName, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.stationStock_table_maxQuantityColumn,
    displayValue: (item) => _qty(item.maxQuantity, item),
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_currentQuantityColumn,
    displayValue: (item) => _qty(item.currentQuantity, item),
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_reservedColumn,
    displayValue: (item) => _qty(item.reservedQuantity, item),
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_remainingColumn,
    displayValue: (item) => _qty(item.remainingQuantity, item),
    sortValue: (item) => item.remainingQuantity ?? 0,
  ),
  TableColumnDef(
    title: context.l10n.stationStock_table_fillingColumn,
    displayValue: (item) => _qty(item.fillingQuantity, item),
    sortValue: (item) => item.fillingQuantity ?? 0,
  ),
];
