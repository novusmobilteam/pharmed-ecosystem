part of 'unscanned_barcodes_screen.dart';

class TableView extends ConsumerWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(unscannedBarcodesNotifierProvider);
    final notifier = ref.read(unscannedBarcodesNotifierProvider);

    return MedTable<PrescriptionItem>(
      data: notifier.items,
      isLoading: notifier.isLoading(notifier.fetchOp),
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      enableDateFilter: false,
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: (page) => notifier.setPage(page),
      onDateRangeChanged: (range) => notifier.setDateRange(range),

      columnDefs: _buildColumnDefs(context),
      actions: [
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
              onSubmit: (codes) => notifier.submit(item, codes),
            );
            if (outcome == QrScanOutcome.submitted) await notifier.fetch();
          },
        ),
      ],
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
