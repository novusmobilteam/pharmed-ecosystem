import 'package:flutter/material.dart';

import '../../../notifier/station_setup_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../notifier/warehouse_notifier.dart';

class WarehouseTableView extends StatelessWidget {
  const WarehouseTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseNotifier>(
      builder: (context, notifier, _) {
        return MedTable<Warehouse>(
          data: notifier.items,
          isLoading: notifier.isLoading(notifier.deleteOp) || notifier.isLoading(notifier.fetchOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              context: context,
              onPressed: (warehouse) => context.read<StationSetupNotifier>().openWarehousePanel(warehouse: warehouse),
            ),
            TableActionItem.delete(context: context, onPressed: (warehouse) => _onDelete(context, notifier, warehouse)),
          ],
          enablePagination: true,
          pageSize: notifier.pageSize,
          currentPage: notifier.currentPage,
          onPageChanged: (page) => notifier.setPage(page),
        );
      },
    );
  }
}

void _onDelete(BuildContext context, WarehouseNotifier notifier, Warehouse warehouse) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () async {
      await notifier.deleteWarehouse(
        warehouse,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg ?? context.l10n.common_operationSuccessMessage),
      );
    },
  );
}
