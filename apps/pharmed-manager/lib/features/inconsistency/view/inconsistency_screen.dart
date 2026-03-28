import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../domain/entity/inconsistency.dart';
import '../view_model/inconsistency_list_view_model.dart';

// part 'inconsistency_detail_view.dart';
// part 'inconsistency_summary_view.dart';
part 'stock_movements_table_view.dart';

class InconsistencyScreen extends StatelessWidget {
  const InconsistencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InconsistencyListViewModel(
        inconsistencyRepository: context.read(),
      )..fetchInconsistencies(),
      child: Consumer<InconsistencyListViewModel>(
        builder: (context, vm, _) {
          return ResponsiveLayout(
            mobile: SizedBox(),
            tablet: SizedBox(),
            desktop: _buildDesktopLayout(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, InconsistencyListViewModel vm) {
    return DesktopLayout(
      title: 'Tutarsızlık Hareketleri',
      showAddButton: false,
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, InconsistencyListViewModel vm) {
    if (vm.isFetching && vm.filteredItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (vm.filteredItems.isEmpty) {
      return Center(
        child: CommonEmptyStates.noData(),
      );
    }

    return UnifiedTableView<Inconsistency>(
      data: vm.filteredItems,
      enableExcel: true,
      enableSearch: true,
      onSearchChanged: vm.search,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.qrCode(),
          tooltip: 'Görüntüle',
          onPressed: (data) {},
        ),
        TableActionItem(
          icon: PhosphorIcons.camera(),
          tooltip: 'Fotoğraf',
          onPressed: (_) {},
        ),
      ],
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
