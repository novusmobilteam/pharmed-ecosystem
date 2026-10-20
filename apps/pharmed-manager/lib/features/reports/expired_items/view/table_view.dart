part of 'expired_items_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final ExpiredItemsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<CabinStock>(
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

      // Cell
      cellBuilder: (item, colIndex, value) {
        if (colIndex == 9) {
          return RemainingDayChip(days: item.remainingDay ?? 0);
        }
        return null;
      },
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<CabinStock>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.expiredItems_table_barcodeColumn, displayValue: (item) => item.medicine?.barcode),
  TableColumnDef(title: context.l10n.expiredItems_table_medicineColumn, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.expiredItems_table_cabinColumn,
    displayValue: (item) => item.assignment?.cabin?.name,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_locationColumn,
    displayValue: (item) => '${item.shelfNo}/${item.corpartmentNo}',
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_minQuantityColumn,
    displayValue: (item) => '${(item.assignment?.minQuantity).formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.assignment?.minQuantity,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_maxQuantityColumn,
    displayValue: (item) => '${(item.assignment?.maxQuantity).formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.assignment?.maxQuantity,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_criticalQuantityColumn,
    displayValue: (item) => '${(item.assignment?.criticalQuantity).formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.assignment?.criticalQuantity,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_quantityColumn,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.quantity,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_expiryDateColumn,
    displayValue: (item) => item.miadDate?.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_remainingDaysColumn,
    displayValue: (item) => item.remainingDayText,
  ),
];
