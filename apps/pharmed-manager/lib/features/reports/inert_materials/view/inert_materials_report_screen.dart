import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/inert_materials_report_notifier.dart';

part 'table_view.dart';

class InertMaterialsReportScreen extends StatelessWidget {
  const InertMaterialsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InertMaterialsReportNotifier(
        getStationsUseCase: context.read(),
        getInertMaterialsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<InertMaterialsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
