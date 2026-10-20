part of 'station_empty_compartments_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationEmptyCompartmentsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<StationEmptyCompartment>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      // Search
      onSearchChanged: notifier.search,

      // İstasyonlar (çoklu seçim)
      categories: notifier.tableCategories,
      selectedCategoryIds: notifier.selectedCategoryIds,
      onCategorySelectionChanged: notifier.onCategorySelectionChanged,
      categoryTitle: context.l10n.report_stationsCategoryTitle,

      columnDefs: _buildColumnDefs(context, notifier),

      actions: [
        TableActionItem<StationEmptyCompartment>(
          icon: PhosphorIcons.dotsThreeVertical(),
          tooltip: context.l10n.report_stationEmptyCompartment_detailTooltip,
          onPressed: (item) => StationEmptyCompartmentDetailDialog.show(context, item: item),
        ),
      ],
    );
  }
}

List<TableColumnDef<StationEmptyCompartment>> _buildColumnDefs(
  BuildContext context,
  StationEmptyCompartmentsReportNotifier notifier,
) => [
  TableColumnDef(
    title: context.l10n.tableCore_stationEmptyCompartmentStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationEmptyCompartmentCabinColumn,
    flex: 1.5,
    displayValue: (item) => item.cabinName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationEmptyCompartmentDrawerColumn,
    displayValue: notifier.drawerLabel,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationEmptyCompartmentEmptyColumn,
    numeric: true,
    displayValue: (item) => item.emptyCount?.toString(),
    sortValue: (item) => item.emptyCount,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationEmptyCompartmentOccupiedColumn,
    numeric: true,
    displayValue: (item) => item.occupiedCount?.toString(),
    sortValue: (item) => item.occupiedCount,
  ),
];
