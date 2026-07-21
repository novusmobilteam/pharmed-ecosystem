import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/cabin_temperature_report_notifier.dart';
part 'table_view.dart';

class CabinTemperatureReportScreen extends StatelessWidget {
  const CabinTemperatureReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CabinTemperatureReportNotifier(
        getStationsUseCase: context.read(),
        getCabinTemperaturesUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(menu: menu, child: TableView()),
      ),
    );
  }
}
