import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/cabin_temperature_notifier.dart';

part 'cabin_temperature_form_view.dart';

class CabinTemperatureScreen extends StatefulWidget {
  const CabinTemperatureScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  State<CabinTemperatureScreen> createState() => _CabinTemperatureScreenState();
}

class _CabinTemperatureScreenState extends State<CabinTemperatureScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CabinTemperatureNotifier(
        getStationsUseCase: context.read(),
        getCabinTemperatureUseCase: context.read(),
        getCabinsByStationUseCase: context.read(),
        createCabinTemperatureUseCase: context.read(),
      )..getStations(),
      child: Consumer<CabinTemperatureNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: widget.menu,
              showAddButton: true,
              child: Container(
                decoration: AppDimensions.cardDecoration(context),
                child: Row(
                  children: [
                    MedSidePanel<Station>(
                      title: context.l10n.report_stationsCategoryTitle,
                      items: notifier.stations,
                      selected: notifier.selectedStation,
                      labelBuilder: (s) => s.name ?? '-',
                      onSelected: notifier.selectStation,
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFEEF0F4)),
                    SizedBox(width: 700, child: CabinTemperatureFormView(formKey: formKey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
