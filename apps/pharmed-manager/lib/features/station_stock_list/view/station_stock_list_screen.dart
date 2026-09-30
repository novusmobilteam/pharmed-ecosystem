import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/station_stock_list_notifier.dart';

part 'table_view.dart';

class StationStockListScreen extends StatelessWidget {
  const StationStockListScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          StationStockListNotifier(getStationsUseCase: context.read(), getStationStockUseCase: context.read())
            ..getStations(),
      child: Consumer<StationStockListNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              isLoading: notifier.isFetching,
              child: TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}
