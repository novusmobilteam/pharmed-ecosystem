import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../../prescription/domain/entity/prescription_item.dart';
import '../view_model/job_list_viewmodel.dart';

/// Günlük iş listesi ekranı.
class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => JobListViewModel(
        prescriptionRepository: context.read(),
      )..fetchDailyJobList(),
      child: Consumer<JobListViewModel>(
        builder: (context, vm, _) => ResponsiveLayout(
          mobile: const MobileLayout(),
          tablet: const TabletLayout(),
          desktop: _buildDesktopLayout(context, vm),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, JobListViewModel vm) {
    return DesktopLayout(
      title: 'Günlük İş Listesi',
      showAddButton: false,
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, JobListViewModel vm) {
    if (vm.isFetching && vm.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (vm.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return _TableView(vm: vm);
  }
}

/// Günlük iş listesi tablosu.
class _TableView extends StatelessWidget {
  const _TableView({required this.vm});

  final JobListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<PrescriptionItem>(
      data: vm.filteredItems,
      isLoading: vm.isFetching,
      horizontalScroll: true,
      enableSearch: true,
      enableExcel: true,
      onSearchChanged: vm.search,
    );
  }
}
