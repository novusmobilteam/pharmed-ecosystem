import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/expiry_date_materials_report_notifier.dart';

part 'table_view.dart';

/// SKT Malzeme Listesi — menü slug: `expiry-date-material-list`.
class ExpiryDateMaterialsReportScreen extends StatelessWidget {
  const ExpiryDateMaterialsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpiryDateMaterialsReportNotifier(
        getExpiryDateStocksUseCase: context.read(),
        getStationsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: const MedMobileLayout(),
        tablet: const MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          showAddButton: false,
          child: Consumer<ExpiryDateMaterialsReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
