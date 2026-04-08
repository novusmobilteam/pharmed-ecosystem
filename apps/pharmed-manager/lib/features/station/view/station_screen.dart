import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/widgets/side_panel.dart';
import 'station_form_panel.dart';
import 'station_setup_wizard_view.dart';
import 'package:provider/provider.dart';

import '../../service/presentation/notifier/service_table_notifier.dart';
import '../../service/presentation/view/service_table_view.dart';
import '../notifier/station_notifier.dart';
import 'station_table_view.dart';
import '../../warehouse/presentation/notifier/warehouse_table_notifier.dart';
import '../../warehouse/presentation/view/warehouse_table_view.dart';

const _titles = ['İstasyon Tanımlama', 'Servis Tanımlama', 'Depo Tanımlama'];

const _onAddLabels = ['Yeni İstasyon', 'Yeni Servis', 'Yeni Depo'];

class StationScreen extends StatelessWidget {
  const StationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              StationNotifier(getStationsUseCase: context.read(), deleteStationUseCase: context.read())..getStations(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              WarehouseTableNotifier(getWarehousesUseCase: context.read(), deleteWarehouseUseCase: context.read())
                ..getWarehouses(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ServiceTableNotifier(getServicesUseCase: context.read(), deleteServiceUseCase: context.read())
                ..getServices(),
        ),
      ],
      child: Consumer<StationNotifier>(
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
              panel: StationFormPanel(),
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
  if (index == 0) {
    context.read<StationNotifier>().openPanel();
    //showStationRegistrationDialog(context);
  }
  if (index == 1) {
    showServiceRegistrationDialog(context);
  }
  if (index == 2) {
    showWarehouseRegistrationDialog(context);
  }
}

Future<void> _showStationSetupWizardView(BuildContext context) async {
  final result = await showDialog<bool?>(context: context, builder: (context) => StationSetupWizardView());

  if (context.mounted && result == true) {
    context.read<StationNotifier>().getStations();
  }
}
