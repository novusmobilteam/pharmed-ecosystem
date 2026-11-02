part of 'unapplied_prescriptions_screen.dart';

/// Geciken uygulamalar tablosu — her satır tek bir reçete kalemi (ilaç uygulaması).
/// Açıldığı her seferde veriyi baştan çeker.
class OverdueTableView extends StatefulWidget {
  const OverdueTableView({super.key, required this.notifier, required this.onToggle});

  final OverdueApplicationsNotifier notifier;
  final VoidCallback onToggle;

  @override
  State<OverdueTableView> createState() => _OverdueTableViewState();
}

class _OverdueTableViewState extends State<OverdueTableView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.notifier.resetFilters(notify: false, resetDate: false);
      widget.notifier.fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        return MedTable<PrescriptionItem>(
          data: notifier.items,
          isLoading: notifier.isFetching,
          enableExcel: true,
          enableDateFilter: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          onDateRangeChanged: notifier.setDateRange,
          emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noData),
          toolbarActions: [
            MedRectangleIconButton(
              tooltip: context.l10n.unapplied_showUnappliedTooltip,
              iconData: PhosphorIcons.clockCounterClockwise(),
              color: MedColors.amberLight,
              iconColor: MedColors.amber,
              onPressed: widget.onToggle,
            ),
          ],
          enablePagination: true,
          pageSize: notifier.pageSize,
          currentPage: notifier.currentPage,
          onPageChanged: (page) => notifier.setPage(page),
          columnDefs: _buildOverdueColumnDefs(context),
        );
      },
    );
  }
}

List<TableColumnDef<PrescriptionItem>> _buildOverdueColumnDefs(BuildContext context) {
  final l10n = context.l10n;
  Hospitalization? hosp(PrescriptionItem item) => item.prescription?.hospitalization ?? item.hospitalization;

  return [
    TableColumnDef(
      title: l10n.unappliedPrescription_table_serviceColumn,
      displayValue: (item) => hosp(item)?.physicalService?.name ?? item.physicalService?.name,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_table_patientCodeColumn,
      displayValue: (item) => hosp(item)?.patient?.protocolNo,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_table_patientColumn,
      displayValue: (item) => hosp(item)?.patient?.fullName,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_medicineColumn,
      displayValue: (item) => item.medicine?.name,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_doseColumn,
      displayValue: (item) => item.dosePiece?.formatFractional,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_scheduledTimeColumn,
      displayValue: (item) => item.time?.formattedDateTime,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_applicationTimeColumn,
      displayValue: (item) => item.applicationDate?.formattedDateTime,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_appliedByColumn,
      displayValue: (item) => item.applicationUser?.fullName,
    ),
    TableColumnDef(
      title: l10n.unappliedPrescription_overdueTable_delayColumn,
      displayValue: (item) => _delayLabel(context, item),
    ),
  ];
}

/// Planlanan saat ile uygulama zamanı arasındaki fark. Henüz uygulanmamışsa
/// şu ana kadar geçen süre gösterilir.
String? _delayLabel(BuildContext context, PrescriptionItem item) {
  final scheduled = item.time;
  if (scheduled == null) return null;
  final diff = (item.applicationDate ?? DateTime.now()).difference(scheduled);
  if (diff.isNegative) return null;
  final hours = diff.inHours;
  final minutes = diff.inMinutes.remainder(60);
  return hours > 0
      ? context.l10n.unappliedPrescription_overdueTable_delayHoursMinutes(hours, minutes)
      : context.l10n.unappliedPrescription_overdueTable_delayMinutes(minutes);
}
