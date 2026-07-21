part of 'role_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final RoleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Role>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enablePagination: true,
      currentPage: notifier.currentPage,
      onPageChanged: (page) {
        notifier.setPage(page);
        notifier.fetch();
      },
      onSearchChanged: notifier.search,
      columnDefs: _buildColumnDefs(context),
      actions: [
        TableActionItem(
          icon: PhosphorIcons.trash(),
          tooltip: context.l10n.common_deleteTooltip,
          onPressed: (role) => notifier.deleteRole(role, successMessage: context.l10n.roleDeleteSuccessMessage),
          isVisible: (role) => role.type == null,
        ),
        TableActionItem(
          icon: PhosphorIcons.pen(),
          tooltip: context.l10n.common_editTooltip,
          onPressed: (role) => notifier.openPanel(item: role),
          isVisible: (role) => role.type == null,
        ),
      ],
    );
  }
}

List<TableColumnDef<Role>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.tableCore_roleNameColumn, displayValue: (item) => item.name ?? '-'),
  TableColumnDef(title: context.l10n.common_statusLabel, displayValue: (item) => item.status.label),
];
