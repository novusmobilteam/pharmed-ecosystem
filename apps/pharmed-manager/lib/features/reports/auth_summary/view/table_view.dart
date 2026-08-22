part of 'auth_summary_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final AuthSummaryReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<UserAuthorizationSummary>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      onSearchChanged: notifier.search,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.dotsThreeVertical(),
          tooltip: context.l10n.authorization_summary_viewDetailsTooltip,
          onPressed: (summary) {
            showAuthSummaryView(context, summary.userId ?? 0);
          },
        ),
      ],
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<UserAuthorizationSummary>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef<UserAuthorizationSummary>(
    title: context.l10n.authorization_table_userColumn,
    displayValue: (item) => item.userFullName,
  ),
  TableColumnDef<UserAuthorizationSummary>(
    title: context.l10n.authorization_table_roleColumn,
    displayValue: (item) => item.roleName,
  ),
  TableColumnDef<UserAuthorizationSummary>(
    title: context.l10n.authorization_table_encryptedLoginColumn,
    displayValue: (item) => (item.encryptedLogin ?? false) ? context.l10n.common_boolYes : context.l10n.common_boolNo,
  ),
  TableColumnDef<UserAuthorizationSummary>(
    title: context.l10n.authorization_table_isDeletedColumn,
    displayValue: (item) => (item.isDeleted ?? false) ? context.l10n.common_boolYes : context.l10n.common_boolNo,
  ),
  TableColumnDef<UserAuthorizationSummary>(
    title: context.l10n.authorization_table_extraAuthCountColumn,
    displayValue: (item) => item.extraAuthorizationCount?.formatFractional,
  ),
];
