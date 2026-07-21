part of 'unapplied_prescriptions_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final UnappliedPrescriptionsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Prescription>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableDateFilter: true,
      enableSearch: true,
      onSearchChanged: notifier.search,
      onDateRangeChanged: notifier.setDateRange,

      // Tablo Satır Aksiyonları
      actions: [
        TableActionItem(
          icon: PhosphorIcons.qrCode(),
          tooltip: context.l10n.unappliedPrescription_viewDetailsTooltip,
          color: context.colorScheme.onSurface,
          onPressed: (item) => showPrescriptionDetailView(context, prescription: item),
        ),
      ],
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),

      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      onPageChanged: (page) => notifier.setPage(page),
      columnDefs: _buildColumnDefs(context),
    );
  }
}

List<TableColumnDef<Prescription>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_serviceColumn,
    displayValue: (item) => item.hospitalization?.physicalService?.name,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_roomColumn,
    displayValue: (item) => item.hospitalization?.room?.name,
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
    displayValue: (item) => item.hospitalizationId?.toCustomString(),
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_admissionDateColumn,
    displayValue: (item) => item.hospitalizationDate?.formattedDate,
  ),
  TableColumnDef(
    title: context.l10n.unappliedPrescription_table_pendingCountColumn,
    displayValue: (item) => item.remainingCount?.toCustomString(),
  ),
];
