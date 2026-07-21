import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/patient_inventory_report_notifier.dart';
part 'table_view.dart';

class PatientInventoryReportScreen extends StatelessWidget {
  const PatientInventoryReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientInventoryReportNotifier(
        getHospitalizationsUseCase: context.read(),
        getPatientInventoryUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<PatientInventoryReportNotifier>(
            builder: (context, notifier, _) {
              return TableView(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}
