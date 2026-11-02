part of 'station_transaction_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final StationTransactionReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<StationTransaction>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      // Kolon sayısı arttı — dar ekranda sıkışmasın diye yatay kaydırma.
      horizontalScroll: true,
      minTableWidth: 1600,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: true,
      enableTimeFilter: true,

      // Sonsuz kaydırma
      enableInfiniteScroll: true,
      hasMore: notifier.hasMore,
      isLoadingMore: notifier.isLoadingMore,
      onLoadMore: notifier.loadMore,
      serverTotalCount: notifier.totalCount,

      // Filter & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,
      serverFilters: notifier.serverFilters,
      onServerFiltersChanged: notifier.onServerFiltersChanged,

      // Kategori
      categories: notifier.tableCategories,
      selectedCategoryIds: notifier.selectedCategoryIds,
      onCategorySelectionChanged: notifier.onCategorySelectionChanged,

      categoryTitle: context.l10n.report_stationsCategoryTitle,

      columnDefs: _buildColumnDefs(context),

      actions: [
        TableActionItem<StationTransaction>(
          icon: PhosphorIcons.videoCamera(),
          tooltip: context.l10n.inconsistency_watchRecordingTooltip,
          // operationId yoksa (backend değişikliği öncesi kayıtlar) izlenecek kayıt yok.
          isVisible: (item) => item.operationId != null,
          onPressed: (item) => showOperationRecordingDialog(context, operationId: item.operationId!),
        ),
        TableActionItem<StationTransaction>(
          icon: PhosphorIcons.dotsThreeVertical(),
          tooltip: context.l10n.report_stationTransaction_detailTooltip,
          onPressed: (item) => StationTransactionDetailDialog.show(context, transaction: item),
        ),
      ],
    );
  }
}

List<TableColumnDef<StationTransaction>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionDateColumn,
    displayValue: (item) => item.transactionDate?.formattedDate,
    sortValue: (item) => item.transactionDate,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionTimeColumn,
    flex: 0.6,
    displayValue: (item) => item.transactionDate?.formattedTime,
    sortValue: (item) => item.transactionDate,
  ),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionCabinColumn, displayValue: (item) => item.cabinName),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionTypeColumn,
    displayValue: (item) =>
        StationTransactionType.fromValue(item.transactionType?.value)?.label(context) ?? item.transaction,
    serverFilter: TableServerFilter(
      field: 'transactionId',
      options: [
        for (final type in StationTransactionType.values)
          TableFilterOption(value: type.value, label: type.label(context)),
      ],
    ),
  ),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionCodeColumn, displayValue: (item) => item.code),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionBarcodeColumn, displayValue: (item) => item.barcode),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionMaterialColumn, displayValue: (item) => item.material),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionBeforeQuantityColumn,
    displayValue: (item) => item.beforeQuantity == null
        ? '-'
        : '${item.beforeQuantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.beforeQuantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionQuantityColumn,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (item) => item.quantity,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionRfidTagColumn,
    displayValue: (item) => item.rfidTagNo ?? '-',
  ),
  // TableColumnDef(
  //   title: context.l10n.tableCore_stationTransactionOrderColumn,
  //   displayValue: (item) => item.order?.toString(),
  // ),
  // TableColumnDef(
  //   title: context.l10n.tableCore_stationTransactionCompartmentColumn,
  //   displayValue: (item) => item.compartment?.toString(),
  // ),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionPatientColumn, displayValue: (item) => item.patient),
  // TableColumnDef(
  //   title: context.l10n.tableCore_stationTransactionProtocolCodeColumn,
  //   displayValue: (item) => item.protocolCode,
  // ),
  TableColumnDef(
    title: context.l10n.tableCore_stationTransactionPerformedByColumn,
    displayValue: (item) => item.performedBy,
  ),
  TableColumnDef(title: context.l10n.tableCore_stationTransactionWitnessColumn, displayValue: (item) => item.witness),
];
