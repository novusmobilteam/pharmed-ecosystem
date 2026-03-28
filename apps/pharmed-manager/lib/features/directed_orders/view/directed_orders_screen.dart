import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../../hospitalization/domain/entity/hospitalization.dart';
import '../view_model/directed_orders_detail_viewmodel.dart';
import '../view_model/directed_orders_viewmodel.dart';

part 'medicine_table_view.dart';
part 'table_view.dart';

/// Yönlendirilmiş order listesi ekranı.
class DirectedOrdersScreen extends StatelessWidget {
  const DirectedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          DirectedOrdersViewModel(hospitalizationRepository: context.read())..fetchHospitalizations(),
      child: Consumer<DirectedOrdersViewModel>(
        builder: (context, vm, _) => ResponsiveLayout(
          mobile: const MobileLayout(),
          tablet: const TabletLayout(),
          desktop: _buildDesktopLayout(context, vm),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DirectedOrdersViewModel vm) {
    return DesktopLayout(
      title: 'Yönlendirilmiş Order Listesi',
      showAddButton: false,
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, DirectedOrdersViewModel vm) {
    if (vm.isFetching && vm.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (vm.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return _TableView(vm: vm);
  }
}
