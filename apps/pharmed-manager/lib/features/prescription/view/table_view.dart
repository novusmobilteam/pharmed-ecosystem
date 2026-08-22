part of 'prescription_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final PrescriptionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Hospitalization>(
      data: notifier.items,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,

      isLoading: notifier.isFetching,
      onSearchChanged: notifier.search,
      enableDateFilter: true,

      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      actions: [
        TableActionItem<Hospitalization>(
          icon: PhosphorIcons.receipt(),
          tooltip: context.l10n.prescription_contentTooltip,
          color: context.colorScheme.onSurface,
          onPressed: notifier.openPanel,
        ),
        TableActionItem<Hospitalization>(
          icon: PhosphorIcons.plus(),
          tooltip: context.l10n.prescription_newTitle,
          onPressed: (hosp) => showPrescriptionFormDialog(context, hospitalization: hosp),
        ),
      ],
      toolbarActions: [
        MedRectangleIconButton(
          tooltip: notifier.showDischarged
              ? context.l10n.prescription_showActiveButton
              : context.l10n.prescription_showDischargedButton,
          iconData: notifier.showDischarged ? PhosphorIcons.userMinus() : PhosphorIcons.userCheck(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleDischarged,
        ),
      ],

      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      onPageChanged: (page) => notifier.setPage(page),
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<Hospitalization>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.tableCore_serviceColumn, displayValue: (item) => item.physicalService?.name),
  TableColumnDef(
    title: context.l10n.tableCore_hospitalizationProtocolNoColumn,
    displayValue: (item) => item.patient?.protocolNo,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_hospitalizationNationalIdColumn,
    displayValue: (item) => item.patient?.tcNo,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_hospitalizationPatientColumn,
    displayValue: (item) => item.patient?.fullName,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_admissionDateColumn,
    displayValue: (item) => item.admissionDate?.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_dischargeDateColumn,
    displayValue: (item) => item.exitDate?.formattedDate,
  ),
];
