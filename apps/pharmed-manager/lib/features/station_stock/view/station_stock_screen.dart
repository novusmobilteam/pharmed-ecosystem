import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/station_stock_notifier.dart';

part 'table_view.dart';

class StationStockScreen extends StatelessWidget {
  const StationStockScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          StationStockNotifier(getStationsUseCase: context.read(), getStationStockUseCase: context.read())
            ..getStations(),
      child: Consumer<StationStockNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.fetchStationsOp),
              showAddButton: false,
              child: Column(
                spacing: 6.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 260,
                    child: MedDropdownInputField(
                      key: ValueKey(notifier.selectedStation),
                      options: notifier.stations,
                      onChanged: notifier.selectStation,
                      initialValue: notifier.selectedStation,
                      labelBuilder: (station) => station?.name,
                      placeholder: context.l10n.assignment_stationSelectPlaceholder,
                    ),
                  ),
                  Expanded(child: TableView(notifier: notifier)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
