import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../../prescription/domain/entity/prescription.dart';
import '../../prescription/domain/entity/prescription_item.dart';
import '../view_model/unapplied_prescription_detail_view_model.dart';
import '../view_model/unapplied_prescriptions_list_view_model.dart';

part 'prescription_detail_view.dart';

class UnappliedPrescriptionsScreen extends StatefulWidget {
  const UnappliedPrescriptionsScreen({super.key});

  @override
  State<UnappliedPrescriptionsScreen> createState() => _UnappliedPrescriptionsScreenState();
}

class _UnappliedPrescriptionsScreenState extends State<UnappliedPrescriptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnappliedPrescriptionListViewModel(
        prescriptionRepository: context.read(),
      )..fetchUnappliedPrescriptions(),
      builder: (context, child) {
        return Consumer<UnappliedPrescriptionListViewModel>(
          builder: (context, vm, child) {
            return ResponsiveLayout(
              mobile: const MobileLayout(),
              tablet: const TabletLayout(),
              desktop: _buildDesktopLayout(context, vm),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UnappliedPrescriptionListViewModel vm) {
    return DesktopLayout(
      title: 'Uygulanmamış Reçeteler',
      showAddButton: false,
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, UnappliedPrescriptionListViewModel vm) {
    if (vm.isFetching && vm.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (vm.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return _TableView(vm: vm);
  }
}

class _TableView extends StatelessWidget {
  const _TableView({required this.vm});

  final UnappliedPrescriptionListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Prescription>(
      data: vm.filteredItems,
      enableExcel: true,
      enableDateFilter: true,
      enableSearch: true,
      onSearchChanged: vm.search,
      onDateRangeChanged: (value) {
        vm.setStartDate(value?.start);
        vm.setEndDate(value?.end);
      },

      // Tablo Satır Aksiyonları
      actions: [
        TableActionItem(
          icon: PhosphorIcons.qrCode(),
          tooltip: 'Detayları Görüntüle',
          color: context.colorScheme.onSurface,
          onPressed: (item) => showPrescriptionDetailView(
            context,
            prescription: item,
          ),
        ),
      ],
    );
  }
}
