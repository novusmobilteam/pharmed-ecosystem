import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/station_empty_compartments_report_notifier.dart';

part 'table_view.dart';
part 'station_empty_compartment_detail_dialog.dart';

class StationEmptyCompartmentsReportScreen extends StatelessWidget {
  const StationEmptyCompartmentsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationEmptyCompartmentsReportNotifier(
        getStationsUseCase: context.read(),
        getStationEmptyCompartmentsUseCase: context.read(),
        getStationEmptyCompartmentDetailsUseCase: context.read(),
        getDrawerTypesUseCase: context.read(),
      )..init(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<StationEmptyCompartmentsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
