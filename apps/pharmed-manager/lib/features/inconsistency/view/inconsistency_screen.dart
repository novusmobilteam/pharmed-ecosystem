import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/inconsistency_notifier.dart';

// part 'inconsistency_detail_view.dart';
// part 'inconsistency_summary_view.dart';
part 'stock_movements_table_view.dart';

class InconsistencyScreen extends StatelessWidget {
  const InconsistencyScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InconsistencyNotifier(getInconsistenciesUseCase: context.read())..fetch(),
      child: Consumer<InconsistencyNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              showAddButton: false,
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
          );
        },
      ),
    );
  }
}

// void _onShow(BuildContext context, Inconsistency data) {
//   showDialog(
//     context: context,
//     builder: (context) => ChangeNotifierProvider(
//       create: (context) => InconsistencyDetailViewModel(
//         repository: context.read(),
//       )..getInconsistencyDetail(data.id ?? 0),
//       child: const InconsistencyDetailView(),
//     ),
//   );
// }
