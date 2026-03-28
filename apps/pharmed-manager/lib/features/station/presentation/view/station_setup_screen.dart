import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/pharmed_icon_button.dart';
import '../notifier/station_setup_notifier.dart';
import 'station_setup_wizard_view.dart';
import 'package:provider/provider.dart';

import '../../../service/presentation/notifier/service_table_notifier.dart';
import '../../../service/presentation/view/service_table_view.dart';
import '../notifier/station_table_notifier.dart';
import 'station_table_view.dart';
import '../../../warehouse/presentation/notifier/warehouse_table_notifier.dart';
import '../../../warehouse/presentation/view/warehouse_table_view.dart';

const _titles = [
  'İstasyon Tanımlama',
  'Servis Tanımlama',
  'Depo Tanımlama',
];

const _onAddLabels = [
  'Yeni İstasyon',
  'Yeni Servis',
  'Yeni Depo',
];

class StationSetupScreen extends StatelessWidget {
  const StationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StationSetupNotifier()),
        ChangeNotifierProvider(
          create: (_) => StationTableNotifier(
            getStationsUseCase: context.read(),
            deleteStationUseCase: context.read(),
          )..getStations(),
        ),
        ChangeNotifierProvider(
          create: (context) => WarehouseTableNotifier(
            getWarehousesUseCase: context.read(),
            deleteWarehouseUseCase: context.read(),
          )..getWarehouses(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceTableNotifier(
            getServicesUseCase: context.read(),
            deleteServiceUseCase: context.read(),
          )..getServices(),
        )
      ],
      child: Consumer<StationSetupNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: DesktopLayout(
              title: _titles.elementAt(notifier.activeIndex),
              showAddButton: true,
              onAddLabel: _onAddLabels[notifier.activeIndex],
              onAddPressed: () => _onAdd(context, notifier.activeIndex),
              actions: [
                PharmedIconButton(
                  onPressed: () => _showStationSetupWizardView(context),
                  label: 'İstasyon Kurulumu Başlat',
                ),
              ],
              child: Column(
                spacing: AppDimensions.registrationDialogSpacing,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 600,
                    child: PharmedSegmentedButton(
                      selectedIndex: notifier.activeIndex,
                      onChanged: (index) => notifier.activeIndex = index,
                      labels: _titles,
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: notifier.activeIndex,
                      children: [
                        StationTableView(),
                        ServiceTableView(),
                        WarehouseTableView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _onAdd(BuildContext context, int index) {
  if (index == 0) {
    showStationRegistrationDialog(context);
  }
  if (index == 1) {
    showServiceRegistrationDialog(context);
  }
  if (index == 2) {
    showWarehouseRegistrationDialog(context);
  }
}

Future<void> _showStationSetupWizardView(BuildContext context) async {
  final result = await showDialog<bool?>(
    context: context,
    builder: (context) => StationSetupWizardView(),
  );

  if (context.mounted && result == true) {
    context.read<StationTableNotifier>().getStations();
  }
}
