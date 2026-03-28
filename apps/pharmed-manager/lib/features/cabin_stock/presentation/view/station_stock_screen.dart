import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/station_stock.dart';
import '../notifier/station_stock_notifier.dart';

class StationStockScreen extends StatelessWidget {
  const StationStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => StationStockNotifier(
        getStationStocksUseCase: context.read(),
        getStationsUseCase: context.read(),
      )..getStations(),
      child: Consumer<StationStockNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: DesktopLayout(
              title: 'İstasyon Stok Listesi',
              child: _buildChild(notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild(StationStockNotifier notifier) {
    if (notifier.isFetching && notifier.stations.isEmpty) {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (notifier.stations.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return UnifiedTableView<StationStock>(
      data: notifier.filteredItems,
      isLoading: notifier.isFetching,
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: (id) => notifier.selectStation(
        notifier.stations.firstWhere((s) => s.id.toString() == id),
      ),
      numericColumnIndices: const {3, 4, 5, 6, 7},
      columnFlexes: const [1.0, 1.3, 2.5, 0.9, 0.9, 0.9, 0.9, 0.9],
      enableSearch: true,
      onSearchChanged: notifier.search,
      enableExcel: true,
    );
  }
}
