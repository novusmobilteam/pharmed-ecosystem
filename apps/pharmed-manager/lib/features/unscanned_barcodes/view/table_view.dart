part of 'unscanned_barcodes_screen.dart';

class _TableView extends StatelessWidget {
  const _TableView({required this.notifier});

  final UnscannedBarcodesNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<PrescriptionItem>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enableDateFilter: true,
      onSearchChanged: notifier.search,

      selectionMode: notifier.canSelectItem ? TableSelectionMode.single : TableSelectionMode.none,
      onSingleSelectionChanged: (selectedItem) => notifier.selectedItem = selectedItem,
      columnDefs: _buildColumnDefs(context),

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      // Filter & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: (range) => notifier.setDateRange(range),

      // Kategori
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,
      toolbarActions: [
        MedRectangleIconButton(
          tooltip: switch (notifier.mode) {
            BarcodeListMode.unscanned => context.l10n.unscannedBarcodes_action_showScanned,
            BarcodeListMode.scanned => context.l10n.unscannedBarcodes_action_showDeleted,
            BarcodeListMode.deleted => context.l10n.unscannedBarcodes_action_showUnscanned,
          },
          iconData: switch (notifier.mode) {
            BarcodeListMode.unscanned => PhosphorIcons.checkCircle(),
            BarcodeListMode.scanned => PhosphorIcons.trash(),
            BarcodeListMode.deleted => PhosphorIcons.qrCode(),
          },
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.cycleBarcodeListMode,
        ),
      ],

      actions: [
        if (notifier.canSelectItem)
          TableActionItem(
            icon: PhosphorIcons.qrCode(),
            tooltip: context.l10n.qrScan_dialogTitle,
            onPressed: (item) async {
              final outcome = await showQrScanDialog(
                context,
                request: QrScanRequest(
                  operationLabel: context.l10n.qrScan_operationUnscanned,
                  medicineName: item.medicine?.name ?? '—',
                  requiredCount: notifier.requiredQrCountOf(item),
                  expectedGtin: notifier.expectedGtinOf(item),
                  allowPartialSubmit: true,
                ),
                onSubmit: (codes) => notifier.scanQrCode(item, codes),
              );
              if (outcome == QrScanOutcome.submitted) await notifier.fetch();
            },
          ),
        if (notifier.canSelectItem)
          TableActionItem(
            icon: PhosphorIcons.trash(),
            color: MedColors.red,
            tooltip: context.l10n.common_deleteTooltip,
            onPressed: (data) => showDeleteDescriptionView(context, data),
          ),
      ],
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
    );
  }
}

List<TableColumnDef<PrescriptionItem>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.drugActivity_table_patientColumn,
    displayValue: (item) => item.prescription?.hospitalization?.patient?.fullName,
  ),
  TableColumnDef(
    title: context.l10n.patientInventory_table_barcodeColumn,
    displayValue: (item) => item.medicine?.barcode,
  ),
  TableColumnDef(title: context.l10n.enumCore_medicineTypeDrug, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.patientInventory_table_processDateColumn,
    displayValue: (item) => item.applicationDate.formattedDate,
  ),
  TableColumnDef(title: context.l10n.movement_performedBy, displayValue: (item) => item.applicationUser?.fullName),
  TableColumnDef(
    title: context.l10n.movement_quantityLabel,
    displayValue: (item) => '${item.dosePiece.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
];
