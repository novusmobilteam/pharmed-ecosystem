part of 'unordered_loaded_materials_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final UnorderedLoadedMaterialsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<UnorderedLoadedMaterial>(
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

      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<UnorderedLoadedMaterial>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_unorderedLoadedMaterialStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_unorderedLoadedMaterialBarcodeColumn,
    displayValue: (item) => item.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_unorderedLoadedMaterialMaterialColumn,
    flex: 2,
    displayValue: (item) => item.materialName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_unorderedLoadedMaterialQuantityColumn,
    numeric: true,
    displayValue: (item) => item.quantity?.formatFractional,
    sortValue: (item) => item.quantity,
  ),
];
