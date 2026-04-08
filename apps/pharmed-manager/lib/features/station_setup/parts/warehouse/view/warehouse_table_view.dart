import 'package:flutter/material.dart';

import '../../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../../core/widgets/unified_table/unified_table_view.dart';
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
        return UnifiedTableView<Warehouse>(
          data: notifier.allItems,
          isLoading: notifier.isLoading(notifier.deleteOp) || notifier.isLoading(notifier.fetchOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              onPressed: (warehouse) => context.read<StationSetupNotifier>().openWarehousePanel(warehouse: warehouse),
            ),
            TableActionItem.delete(onPressed: (warehouse) => _onDelete(context, notifier, warehouse)),
          ],
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
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}
