import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import 'package:provider/provider.dart';

import '../../../cabin/shared/cabin_inventory/view/cabin_inventory_view.dart';
import '../../../cabin_stock/presentation/widgets/cabin_stock_view.dart';
import '../notifier/medicine_disposal_notifier.dart';

class MedicineDisposalView extends StatelessWidget {
  const MedicineDisposalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MedicineDisposalNotifier(
        getDisposableMaterialsUseCase: context.read(),
        disposeMaterialUseCase: context.read(),
      )..getDisposableMaterials(),
      child: Consumer<MedicineDisposalNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            title: 'İlaç İmha',
            maxHeight: context.height,
            width: context.width,
            actions: [
              if (notifier.selectedItems.isNotEmpty)
                TextButton(
                  onPressed: () => showCabinInventoryView(
                    context,
                    initial: notifier.selectedItems.first,
                    inventoryType: CabinInventoryType.disposal,
                    onSave: (data) async {
                      return notifier.submit(
                        data,
                        onFailed: (message) {
                          MessageUtils.showErrorSnackbar(context, message);
                        },
                        onSuccess: (message) {
                          MessageUtils.showSuccessSnackbar(context, message);
                        },
                      );
                    },
                    quantity: notifier.selectedItems.first.totalQuantity,
                  ),
                  child: Text('İmha Et'),
                ),
            ],
            child: CabinStockView(
              key: ValueKey(notifier.allItems),
              selectedAssignments: notifier.selectedItems,
              onTapUnit: (assignment) {
                notifier.selectItem(
                  assignment,
                  onFailed: (msg) {
                    MessageUtils.showErrorSnackbar(context, msg);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
