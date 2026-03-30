import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/remaining_day_badge.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/inventory_notifier.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryNotifier(getCurrentCabinStockUseCase: context.read())..getInventory(),
      child: ResponsiveLayout(
        mobile: const SizedBox(),
        tablet: const SizedBox(),
        desktop: DesktopLayout(title: 'İlaç Envanter', child: _buildChild()),
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<InventoryNotifier>(
      builder: (context, vm, _) {
        if (vm.isFetching && vm.inventory.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (vm.isEmpty) {
          return CommonEmptyStates.noData();
        }

        return UnifiedTableView<CabinStock>(
          data: vm.filteredItems,
          numericColumnIndices: const {4, 5, 6, 7, 9},
          enableSearch: true,
          onSearchChanged: vm.search,
          enableExcel: true,
          isLoading: vm.isFetching,
          cellBuilder: (item, colIndex, value) {
            if (colIndex == 9) return RemainingDayBadge(days: item.remainingDay ?? 0);
            return null; // varsayılan text render
          },
        );
      },
    );
  }
}
