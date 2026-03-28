import 'package:flutter/material.dart';

import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/warehouse_form_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/warehouse.dart';
import '../notifier/warehouse_table_notifier.dart';
import 'warehouse_registration_dialog.dart';

class WarehouseTableView extends StatelessWidget {
  const WarehouseTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WarehouseTableNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView<Warehouse>(
          data: notifier.allItems,
          isLoading: notifier.isLoading(notifier.deleteOp) || notifier.isLoading(notifier.fetchOp),
          enableExcel: true,
          enableSearch: true,
          onSearchChanged: notifier.search,
          actions: [
            TableActionItem.edit(
              onPressed: (warehouse) => showWarehouseRegistrationDialog(context, warehouse: warehouse),
            ),
            TableActionItem.delete(
              onPressed: (warehouse) => _onDelete(context, notifier, warehouse),
            )
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, WarehouseTableNotifier notifier, Warehouse warehouse) {
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

Future<void> showWarehouseRegistrationDialog(BuildContext context, {Warehouse? warehouse}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => WarehouseFormNotifier(
        warehouse: warehouse,
        createWarehouseUseCase: context.read(),
        updateWarehouseUseCase: context.read(),
      ),
      child: WarehouseRegistrationDialog(),
    ),
  );

  if (result == true && context.mounted) {
    context.read<WarehouseTableNotifier>().getWarehouses();
  }
}
