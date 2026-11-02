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
      // Kolon sayısı arttı — dar ekranda sıkışmasın diye yatay kaydırma.
      horizontalScroll: true,
      minTableWidth: 1600,
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
      columnDefs: _buildColumnDefs(context, notifier.selectedHospitalization?.patient),
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

/// Hasta bilgisi satırın reçetesindeki yatıştan, yoksa seçili yatıştan alınır.
Patient? _patientOf(PrescriptionItem i, Patient? selected) => i.prescription?.hospitalization?.patient ?? selected;

/// İlaç No = ilacın kodu (yalnızca ilaçlarda; tıbbi sarfta yok).
String _medicineCode(Medicine? medicine) => medicine is Drug ? (medicine.code ?? '-') : '-';

List<TableColumnDef<PrescriptionItem>> _buildColumnDefs(BuildContext context, Patient? selectedPatient) => [
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_tcNoColumn,
    displayValue: (i) => _patientOf(i, selectedPatient)?.tcNo ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_genderColumn,
    flex: 0.7,
    displayValue: (i) => _patientOf(i, selectedPatient)?.gender?.label ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_birthDateColumn,
    flex: 0.8,
    displayValue: (i) => _patientOf(i, selectedPatient)?.birthDate?.formattedDate ?? '-',
    sortValue: (i) => _patientOf(i, selectedPatient)?.birthDate,
  ),
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
    title: context.l10n.patientInventory_table_medicineCodeColumn,
    displayValue: (i) => _medicineCode(i.medicine),
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
    displayValue: (i) => '${i.dosePiece.formatFractional} ${i.medicine?.pieceUnitLabel ?? ''}',
    sortValue: (i) => i.dosePiece,
  ),
  TableColumnDef<PrescriptionItem>(
    title: context.l10n.patientInventory_table_processedQuantityColumn,
    displayValue: (i) => '${(i.lastMovement?.quantity).formatFractional} ${i.medicine?.pieceUnitLabel ?? ''}',
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
