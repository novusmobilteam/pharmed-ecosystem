import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../auth/notifier/auth_notifier.dart';
import '../notifier/inventory_notifier.dart';
import '../receipts/inventory_receipt.dart';

part 'table_view.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(inventoryNotifierProvider);
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    return MedResponsiveLayout(
      mobile: const MedMobileLayout(),
      tablet: const MedTabletLayout(),
      desktop: Center(
        child: Column(
          spacing: 16.0,
          children: [
            ScreenTitle(
              menu: menu,

              trailing: ReceiptPrintButton(
                enabled: !notifier.isFetchingItems && notifier.items.isNotEmpty,
                buildReceipt: () => buildInventoryReceipt(
                  items: notifier.items,
                  operatorName: ref.read(authNotifierProvider.notifier).currentUser?.fullName,
                ),
              ),
            ),
            Expanded(child: TableView()),
          ],
        ),
      ),
    );
  }
}
