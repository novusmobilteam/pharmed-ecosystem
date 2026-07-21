import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../../../notifier/station_setup_notifier.dart';
import '../notifier/service_notifier.dart';

class ServiceTableView extends StatelessWidget {
  const ServiceTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceNotifier>(
      builder: (context, notifier, _) {
        return MedTable<HospitalService>(
          data: notifier.items,
          isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.deleteOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              context: context,
              onPressed: (service) => context.read<StationSetupNotifier>().openServicePanel(service: service),
            ),
            TableActionItem.delete(context: context, onPressed: (service) => _onDelete(context, notifier, service)),
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

void _onDelete(BuildContext context, ServiceNotifier notifier, HospitalService service) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteService(
        service,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) =>
            MessageUtils.showSuccessSnackbar(context, msg ?? context.l10n.common_operationSuccessMessage),
      );
    },
  );
}

List<TableColumnDef<HospitalService>> _buildColumnDefs(BuildContext context) => [
  TableColumnDef(title: context.l10n.service_table_nameColumn, displayValue: (item) => item.name ?? '-'),
  TableColumnDef(title: context.l10n.service_table_branchColumn, displayValue: (item) => item.branch?.name ?? '-'),
  TableColumnDef(title: context.l10n.service_table_managerColumn, displayValue: (item) => item.user?.name ?? '-'),
  TableColumnDef(title: context.l10n.service_table_statusColumn, displayValue: (item) => item.status.label),
];
