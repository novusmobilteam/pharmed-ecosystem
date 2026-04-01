import 'package:flutter/material.dart';
import '../../../core/core.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../view_model/medicine_activity_viewmodel.dart';

part 'table_view.dart';

/// İlaç aktivite ekranı.
class MedicineActivityScreen extends StatelessWidget {
  const MedicineActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineActivityViewModel(prescriptionRepository: context.read())..fetchActivities(),
      child: Consumer<MedicineActivityViewModel>(
        builder: (context, vm, child) => ResponsiveLayout(
          mobile: const MobileLayout(),
          tablet: const TabletLayout(),
          desktop: _buildDesktopLayout(context, vm),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MedicineActivityViewModel vm) {
    return DesktopLayout(title: 'İlaç Aktivite', showAddButton: false, child: _buildContent(context, vm));
  }

  Widget _buildContent(BuildContext context, MedicineActivityViewModel vm) {
    if (vm.isFetching && vm.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (vm.isEmpty) {
      return CommonEmptyStates.noPatient();
    }

    return _TableView(vm: vm);
  }
}
