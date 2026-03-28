import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../../../station/domain/entity/station.dart';
import '../../../station/domain/usecase/get_stations_usecase.dart';
part 'station_list_notifier.dart';

class StationsSideListView extends StatelessWidget {
  final Function(Station) onStationSelected;

  const StationsSideListView({super.key, required this.onStationSelected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationListNotifier(context.read())..getStations(onInitialLoad: onStationSelected),
      child: Consumer<StationListNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading(notifier.fetchOp)) return SizedBox();

          return PharmedSideListView<Station>(
            title: 'İstasyonlar',
            items: notifier.stations,
            activeIndex: notifier.activeIndex,
            onTap: (station) {
              notifier.selectStation(station);
              onStationSelected(station);
            },
            labelBuilder: (w) => w.name,
          );
        },
      ),
    );
  }
}
