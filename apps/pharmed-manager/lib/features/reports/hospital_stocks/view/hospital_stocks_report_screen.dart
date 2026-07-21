import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/hospital_stocks_report_notifier.dart';

part 'table_view.dart';

class HospitalStocksReportScreen extends StatelessWidget {
  const HospitalStocksReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          HospitalStocksReportNotifier(getStationsUseCase: context.read(), getHospitalStocksUseCase: context.read())
            ..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<HospitalStocksReportNotifier>(
            builder: (context, notifier, _) {
              return TableView(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}
