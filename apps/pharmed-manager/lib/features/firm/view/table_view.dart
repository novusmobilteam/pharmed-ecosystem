part of 'firm_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final FirmNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Firm>(
      data: notifier.items,
      isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
      enableExcel: true,
      enableSearch: true,
      onSearchChanged: notifier.search,
      actions: [
        TableActionItem.edit(
          context: context,
          onPressed: (firm) => notifier.openPanel(firm: firm),
        ),
        TableActionItem.delete(context: context, onPressed: (firm) => _onDelete(context, notifier, firm)),
      ],
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      onPageChanged: (page) => notifier.setPage(page),
      columnDefs: _buildColumnDefs(context),
    );
  }
}

void _onDelete(BuildContext context, FirmNotifier notifier, Firm item) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteFirm(
        item,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}

List<TableColumnDef<Firm>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.tableCore_firmIdColumn, displayValue: (item) => item.id?.toString()),
  TableColumnDef(title: context.l10n.tableCore_firmNameColumn, displayValue: (item) => item.name),
  TableColumnDef(title: context.l10n.tableCore_firmTypeColumn, displayValue: (item) => item.type?.label),
  TableColumnDef(title: context.l10n.tableCore_firmTaxOfficeColumn, displayValue: (item) => item.taxOffice),
  TableColumnDef(title: context.l10n.tableCore_firmTaxNoColumn, displayValue: (item) => item.taxNo?.toString()),
];
