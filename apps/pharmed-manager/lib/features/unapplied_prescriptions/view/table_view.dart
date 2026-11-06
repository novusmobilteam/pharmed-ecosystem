part of 'unapplied_prescriptions_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final UnappliedPrescriptionsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<UnappliedHospitalization>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableDateFilter: true,
      enableSearch: true,
      onSearchChanged: notifier.search,
      onDateRangeChanged: notifier.setDateRange,
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noData),

      // Tablo Satır Aksiyonları
      actions: [
        TableActionItem<UnappliedHospitalization>(
          icon: PhosphorIcons.receipt(),
          tooltip: context.l10n.unappliedPrescription_viewDetailsTooltip,
          color: context.colorScheme.onSurface,
          onPressed: notifier.openPanel,
        ),
      ],

      toolbarActions: [
        MedRectangleIconButton(
          tooltip: notifier.showOverdue
              ? context.l10n.unapplied_showUnappliedTooltip
              : context.l10n.unapplied_showOverdueTooltip,
          iconData: notifier.showOverdue ? PhosphorIcons.clockCounterClockwise() : PhosphorIcons.clockClockwise(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleOverdue,
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

List<TableColumnDef<UnappliedHospitalization>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_serviceColumn,
    displayValue: (item) => item.hospitalization?.physicalService?.name,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_roomColumn,
    displayValue: (item) => item.hospitalization?.bed?.room?.name ?? item.hospitalization?.room?.name,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_bedColumn,
    displayValue: (item) => item.hospitalization?.bed?.name,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_patientCodeColumn,
    displayValue: (item) => item.hospitalization?.patient?.protocolNo,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_patientColumn,
    displayValue: (item) => item.hospitalization?.patient?.fullName,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_hospitalizationCodeColumn,
    displayValue: (item) => (item.hospitalization?.code ?? item.hospitalizationId)?.toCustomString(),
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_admissionDateColumn,
    displayValue: (item) => item.hospitalizationDate?.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_prescriptionDateColumn,
    displayValue: (item) => item.lastPrescriptionDate?.formattedDate,
    sortValue: (item) => item.lastPrescriptionDate?.millisecondsSinceEpoch ?? 0,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_medicinesColumn,
    displayValue: (item) => item.materialNames,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_pendingCountColumn,
    numeric: true,
    displayValue: (item) => item.remainingCount?.toCustomString(),
    sortValue: (item) => item.remainingCount ?? 0,
  ),
];
