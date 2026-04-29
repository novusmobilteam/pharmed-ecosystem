import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
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
      create: (context) => InconsistencyNotifier(getInconsistenciesUseCase: context.read())..getInconsistencies(),
      child: Consumer<InconsistencyNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: MobileLayout(),
            tablet: TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Tutarsızlık Hareketleri',
              subtitle: menu.description,
              showAddButton: false,
              child: UnifiedTableView<Inconsistency>(
                data: notifier.filteredItems,
                enableExcel: true,
                enableSearch: true,
                onSearchChanged: notifier.search,
                actions: [
                  TableActionItem(icon: PhosphorIcons.qrCode(), tooltip: 'Görüntüle', onPressed: (data) {}),
                  TableActionItem(icon: PhosphorIcons.camera(), tooltip: 'Fotoğraf', onPressed: (_) {}),
                ],
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
