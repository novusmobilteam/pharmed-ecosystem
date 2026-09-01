import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/inconsistency_notifier.dart';

// part 'inconsistency_detail_view.dart';
// part 'inconsistency_summary_view.dart';
part 'table_view.dart';
part 'stock_movements_table_view.dart';

class InconsistencyScreen extends StatelessWidget {
  const InconsistencyScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          InconsistencyNotifier(getInconsistenciesUseCase: context.read(), getStationsUseCase: context.read())
            ..getStations(),
      child: Consumer<InconsistencyNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              isLoading: notifier.isLoading(notifier.fetchOp) || notifier.isLoading(notifier.fetchStationsOp),
              showAddButton: false,
              child: Column(
                spacing: 6.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 260,
                    child: MedDropdownInputField(
                      key: ValueKey(notifier.selectedStation),
                      options: notifier.stations,
                      onChanged: notifier.selectStation,
                      initialValue: notifier.selectedStation,
                      labelBuilder: (station) => station?.name,
                      placeholder: context.l10n.assignment_stationSelectPlaceholder,
                    ),
                  ),
                  Expanded(
                    child: MedTable<Inconsistency>(
                      data: notifier.items,
                      enableExcel: true,
                      enableSearch: true,
                      onSearchChanged: notifier.search,
                      actions: [
                        TableActionItem(
                          icon: PhosphorIcons.qrCode(),
                          tooltip: context.l10n.inconsistency_viewTooltip,
                          onPressed: (data) {},
                        ),
                        TableActionItem(
                          icon: PhosphorIcons.camera(),
                          tooltip: context.l10n.inconsistency_photoTooltip,
                          onPressed: (_) {},
                        ),
                      ],
                      columnDefs: [],
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
