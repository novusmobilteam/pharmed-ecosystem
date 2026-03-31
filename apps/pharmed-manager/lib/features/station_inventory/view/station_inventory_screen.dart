import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/remaining_day_badge.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/station_inventory_notifier.dart';

class StationInventoryScreen extends StatelessWidget {
  const StationInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationInventoryNotifier(getCurrentCabinStockUseCase: context.read())..fetchInventory(),
      child: Consumer<StationInventoryNotifier>(
        builder: (context, vm, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: _buildDesktopLayout(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, StationInventoryNotifier vm) {
    return DesktopLayout(
      title: 'İstasyon Envanter Listesi',
      showAddButton: false,
      child: UnifiedTableView<CabinStock>(
        data: vm.inventory,
        isLoading: vm.anyLoading,
        enableSearch: true,
        enableExcel: true,
        numericColumnIndices: {4, 5, 6, 7},
        cellBuilder: (item, colIndex, value) {
          if (colIndex == 9) {
            return RemainingDayBadge(days: item.remainingDay ?? 0);
          }
          return null;
        },
      ),
    );
  }
}
