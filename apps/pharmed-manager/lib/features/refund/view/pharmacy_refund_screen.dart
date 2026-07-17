import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../notifier/pharmacy_refund_notifier.dart';

class PharmacyRefundScreen extends StatelessWidget {
  const PharmacyRefundScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PharmacyRefundNotifier(
        getPharmacyRefundsUseCase: context.read(),
        completePharmacyRefundUseCase: context.read(),
        deletePharmacyRefundUseCase: context.read(),
        getStationsUseCase: context.read(),
        getCompletedPharmacyRefundsUseCase: context.read(),
      )..getStations(),
      child: Consumer<PharmacyRefundNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              title: menu.name ?? 'Eczane İade Alma',
              subtitle: menu.description,
              isLoading: notifier.isLoading(notifier.completeOp),
              child: _RefundTableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

class _RefundTableView extends StatelessWidget {
  const _RefundTableView({required this.notifier});

  final PharmacyRefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<Refund>(
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
      onCategoryChanged: (id) => notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
      categoryTitle: context.l10n.report_stationsCategoryTitle,

      actions: [
        if (!notifier.showCompleted)
          TableActionItem(
            icon: PhosphorIcons.arrowFatDown(),
            tooltip: 'İade Al',
            onPressed: (refund) => notifier.completeRefund(
              refund,
              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
              onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
            ),
          ),
        if (!notifier.showCompleted)
          TableActionItem.delete(context: context, onPressed: (refund) => showDeleteDescriptionView(context, refund)),
      ],

      toolbarActions: [
        MedRectangleIconButton(
          tooltip: !notifier.showCompleted
              ? context.l10n.refund_showCompletedTooltip
              : context.l10n.refund_showIncompleteTooltip,
          iconData: !notifier.showCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.hourglass(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleCompleted,
        ),
      ],

      columnDefs: notifier.showCompleted ? _buildColumnDefs() : null,

      // cellBuilder: notifier.showCompleted ? _buildCell : null,
      pdfTitle: 'Eczane İade Raporu',
      // veya daha zengin:
      pdfHeaderBuilder: PdfReportHeader.build(
        title: 'Eczane İade Raporu',
        infoLines: [
          if (notifier.selectedStation != null) 'İstasyon: ${notifier.selectedStation!.name}',
          if (notifier.dateRange != null)
            'Tarih: ${notifier.dateRange?.start.formattedDate} - ${notifier.dateRange?.end.formattedDate}',
        ],
      ),
    );
  }
}

void showDeleteDescriptionView(BuildContext context, Refund data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<PharmacyRefundNotifier>(),
      child: DeleteDescriptionView(refund: data),
    ),
  );
}

class DeleteDescriptionView extends StatelessWidget {
  const DeleteDescriptionView({super.key, required this.refund});

  final Refund refund;

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyRefundNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Açıklama',
          maxHeight: 350,
          saveButtonText: 'Sil',
          onSave: () {
            MessageUtils.showConfirmDeleteDialog(
              context: context,
              onConfirm: () {
                notifier.deleteRefund(
                  refund,
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
          child: Column(
            children: [
              MedTextInputField(
                maxLines: 3,
                label: 'Silme nedeninizi açıklayınız',
                onChanged: (value) => notifier.description = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}

// TODO : Localization
List<TableColumnDef<Refund>> _buildColumnDefs() => [
  TableColumnDef<Refund>(title: 'Hasta Kodu', displayValue: (r) => r.patient?.id?.toString() ?? '-'),
  TableColumnDef<Refund>(title: 'Hasta', displayValue: (r) => r.patient?.fullName ?? '-'),
  TableColumnDef<Refund>(title: 'Kullanıcı', displayValue: (r) => r.createdUser?.fullName ?? '-'),
  TableColumnDef<Refund>(title: 'Malzeme', displayValue: (r) => r.medicine?.name ?? '-'),
  TableColumnDef<Refund>(
    title: 'Miktar',
    numeric: true,
    displayValue: (r) => r.quantity?.formatFractional ?? '-',
    sortValue: (r) => r.quantity,
  ),
  TableColumnDef<Refund>(
    title: 'Tarih',
    displayValue: (r) => r.createdDate?.formattedDate ?? '-',
    sortValue: (r) => r.createdDate,
  ),
  TableColumnDef<Refund>(title: 'İade Alan Kullanıcı', displayValue: (r) => r.approvedUser?.fullName ?? '-'),
  TableColumnDef<Refund>(
    title: 'İade Alma Tarihi',
    displayValue: (r) => r.approvedDate?.formattedDate ?? '-',
    sortValue: (r) => r.approvedDate,
  ),
];
