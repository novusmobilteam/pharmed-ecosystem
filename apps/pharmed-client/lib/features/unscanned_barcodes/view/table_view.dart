part of 'unscanned_barcodes_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.items, required this.isLoading, required this.notifier});

  final UnscannedBarcodesNotifier notifier;
  final List<PrescriptionItem> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return MedTable(
      data: items,
      isLoading: isLoading,
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      enableDateFilter: false,
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: (page) => notifier.goToPage(page),
      onDateRangeChanged: (range) => notifier.onDateRangeChanged(range?.start, range?.end),

      columnDefs: _buildColumnDefs(context),
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
