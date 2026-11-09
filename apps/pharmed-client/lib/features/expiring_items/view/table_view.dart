part of 'expiring_items_screen.dart';

class TableView extends ConsumerWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(expiringItemsNotifierProvider);
    final notifier = ref.read(expiringItemsNotifierProvider);

    return MedTable<CabinStock>(
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
    displayValue: (item) => '${item.quantity.formatFractional} ${item.medicine?.pieceUnitLabel ?? ''}',
  ),
];
