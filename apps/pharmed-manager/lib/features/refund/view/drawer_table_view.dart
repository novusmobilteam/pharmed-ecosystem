part of 'drawer_refund_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final DrawerRefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Refund>(
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

      pdfTitle: context.l10n.refund_pdf_title,
      pdfHeaderBuilder: PdfReportHeader.build(
        title: context.l10n.refund_pdf_title,
        infoLines: [
          if (notifier.selectedStation != null) context.l10n.refund_pdf_station(notifier.selectedStation!.name ?? ''),
          if (notifier.dateRange != null)
            context.l10n.refund_pdf_dateRange(
              notifier.dateRange!.start.formattedDate,
              notifier.dateRange!.end.formattedDate,
            ),
        ],
      ),
    );
  }
}

List<TableColumnDef<Refund>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_patientCodeColumn,
    displayValue: (r) => r.patient?.id?.toCustomString(),
  ),
  TableColumnDef<Refund>(title: context.l10n.refund_table_patientColumn, displayValue: (r) => r.patient?.fullName),
  TableColumnDef<Refund>(title: context.l10n.refund_table_userColumn, displayValue: (r) => r.createdUser?.fullName),
  TableColumnDef<Refund>(title: context.l10n.refund_table_medicineColumn, displayValue: (r) => r.medicine?.name),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_quantityColumn,
    displayValue: (r) => '${r.quantity?.formatFractional ?? '-'} ${r.medicine?.operationUnitLocalized(context) ?? ''}',
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_dateColumn,
    displayValue: (r) => r.createdDate?.formattedDate,
  ),
  TableColumnDef<Refund>(title: context.l10n.refund_table_descriptionColumn, displayValue: (r) => r.description),
];
