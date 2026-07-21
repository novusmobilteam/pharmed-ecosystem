part of 'hospital_stocks_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final HospitalStocksReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: false,

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

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

List<TableColumnDef<HospitalStock>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.hospitalStock_table_serviceColumn, displayValue: (item) => item.serviceName),
  TableColumnDef(title: context.l10n.hospitalStock_table_codeColumn, displayValue: (item) => item.code),
  TableColumnDef(title: context.l10n.hospitalStock_table_medicineColumn, displayValue: (item) => item.materialName),
  TableColumnDef(
    title: context.l10n.hospitalStock_table_quantityColumn,
    displayValue: (item) => item.quantity?.formatFractional,
  ),
];
