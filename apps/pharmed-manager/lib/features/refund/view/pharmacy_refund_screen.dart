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
        TableActionItem(
          icon: PhosphorIcons.arrowFatDown(),
          tooltip: 'İade Al',
          onPressed: (refund) => notifier.completeRefund(
            refund,
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
          ),
        ),
        TableActionItem.delete(context: context, onPressed: (refund) => showDeleteDescriptionView(context, refund)),
      ],

      toolbarActions: [
        MedRectangleIconButton(
          tooltip: notifier.showCompleted
              ? context.l10n.refund_showCompletedTooltip
              : context.l10n.refund_showIncompleteTooltip,
          iconData: notifier.showCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.hourglass(),
          color: MedColors.amberLight,
          iconColor: MedColors.amber,
          onPressed: notifier.toggleCompleted,
        ),
      ],

      columnDefs: notifier.showCompleted ? _buildColumnDefs() : null,
      cellBuilder: notifier.showCompleted ? _buildCell : null,
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

List<TableColumnDef> _buildColumnDefs() => const [
  TableColumnDef(title: 'Hasta Kodu', flex: 0.8), // colIndex: 0
  TableColumnDef(title: 'Hasta', flex: 1.2), // colIndex: 1
  TableColumnDef(title: 'Kullanıcı'), // colIndex: 2
  TableColumnDef(title: 'Malzeme', flex: 1.5), // colIndex: 3
  TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 4
  TableColumnDef(title: 'Tarih'), // colIndex: 5
  TableColumnDef(title: 'İade Alan Kullanıcı'), // colIndex: 6
  TableColumnDef(title: 'İade Alma Tarihi'), // colIndex: 7
];

Widget? _buildCell(Refund item, int colIndex, dynamic _) {
  return switch (colIndex) {
    0 => Text(item.patient?.id?.toString() ?? '-'),
    1 => Text(item.patient?.fullName ?? '-'),
    2 => Text(item.user ?? '-'),
    3 => Text(item.medicine?.name ?? '-'),
    4 => Text(item.quantity?.formatFractional ?? '-'),
    5 => Text(item.createdDate?.formattedDate ?? '-'),
    6 => Text(item.receiveUser?.fullName ?? '-'),
    7 => Text(item.receiveDate?.formattedDate ?? '-'),

    _ => null,
  };
}
