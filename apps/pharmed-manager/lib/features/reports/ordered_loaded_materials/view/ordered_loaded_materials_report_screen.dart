import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/ordered_loaded_materials_report_notifier.dart';

part 'table_view.dart';

class OrderedLoadedMaterialsReportScreen extends StatelessWidget {
  const OrderedLoadedMaterialsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderedLoadedMaterialsReportNotifier(
        getStationsUseCase: context.read(),
        getOrderedLoadedMaterialsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<OrderedLoadedMaterialsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
