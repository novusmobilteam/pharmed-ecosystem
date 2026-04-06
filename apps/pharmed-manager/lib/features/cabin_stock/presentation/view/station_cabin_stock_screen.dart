import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import '../../../stock_transaction/presentation/widgets/stations_list_view.dart';

class StationCabinStockScreen extends StatefulWidget {
  const StationCabinStockScreen({super.key});

  @override
  State<StationCabinStockScreen> createState() => _StationCabinStockScreenState();
}

class _StationCabinStockScreenState extends State<StationCabinStockScreen> {
  Station? _station;

  void _selectStation(Station? station) {
    setState(() {
      _station = station;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileLayout(),
      tablet: TabletLayout(),
      desktop: DesktopLayout(
        title: 'İstasyon Kabin Stok',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: StationsSideListView(onStationSelected: _selectStation)),
            const SizedBox(width: 24),
            Expanded(flex: 5, child: SizedBox()),
            // Expanded(
            //   flex: 5,
            //   child: CabinStockView(key: ValueKey(_station?.id), stationId: _station?.id),
            // ),
          ],
        ),
      ),
    );
  }
}
