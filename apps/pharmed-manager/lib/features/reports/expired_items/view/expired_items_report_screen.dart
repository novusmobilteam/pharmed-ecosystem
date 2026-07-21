import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import 'package:provider/provider.dart';

import '../notifier/expired_items_report_notifier.dart';

part 'table_view.dart';

class ExpiredItemsReportScreen extends StatelessWidget {
  const ExpiredItemsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ExpiredItemsReportNotifier(getExpiredStocksUseCase: context.read(), getStationsUseCase: context.read())
            ..getStations(),
      builder: (context, child) {
        return Consumer<ExpiredItemsReportNotifier>(
          builder: (context, notifier, _) {
            return MedResponsiveLayout(
              mobile: const MedMobileLayout(),
              tablet: const MedTabletLayout(),
              desktop: MedDesktopLayout(
                menu: menu,
                showAddButton: false,
                child: TableView(notifier: notifier),
              ),
            );
          },
        );
      },
    );
  }
}
