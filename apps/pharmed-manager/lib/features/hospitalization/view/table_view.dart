part of 'hospitalization_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final HospitalizationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Hospitalization>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: true,
      onSearchChanged: notifier.search,
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.pen(),
          tooltip: context.l10n.hospitalization_formTitleEdit,
          onPressed: (hospitalization) {
            notifier.selectHospitalization(hospitalization);
            notifier.openPanel(HospitalizationPanelMode.editHospitalization);
          },
        ),
        TableActionItem(
          icon: PhosphorIcons.user(),
          tooltip: context.l10n.hospitalization_editPatientTooltip,
          onPressed: (hospitalization) {
            notifier.selectHospitalization(hospitalization);
            notifier.openPanel(HospitalizationPanelMode.editPatient);
          },
        ),
        TableActionItem(
          icon: PhosphorIcons.plus(),
          tooltip: context.l10n.hospitalization_formTitleNew,
          onPressed: (hospitalization) {
            notifier.selectHospitalization(hospitalization);
            notifier.openPanel(HospitalizationPanelMode.newHospitalizationWithPatient);
          },
        ),
      ],
      toolbarActions: [
        MedRectangleIconButton(
          tooltip: notifier.showDischarged
              ? context.l10n.hospitalization_showActiveTooltip
              : context.l10n.hospitalization_showDischargedTooltip,
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
