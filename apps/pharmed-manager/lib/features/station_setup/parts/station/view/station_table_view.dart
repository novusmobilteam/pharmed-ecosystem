import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/station_setup/notifier/station_setup_notifier.dart';

import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../notifier/station_notifier.dart';

class StationTableView extends StatelessWidget {
  const StationTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StationNotifier>(
      builder: (context, notifier, _) {
        return MedTable<Station>(
          data: notifier.items,
          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              context: context,
              onPressed: (station) => context.read<StationSetupNotifier>().openStationPanel(station: station),
            ),
            TableActionItem.delete(context: context, onPressed: (station) => _onDelete(context, notifier, station)),
          ],
          enablePagination: true,
          pageSize: notifier.pageSize,
          currentPage: notifier.currentPage,
          onPageChanged: (page) => notifier.setPage(page),
          columnDefs: _buildColumnDefs(context),
        );
      },
    );
  }
}

void _onDelete(BuildContext context, StationNotifier notifier, Station station) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteStation(
        station,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) =>
            MessageUtils.showSuccessSnackbar(context, msg ?? context.l10n.common_operationSuccessMessage),
      );
    },
  );
}

List<TableColumnDef<Station>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.tableCore_stationCodeColumn, displayValue: (item) => item.id?.toString()),
  TableColumnDef(title: context.l10n.tableCore_stationNameColumn, displayValue: (item) => item.title),
  TableColumnDef(
    title: context.l10n.tableCore_serviceColumn,
    displayValue: (item) => item.service?.name?.toString() ?? '-',
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationDrugWarehouseColumn,
    displayValue: (item) => item.materialWarehouse?.name,
  ),
  TableColumnDef(title: context.l10n.tableCore_stationDrugColumn, displayValue: (item) => item.drugStatus.label),
  TableColumnDef(
    title: context.l10n.tableCore_stationConsumableWarehouseColumn,
    displayValue: (item) => item.medicalConsumableWarehouse?.name,
  ),
  TableColumnDef(
    title: context.l10n.tableCore_stationConsumableColumn,
    displayValue: (item) => item.medicalConsumableStatus.label,
  ),
  TableColumnDef(title: context.l10n.tableCore_stationWorkingTypeColumn, displayValue: (item) => item.type?.label),
];
