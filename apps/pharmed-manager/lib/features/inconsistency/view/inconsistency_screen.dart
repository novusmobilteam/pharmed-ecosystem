import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../notifier/inconsistency_notifier.dart';

part 'table_view.dart';
part 'solve_inconsistency_view.dart';

class InconsistencyScreen extends StatelessWidget {
  const InconsistencyScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InconsistencyNotifier(
        getInconsistenciesUseCase: context.read(),
        getStationsUseCase: context.read(),
        solveUseCase: context.read(),
      )..getStations(),
      child: Consumer<InconsistencyNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              child: TableView(notifier: notifier),

              // child: MedTable<Inconsistency>(
              //   data: notifier.items,
              //   enableExcel: true,
              //   enableSearch: true,
              //   onSearchChanged: notifier.search,
              //   actions: [
              //     TableActionItem(
              //       icon: PhosphorIcons.qrCode(),
              //       tooltip: context.l10n.inconsistency_viewTooltip,
              //       onPressed: (data) {},
              //     ),
              //     TableActionItem(
              //       icon: PhosphorIcons.camera(),
              //       tooltip: context.l10n.inconsistency_photoTooltip,
              //       onPressed: (_) {},
              //     ),
              //   ],
              //   columnDefs: [],
              // ),
            ),
          );
        },
      ),
    );
  }
}
