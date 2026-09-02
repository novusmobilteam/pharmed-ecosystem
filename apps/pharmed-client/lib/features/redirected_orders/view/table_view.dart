part of 'redirected_orders_screen.dart';

class TableView extends ConsumerWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(redirectedOrdersNotifierProvider);
    final notifier = ref.read(redirectedOrdersNotifierProvider.notifier);

    return MedTable<RedirectedOrder>(
      data: notifier.orders,
      isLoading: notifier.isFetchingOrders,
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
      columnDefs: _buildColumnDefs(context),
      actions: [
        TableActionItem(
          icon: PhosphorIcons.x(),
          tooltip: context.l10n.common_confirmCancelButton,
          color: MedColors.red,
          onPressed: (item) => notifier.cancelOrder(
            item.id!,
            onSuccess: () => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
            onError: (message) => MessageUtils.showErrorSnackbar(context, message),
          ),
        ),
      ],
    );
  }
}

List<TableColumnDef<RedirectedOrder>> _buildColumnDefs(BuildContext context) => [
  // TableColumnDef(
  //   title: context.l10n.directedOrders_table_dateColumn,
  //   displayValue: (item) => item.receivedDate?.formattedDate,
  // ),
  TableColumnDef(title: context.l10n.directedOrders_table_materialColumn, displayValue: (item) => item.materialName),
  TableColumnDef(
    title: context.l10n.directedOrders_table_quantityColumn,
    displayValue: (item) => item.quantity?.formatFractional,
  ),
  TableColumnDef(
    title: context.l10n.directedOrders_table_targetServiceColumn,
    displayValue: (item) => item.serviceName,
  ),
  TableColumnDef(
    title: context.l10n.directedOrders_table_targetStationColumn,
    displayValue: (item) => item.stationName,
  ),
  TableColumnDef(title: context.l10n.directedOrders_table_sentByColumn, displayValue: (item) => item.sendUserName),
  TableColumnDef(
    title: context.l10n.directedOrders_table_cancelledColumn,
    displayValue: (item) => null,
    cellBuilder: (item) {
      final isCancelled = item.isCancel ?? false;
      return MedInfoChip(
        info: isCancelled
            ? context.l10n.directedOrders_table_cancelledYes
            : context.l10n.directedOrders_table_cancelledNo,
        backgroundColor: isCancelled ? MedColors.redLight : MedColors.greenLight,
        foregroundColor: isCancelled ? MedColors.red : MedColors.green,
      );
    },
  ),
];
