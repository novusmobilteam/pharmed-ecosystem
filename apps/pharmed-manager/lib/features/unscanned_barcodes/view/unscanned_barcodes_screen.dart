import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/unscanned_barcodes_notifier.dart';

part 'delete_description_view.dart';
part 'scan_barcode_view.dart';

class UnscannedBarcodesScreen extends StatelessWidget {
  const UnscannedBarcodesScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnscannedBarcodesNotifier(
        deleteUnscannedBarcodeUseCase: context.read(),
        getUnscannedBarcodesUseCase: context.read(),
        scanBarcodeUseCase: context.read(),
        toggleBarcodeWarningUseCase: context.read(),
        getScannedBarcodesUseCase: context.read(),
        getDeletedBarcodesUseCase: context.read(),
        getStationsUseCase: context.read(),
      )..getStations(),
      child: Consumer<UnscannedBarcodesNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              actions: [
                if (notifier.canOpenWarning)
                  IconButton(
                    onPressed: notifier.toggleWarning,
                    tooltip: 'Uyarı Aç/Kapa',
                    icon: Icon(PhosphorIcons.warning()),
                  ),
              ],

              child: _TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

class _TableView extends StatelessWidget {
  const _TableView({required this.notifier});

  final UnscannedBarcodesNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<PrescriptionItem>(
      data: notifier.items,
      isLoading: notifier.isFetching,
      enableExcel: true,
      enableSearch: true,
      enableDateFilter: true,
      onSearchChanged: notifier.search,

      selectionMode: notifier.canSelectItem ? TableSelectionMode.single : TableSelectionMode.none,
      onSingleSelectionChanged: (selectedItem) => notifier.selectedItem = selectedItem,
      columnDefs: _buildColumnDefs(context),

      // Pagination
      enablePagination: true,
      pageSize: notifier.pageSize,
      currentPage: notifier.currentPage,
      serverTotalCount: notifier.totalCount,
      onPageChanged: notifier.setPage,

      // Filter & Search
      initialDateRange: notifier.dateRange,
      onDateRangeChanged: (range) => notifier.setDateRange(range),

      // Kategori
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,
      toolbarActions: [
        MedRectangleIconButton(
          tooltip: switch (notifier.mode) {
            BarcodeListMode.unscanned => context.l10n.unscannedBarcodes_action_showScanned,
            BarcodeListMode.scanned => context.l10n.unscannedBarcodes_action_showDeleted,
            BarcodeListMode.deleted => context.l10n.unscannedBarcodes_action_showUnscanned,
          },
          iconData: switch (notifier.mode) {
            BarcodeListMode.unscanned => PhosphorIcons.checkCircle(),
            BarcodeListMode.scanned => PhosphorIcons.trash(),
            BarcodeListMode.deleted => PhosphorIcons.qrCode(),
          },
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.cycleBarcodeListMode,
        ),
      ],

      actions: [
        if (notifier.canSelectItem)
          TableActionItem(
            icon: PhosphorIcons.qrCode(),
            tooltip: context.l10n.unscannedBarcode_scan_actionLabel,
            onPressed: (data) => showScanBarcodeView(context, data),
          ),
        if (notifier.canSelectItem)
          TableActionItem(
            icon: PhosphorIcons.trash(),
            color: MedColors.red,
            tooltip: context.l10n.common_deleteTooltip,
            onPressed: (data) => showDeleteDescriptionView(context, data),
          ),
      ],
      emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
    );
  }
}

List<TableColumnDef<PrescriptionItem>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(
    title: context.l10n.drugActivity_table_patientColumn,
    displayValue: (item) => item.prescription?.hospitalization?.patient?.fullName,
  ),
  TableColumnDef(
    title: context.l10n.patientInventory_table_barcodeColumn,
    displayValue: (item) => item.medicine?.barcode,
  ),
  TableColumnDef(title: context.l10n.enumCore_medicineTypeDrug, displayValue: (item) => item.medicine?.name),
  TableColumnDef(
    title: context.l10n.patientInventory_table_processDateColumn,
    displayValue: (item) => item.applicationDate.formattedDate,
  ),
  TableColumnDef(title: context.l10n.movement_performedBy, displayValue: (item) => item.applicationUser?.fullName),
  TableColumnDef(
    title: context.l10n.movement_quantityLabel,
    displayValue: (item) => '${item.dosePiece.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
  ),
];
