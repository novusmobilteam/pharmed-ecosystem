part of 'mail_preference_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final MailPreferenceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<MailPreference>(
      data: notifier.preferences,
      columnDefs: _buildColumnDefs(context),
      toolbarActions: [MedButton(label: 'Ekle')],
    );
  }
}

List<TableColumnDef<MailPreference>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.tableCore_roleNameColumn, displayValue: (item) => item.title ?? '-'),
  TableColumnDef(title: context.l10n.common_statusLabel, displayValue: (item) => item.senderName),
];
