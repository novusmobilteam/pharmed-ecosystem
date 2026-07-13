import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/patient_inventory_report_notifier.dart';

class PatientInventoryReportScreen extends StatelessWidget {
  const PatientInventoryReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientInventoryReportNotifier(
        getHospitalizationsUseCase: context.read(),
        getPatientInventoryUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          title: menu.name ?? context.l10n.report_stationTransactionTitleFallback,
          subtitle: menu.description,
          child: Consumer<PatientInventoryReportNotifier>(
            builder: (context, notifier, _) {
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
                columnDefs: _buildColumnDefs(),
                pdfHeaderBuilder: PdfReportHeader.build(
                  title:
                      '${notifier.selectedHospitalization?.patient?.fullName} adlı hastaya ait Hasta Envanter Listesi',
                  infoLines: [
                    if (notifier.selectedHospitalization?.patient?.id != null)
                      'Hasta Kodu: ${notifier.selectedHospitalization?.patient?.id}',
                    if (notifier.selectedHospitalization?.physicalService?.name != null)
                      'Servis: ${notifier.selectedHospitalization?.physicalService!.name}',
                    if (notifier.selectedHospitalization?.bed?.name != null)
                      'Yatak: ${notifier.selectedHospitalization?.bed?.name}',
                    'Rapor Tarihi: ${DateTime.now().formattedDate}',
                  ],
                  showDate: false, // tarihi infoLines içinde verdik, sağ üstte tekrar istemiyoruz
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// TODO : Localization
List<TableColumnDef<PrescriptionItem>> _buildColumnDefs() => [
  TableColumnDef<PrescriptionItem>(title: 'Doktor', flex: 0.8, displayValue: (i) => i.doctor?.fullName ?? '-'),
  TableColumnDef<PrescriptionItem>(
    title: 'Bölüm',
    flex: 1.2,
    displayValue: (i) => i.prescription?.hospitalization?.physicalService?.name ?? '-',
  ),
  TableColumnDef<PrescriptionItem>(title: 'Barkod', displayValue: (i) => i.medicine?.barcode ?? '-'),
  TableColumnDef<PrescriptionItem>(title: 'Malzeme', displayValue: (i) => i.medicine?.name ?? '-'),
  TableColumnDef<PrescriptionItem>(
    title: 'İstenen Miktar',
    displayValue: (i) => i.dosePiece?.formatFractional ?? '-',
    sortValue: (i) => i.dosePiece,
  ),
  TableColumnDef<PrescriptionItem>(
    title: 'İşlem Miktarı',
    displayValue: (i) => i.lastMovement?.quantity?.formatFractional ?? '-',
    sortValue: (i) => i.lastMovement?.quantity,
  ),
  TableColumnDef<PrescriptionItem>(
    title: 'İstem Tarihi',
    displayValue: (i) => i.prescription?.prescriptionDate?.formattedDate ?? '-',
    sortValue: (i) => i.prescription?.prescriptionDate,
  ),
  TableColumnDef<PrescriptionItem>(
    title: 'İşlem Tarihi',
    displayValue: (i) => i.prescription?.prescriptionDate?.formattedDate ?? '-',
    sortValue: (i) => i.prescription?.prescriptionDate,
  ),
  // ── "İşlem" kolonu ──────────────────────────────────────────────
  // A) Düz text (mevcut davranış):
  //TableColumnDef<PrescriptionItem>(title: 'İşlem', displayValue: (i) => i.lastMovement?.type.label ?? '-'),
  // B) Chip istersen A) yerine bunu kullan (filtre/export displayValue'dan):
  TableColumnDef<PrescriptionItem>(
    title: 'İşlem',
    displayValue: (i) => i.lastMovement?.type.label ?? '-',
    cellBuilder: (i) => i.lastMovement != null ? MedRxMovementChip(status: i.lastMovement!.type) : const Text('-'),
  ),
];
