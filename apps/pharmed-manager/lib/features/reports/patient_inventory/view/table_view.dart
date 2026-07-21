part of 'patient_inventory_report_screen.dart';

class TableView extends StatelessWidget {
  const TableView({super.key, required this.notifier});

  final PatientInventoryReportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enablePDF: true,
      enableDateFilter: true,

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      // Filter & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: notifier.setDateRange,
      onSearchChanged: notifier.search,

      // Kategori
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) =>
          notifier.selectHospitalization(notifier.hospitalizations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.common_patientListTitle,
      columnDefs: _buildColumnDefs(context),
      pdfHeaderBuilder: PdfReportHeader.build(
        title: context.l10n.patientInventory_pdf_title(notifier.selectedHospitalization?.patient?.fullName ?? '-'),
        infoLines: [
          if (notifier.selectedHospitalization?.patient?.id != null)
            context.l10n.patientInventory_pdf_patientCode(notifier.selectedHospitalization!.patient!.id!),
          if (notifier.selectedHospitalization?.physicalService?.name != null)
            context.l10n.patientInventory_pdf_service(notifier.selectedHospitalization!.physicalService!.name!),
          if (notifier.selectedHospitalization?.bed?.name != null)
            context.l10n.patientInventory_pdf_bed(notifier.selectedHospitalization!.bed!.name!),
          context.l10n.patientInventory_pdf_reportDate(DateTime.now().formattedDate),
        ],
        showDate: false,
      ),
    );
  }
}

List<TableColumnDef<PrescriptionItem>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_doctorColumn,
    flex: 0.8,
    displayValue: (i) => i.doctor?.fullName ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_departmentColumn,
    flex: 1.2,
    displayValue: (i) => i.prescription?.hospitalization?.physicalService?.name ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_barcodeColumn,
    displayValue: (i) => i.medicine?.barcode ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_medicineColumn,
    displayValue: (i) => i.medicine?.name ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_requestedQuantityColumn,
    displayValue: (i) => i.dosePiece?.formatFractional ?? '-',
    sortValue: (i) => i.dosePiece,
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_processedQuantityColumn,
    displayValue: (i) => i.lastMovement?.quantity?.formatFractional ?? '-',
    sortValue: (i) => i.lastMovement?.quantity,
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_requestDateColumn,
    displayValue: (i) => i.prescription?.prescriptionDate?.formattedDate ?? '-',
    sortValue: (i) => i.prescription?.prescriptionDate,
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_processDateColumn,
    displayValue: (i) => i.prescription?.prescriptionDate?.formattedDate ?? '-',
    sortValue: (i) => i.prescription?.prescriptionDate,
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_movementColumn,
    displayValue: (i) => i.lastMovement?.type.label(context) ?? '-',
    cellBuilder: (i) => i.lastMovement != null ? MedRxMovementChip(status: i.lastMovement!.type) : const Text('-'),
  ),
];
