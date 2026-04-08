import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/widgets/side_panel.dart';
import '../parts/service/view/service_form_panel.dart';
import '../notifier/station_setup_notifier.dart';
import '../parts/station/view/station_form_panel.dart';
import '../parts/warehouse/view/warehouse_form_panel.dart';
import 'station_setup_wizard_view.dart';
import 'package:provider/provider.dart';

import '../parts/service/notifier/service_notifier.dart';
import '../parts/service/view/service_table_view.dart';
import '../parts/station/notifier/station_notifier.dart';
import '../parts/station/view/station_table_view.dart';
import '../parts/warehouse/notifier/warehouse_notifier.dart';
import '../parts/warehouse/view/warehouse_table_view.dart';

const _titles = ['İstasyon Tanımlama', 'Servis Tanımlama', 'Depo Tanımlama'];

const _onAddLabels = ['Yeni İstasyon', 'Yeni Servis', 'Yeni Depo'];

class StationSetupScreen extends StatelessWidget {
  const StationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StationSetupNotifier()),
        ChangeNotifierProvider(
          create: (_) =>
              StationNotifier(getStationsUseCase: context.read(), deleteStationUseCase: context.read())..getStations(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              WarehouseNotifier(getWarehousesUseCase: context.read(), deleteWarehouseUseCase: context.read())
                ..getWarehouses(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ServiceNotifier(getServicesUseCase: context.read(), deleteServiceUseCase: context.read())..getServices(),
        ),
      ],
      child: Consumer<StationSetupNotifier>(
        builder: (context, notifier, _) {
          return DesktopLayout(
            title: 'İstasyon Tanımlama',
            subtitle: 'İstasyon, Servis ve Depo tanımlamalarını yönetin.',
            actions: [
              PharmedButton(
                onPressed: () => _onAdd(context, notifier.activeIndex),
                label: _onAddLabels.elementAt(notifier.activeIndex),
              ),
              PharmedButton(
                onPressed: () => _showStationSetupWizardView(context),
                label: 'Kurulum Sihirbazı',
                backgroundColor: MedColors.amber,
              ),
            ],
            child: SidePanelWrapper(
              isOpen: notifier.isPanelOpen,
              width: 480,
              panel: switch (notifier.panelType) {
                StationPanelType.station => StationFormPanel(),
                StationPanelType.service => ServiceFormPanel(),
                StationPanelType.warehouse => WarehouseFormPanel(),
                null => const SizedBox.shrink(),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 500,
                    child: PharmedSegmentedButton(
                      selectedIndex: notifier.activeIndex,
                      onChanged: (index) => notifier.activeIndex = index,
                      labels: _titles,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: IndexedStack(
                      index: notifier.activeIndex,
                      children: [StationTableView(), ServiceTableView(), WarehouseTableView()],
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
  final notifier = context.read<StationSetupNotifier>();
  switch (index) {
    case 0:
      notifier.openStationPanel();
    case 1:
      notifier.openServicePanel();
    case 2:
      notifier.openWarehousePanel();
  }
}

Future<void> _showStationSetupWizardView(BuildContext context) async {
  final result = await showDialog<bool?>(context: context, builder: (context) => StationSetupWizardView());

  if (context.mounted && result == true) {
    context.read<StationNotifier>().getStations();
  }
}
