part of 'expiring_items_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.items, required this.isLoading, required this.notifier});

  final ExpiringItemsNotifier notifier;
  final List<CabinStock> items;
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

      onPageChanged: (page) => notifier.setPage(page),
      onDateRangeChanged: (range) => notifier.setDateRange(range),
      //cellBuilder: (item, colIndex, value) {},
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<CabinStock>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.drugActivity_table_medicineColumn, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.expiredItems_table_expiryDateColumn,
    displayValue: (item) => item.miadDate.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.expiredItems_table_remainingDaysColumn,
    displayValue: (item) => item.remainingDayText,
  ),
  TableColumnDef(title: context.l10n.expiredItems_table_locationColumn, displayValue: (item) => item.position),
  TableColumnDef(
    title: context.l10n.expiredItems_table_quantityColumn,
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),

  // TableColumnDef(
  //   title: context.l10n.drugActivity_table_dateColumn,
  //   displayValue: (item) => item.createdAt.formattedDate,
  // ),
  // TableColumnDef(
  //   title: context.l10n.drugActivity_table_patientColumn,
  //   displayValue: (item) => item.prescriptionItem?.prescription?.hospitalization?.patient?.fullName,
  // ),
  // TableColumnDef(title: context.l10n.drugActivity_table_userColumn, displayValue: (item) => item.performedBy?.fullName),
  // TableColumnDef(
  //   title: context.l10n.drugActivity_table_medicineColumn,
  //   displayValue: (item) => item.prescriptionItem?.medicine?.name,
  // ),
  // TableColumnDef(
  //   title: context.l10n.drugActivity_table_quantityColumn,
  //   displayValue: (item) => item.quantity.formatFractional,
  // ),
  // TableColumnDef(
  //   title: context.l10n.drugActivity_table_movementColumn,
  //   displayValue: (item) => item.type.actionLabel(context),
  // ),
];
