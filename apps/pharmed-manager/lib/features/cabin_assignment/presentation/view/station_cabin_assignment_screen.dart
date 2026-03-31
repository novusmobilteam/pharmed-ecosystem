import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../stock_transaction/presentation/widgets/stations_list_view.dart';
import '../widgets/editor/cabin_assignment_view.dart';

class StationCabinAssignmentScreen extends StatefulWidget {
  const StationCabinAssignmentScreen({super.key});

  @override
  State<StationCabinAssignmentScreen> createState() => _StationCabinAssignmentScreenState();
}

class _StationCabinAssignmentScreenState extends State<StationCabinAssignmentScreen> {
  Station? _station;

  void _selectStation(Station? station) {
    setState(() {
      _station = station;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const MobileLayout(),
      tablet: const TabletLayout(),
      desktop: DesktopLayout(
        title: 'İstasyon Malzeme Atama',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: StationsSideListView(onStationSelected: _selectStation)),
            const SizedBox(width: 24),
            Expanded(flex: 5, child: SizedBox()),
            // Expanded(
            //   flex: 5,
            //   child: CabinAssignmentView(key: ValueKey(_station?.id), stationId: _station?.id),
            // ),
          ],
        ),
      ),
    );
  }
}
