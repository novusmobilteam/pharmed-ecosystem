import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/unordered_loaded_materials_report_notifier.dart';

part 'table_view.dart';

class UnorderedLoadedMaterialsReportScreen extends StatelessWidget {
  const UnorderedLoadedMaterialsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnorderedLoadedMaterialsReportNotifier(
        getStationsUseCase: context.read(),
        getUnorderedLoadedMaterialsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<UnorderedLoadedMaterialsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
