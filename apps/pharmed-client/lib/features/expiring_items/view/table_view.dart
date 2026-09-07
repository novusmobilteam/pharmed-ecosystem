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

      onPageChanged: (page) => notifier.goToPage(page),
      onDateRangeChanged: (range) => notifier.onDateRangeChanged(range?.start, range?.end),
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
];
