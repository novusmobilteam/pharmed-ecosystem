part of 'authorization_breakdown_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final AuthorizationBreakdownReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<AuthorizationBreakdown>(
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

      // Tarih & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,

      // İstasyon (tekli seçim)
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,

      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<AuthorizationBreakdown>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownDateColumn,
    displayValue: (item) => item.applicationDate?.formattedDateTime,
    sortValue: (item) => item.applicationDate,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownPatientColumn,
    displayValue: (item) => item.patientFullName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownMaterialColumn,
    flex: 2,
    displayValue: (item) => item.medicine?.name ?? item.materialName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownQuantityColumn,
    numeric: true,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.quantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownTypeColumn,
    displayValue: (item) => _typeLabel(context, item),
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownUserColumn,
    displayValue: (item) => item.userFullName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_authorizationBreakdownStationColumn,
    displayValue: (item) => item.stationName,
  ),
];

/// Kırım tipi: serbest erişim önceliklidir (bir alım ikisini birden taşırsa).
String? _typeLabel(BuildContext context, AuthorizationBreakdown item) {
  if (item.isFreeAccessCollect) return context.l10n.report_authorizationBreakdown_freeAccessType;
  if (item.isOrderlessCollect) return context.l10n.report_authorizationBreakdown_orderlessType;
  return null;
}
