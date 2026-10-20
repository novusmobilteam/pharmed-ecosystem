import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/ordered_not_loaded_materials_report_notifier.dart';

part 'table_view.dart';

class OrderedNotLoadedMaterialsReportScreen extends StatelessWidget {
  const OrderedNotLoadedMaterialsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderedNotLoadedMaterialsReportNotifier(
        getStationsUseCase: context.read(),
        getOrderedNotLoadedMaterialsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<OrderedNotLoadedMaterialsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
