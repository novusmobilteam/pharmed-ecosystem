part of 'ordered_loaded_materials_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final OrderedLoadedMaterialsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<OrderedLoadedMaterial>(
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

List<TableColumnDef<OrderedLoadedMaterial>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_orderedLoadedMaterialStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedLoadedMaterialCabinColumn,
    displayValue: (item) => item.cabinName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedLoadedMaterialServiceColumn,
    displayValue: (item) => item.serviceName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedLoadedMaterialBarcodeColumn,
    displayValue: (item) => item.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_orderedLoadedMaterialMaterialColumn,
    flex: 2,
    displayValue: (item) => item.materialName,
  ),
];
