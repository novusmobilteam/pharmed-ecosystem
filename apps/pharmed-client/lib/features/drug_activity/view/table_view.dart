part of 'drug_activity_screen.dart';

class TableView extends ConsumerWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(drugActivityNotifierProvider);
    final notifier = ref.read(drugActivityNotifierProvider.notifier);

    return MedTable(
      data: notifier.items,
      isLoading: notifier.isLoading(notifier.fetchOp),
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      serverTotalCount: notifier.totalCount,
      currentPage: notifier.currentPage,
      pageSize: notifier.pageSize,
      enableDateFilter: true,
      enablePagination: true,
      onPageChanged: (page) => notifier.setPage(page),
      onDateRangeChanged: (range) => notifier.setDateRange(range),
      cellBuilder: (item, colIndex, value) {
        if (colIndex == 6) {
          final status = (item).type;
          return MedInfoChip(
            info: status.actionLabel(context),
            backgroundColor: status.backgroundColor,
            foregroundColor: status.foregroundColor,
          );
        }
        return null;
      },
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<PrescriptionItemMovement>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.drugActivity_table_dateColumn,
    displayValue: (item) => item.createdAt.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.drugActivity_table_timeColumn,
    displayValue: (item) => item.createdAt.formattedTime,
  ),
  TableColumnDef(
    title: context.l10n.drugActivity_table_patientColumn,
    displayValue: (item) => item.prescriptionItem?.prescription?.hospitalization?.patient?.fullName,
  ),
  TableColumnDef(title: context.l10n.drugActivity_table_userColumn, displayValue: (item) => item.performedBy?.fullName),
  TableColumnDef(
    title: context.l10n.drugActivity_table_medicineColumn,
    displayValue: (item) => item.prescriptionItem?.medicine?.name,
  ),
  TableColumnDef(
    title: context.l10n.drugActivity_table_quantityColumn,
    displayValue: (item) => item.quantity.formatFractional,
  ),
  TableColumnDef(
    title: context.l10n.drugActivity_table_movementColumn,
    displayValue: (item) => item.type.actionLabel(context),
  ),
];
