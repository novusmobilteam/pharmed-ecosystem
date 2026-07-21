import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/material_usage_report_notifier.dart';

part 'table_view.dart';

class MaterialUsageReportScreen extends StatelessWidget {
  const MaterialUsageReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MaterialUsageReportNotifier(getStationsUseCase: context.read(), getMaterialUsagesUseCase: context.read())
            ..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<MaterialUsageReportNotifier>(
            builder: (context, notifier, _) {
              return TableView(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}
