part of 'inconsistency_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final InconsistencyNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Inconsistency>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableDateFilter: true,
      enableSearch: true,
      onSearchChanged: notifier.search,
      onDateRangeChanged: notifier.setDateRange,
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noData),

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: (page) => notifier.setPage(page),

      // Category
      categories: notifier.tableCategories,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      selectedCategoryId: notifier.selectedCategoryId,

      columnDefs: _buildColumnDefs(context, notifier),

      actions: [
        if (notifier.showSolved)
          TableActionItem(
            icon: PhosphorIcons.pen(),
            tooltip: context.l10n.enumCore_warningSubjectInconsistencyResolution,
            onPressed: (item) => showSolveInconsistencyView(context, item),
          ),
        if (!notifier.showSolved)
          TableActionItem(
            icon: PhosphorIcons.note(),
            tooltip: context.l10n.unappliedPrescription_viewDetailsTooltip,
            onPressed: (item) => showDialog(
              context: context,
              builder: (context) => InconsistencyDetailDialog(inconsistency: item),
            ),
          ),
      ],

      toolbarActions: [
        MedRectangleIconButton(
          tooltip: notifier.showSolved
              ? context.l10n.inconsistency_showSolvedTooltip
              : context.l10n.inconsistency_showUnsolvedTooltip,
          iconData: notifier.showSolved ? PhosphorIcons.clockCounterClockwise() : PhosphorIcons.clockClockwise(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleSolved,
        ),
      ],
    );
  }
}

List<TableColumnDef<Inconsistency>> _buildColumnDefs(BuildContext context, InconsistencyNotifier notifier) {
  String dose(Medicine? medicine, num? quantity) =>
      '${quantity.formatFractional} ${medicine?.operationUnitLocalized(context)}';
  return [
    TableColumnDef(title: context.l10n.drugActivity_column_material, displayValue: (item) => item.medicine?.name),
    TableColumnDef(
      title: context.l10n.table_inconsistency_currentColumn,
      displayValue: (item) => dose(item.medicine, item.quantity),
    ),
    TableColumnDef(
      title: context.l10n.table_inconsistency_expectedColumn,
      displayValue: (item) => dose(item.medicine, item.requiredQuantity),
    ),
    TableColumnDef(
      title: context.l10n.table_inconsistency_handledByColumn,
      displayValue: (item) => item.user?.fullName ?? '-',
    ),
    TableColumnDef(
      title: context.l10n.drugActivity_column_date,
      displayValue: (item) => item.createdDate.formattedDateTime,
    ),
    if (!notifier.showSolved)
      TableColumnDef(
        title: context.l10n.inconsistency_resolvedByUserLabel,
        displayValue: (item) => item.solvedUser?.fullName,
      ),
    TableColumnDef(
      title: context.l10n.common_statusLabel,
      displayValue: (item) => item.isSolved ? context.l10n.fault_cellValueSolved : context.l10n.fault_cellValueUnsolved,
    ),
  ];
}
