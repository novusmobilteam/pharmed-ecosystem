import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class StationCabinStockScreen extends StatefulWidget {
  const StationCabinStockScreen({super.key});

  @override
  State<StationCabinStockScreen> createState() => _StationCabinStockScreenState();
}

class _StationCabinStockScreenState extends State<StationCabinStockScreen> {
  // ignore: unused_field
  Station? _station;

  @override
  Widget build(BuildContext context) {
    return MedResponsiveLayout(
      mobile: MedMobileLayout(),
      tablet: MedTabletLayout(),
      desktop: MedDesktopLayout(
        title: context.l10n.report_stationStockTitle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Expanded(flex: 1, child: StationsSideListView(onStationSelected: _selectStation)),
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
