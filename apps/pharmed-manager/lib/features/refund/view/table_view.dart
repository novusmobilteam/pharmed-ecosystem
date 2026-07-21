part of 'pharmacy_refund_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final PharmacyRefundNotifier notifier;

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

      actions: [
        if (!notifier.showCompleted)
          TableActionItem(
            icon: PhosphorIcons.arrowFatDown(),
            tooltip: 'İade Al',
            onPressed: (refund) => notifier.completeRefund(
              refund,
              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
              onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
            ),
          ),
        if (!notifier.showCompleted)
          TableActionItem.delete(context: context, onPressed: (refund) => showDeleteDescriptionView(context, refund)),
      ],

      toolbarActions: [
        MedRectangleIconButton(
          tooltip: !notifier.showCompleted
              ? context.l10n.refund_showCompletedTooltip
              : context.l10n.refund_showIncompleteTooltip,
          iconData: !notifier.showCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.hourglass(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleCompleted,
        ),
      ],

      columnDefs: notifier.showCompleted ? _buildCompletedColumnDefs(context) : _buildColumnDefs(context),

      pdfTitle: 'Eczane İade Raporu',
      pdfHeaderBuilder: PdfReportHeader.build(
        title: 'Eczane İade Raporu',
        infoLines: [
          if (notifier.selectedStation != null) 'İstasyon: ${notifier.selectedStation!.name}',
          if (notifier.dateRange != null)
            'Tarih: ${notifier.dateRange?.start.formattedDate} - ${notifier.dateRange?.end.formattedDate}',
        ],
      ),
    );
  }
}

List<TableColumnDef<Refund>> _buildCompletedColumnDefs(BuildContext context) => [
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_patientCodeColumn,
    displayValue: (r) => r.patient?.id?.toString() ?? '-',
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_patientColumn,
    displayValue: (r) => r.patient?.fullName ?? '-',
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_userColumn,
    displayValue: (r) => r.createdUser?.fullName ?? '-',
  ),
  TableColumnDef<Refund>(title: context.l10n.refund_table_medicineColumn, displayValue: (r) => r.medicine?.name ?? '-'),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_quantityColumn,
    numeric: true,
    displayValue: (r) => r.quantity?.formatFractional ?? '-',
    sortValue: (r) => r.quantity,
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_dateColumn,
    displayValue: (r) => r.createdDate?.formattedDate ?? '-',
    sortValue: (r) => r.createdDate,
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_approvedUserColumn,
    displayValue: (r) => r.approvedUser?.fullName ?? '-',
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_approvedDateColumn,
    displayValue: (r) => r.approvedDate?.formattedDate ?? '-',
    sortValue: (r) => r.approvedDate,
  ),
];

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
    displayValue: (r) => r.quantity?.formatFractional,
  ),
  TableColumnDef<Refund>(
    title: context.l10n.refund_table_dateColumn,
    displayValue: (r) => r.createdDate?.formattedDate,
  ),
  TableColumnDef<Refund>(title: context.l10n.refund_table_descriptionColumn, displayValue: (r) => r.description),
];
