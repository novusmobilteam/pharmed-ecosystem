import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../widgets/cabin_assignment_mini_panel.dart';
import '../notifier/station_stock_data_notifier.dart';

part 'table_view.dart';

class StationStockDataScreen extends StatelessWidget {
  const StationStockDataScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationStockDataNotifier(
        getStationsUseCase: context.read(),
        getCabinsByStationUseCase: context.read(),
        getCabinAssignmentsUseCase: context.read(),
        getCabinVisualizerDataUseCase: context.read(),
      )..init(),
      child: Consumer<StationStockDataNotifier>(
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
