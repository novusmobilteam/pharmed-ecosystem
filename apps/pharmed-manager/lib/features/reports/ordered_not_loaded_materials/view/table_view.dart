part of 'ordered_not_loaded_materials_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final OrderedNotLoadedMaterialsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<OrderedNotLoadedMaterial>(
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

      // Tarih & arama
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,

      // İstasyonlar (çoklu seçim)
      categories: notifier.tableCategories,
      selectedCategoryIds: notifier.selectedCategoryIds,
      onCategorySelectionChanged: notifier.onCategorySelectionChanged,
      categoryTitle: context.l10n.report_stationsCategoryTitle,

      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<OrderedNotLoadedMaterial>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialServiceColumn,
    displayValue: (item) => item.serviceName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialBarcodeColumn,
    displayValue: (item) => item.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialMaterialColumn,
    flex: 2,
    displayValue: (item) => item.materialName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialDateColumn,
    displayValue: (item) => item.orderDate?.formattedDateTime,
    sortValue: (item) => item.orderDate,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialProtocolColumn,
    displayValue: (item) => item.protocolNo,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialQuantityColumn,
    numeric: true,
    displayValue: (item) => item.quantity?.formatFractional,
    sortValue: (item) => item.quantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedNotLoadedMaterialPatientColumn,
    flex: 1.5,
    displayValue: (item) => item.patientFullName,
  ),
];
