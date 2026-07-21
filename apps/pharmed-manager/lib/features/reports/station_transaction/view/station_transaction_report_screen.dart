import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../notifier/station_transaction_report_notifier.dart';
import 'package:provider/provider.dart';

part 'table_view.dart';

class StationTransactionReportScreen extends StatelessWidget {
  const StationTransactionReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationTransactionReportNotifier(
        getStationsUseCase: context.read(),
        getStationTransactionsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<StationTransactionReportNotifier>(
            builder: (context, notifier, _) {
              return TableView(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}
