part of 'station_transaction_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationTransactionReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: true,

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      // Filter & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,

      // Kategori
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<StockTransaction>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionDateColumn,
    displayValue: (item) => item.sendDate?.formattedDate,
  ),
  TableColumnDef(title: context.l10n.tableCore_materialColumn, displayValue: (item) => item.medicine?.name.toString()),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionBarcodeColumn,
    displayValue: (item) => item.medicine?.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionTypeColumn,
    displayValue: (item) => item.transactionKind?.label,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionQuantityColumn,
    displayValue: (item) => '${item.quantity?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionPreviousQuantityColumn,
    displayValue: (item) =>
        '${item.beforeQuantity?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stockTransactionActorColumn,
    displayValue: (item) => item.user?.fullName,
  ),
];
