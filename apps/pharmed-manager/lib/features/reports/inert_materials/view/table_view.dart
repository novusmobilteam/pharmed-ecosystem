part of 'inert_materials_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final InertMaterialsReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<InertMaterial>(
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

List<TableColumnDef<InertMaterial>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_inertMaterialStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_inertMaterialBarcodeColumn,
    displayValue: (item) => item.barcode,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_inertMaterialMaterialColumn,
    flex: 2,
    displayValue: (item) => item.medicine?.name ?? item.materialName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_inertMaterialQuantityColumn,
    numeric: true,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.quantity,
  ),
];
