import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/new_prescription_notifier.dart';
import 'new_prescription_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../notifier/prescription_detail_notifier.dart';
import '../notifier/prescription_table_notifier.dart';
import 'prescription_list_view.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PrescriptionTableNotifier(
        getHospitalizationsWithPrescriptionUseCase: context.read(),
      )..getHospitalizations(),
      child: Consumer<PrescriptionTableNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Reçete İşlemleri',
              showAddButton: true,
              onAddPressed: () => _openFormDialog(context),
              child: _buildChild(context, notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild(BuildContext context, PrescriptionTableNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return CommonEmptyStates.noData();
    }

    return Column(
      children: [
        Expanded(
          child: UnifiedTableView<Hospitalization>(
            data: notifier.dateFilteredItems,
            enableExcel: true,
            enableSearch: true,
            isLoading: notifier.isFetching,
            onSearchChanged: notifier.search,
            enableDateFilter: true,
            initialDateRange: DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now(),
            ),
            onDateRangeChanged: (value) {
              notifier.setDateRange(value?.start, value?.end);
            },
            actions: [
              TableActionItem<Hospitalization>(
                icon: PhosphorIcons.receipt(),
                tooltip: 'Reçete İçeriği',
                color: context.colorScheme.onSurface,
                onPressed: (data) {
                  _showPatientPrescriptions(context, data);
                },
              ),
              TableActionItem(
                icon: PhosphorIcons.plus(),
                tooltip: 'Yeni Reçete',
                onPressed: (data) => _openFormDialog(
                  context,
                  hospitalization: data,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showPatientPrescriptions(BuildContext context, Hospitalization hospitalization) {
  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => PrescriptionDetailNotifier(
        hospitalization: hospitalization,
        submitUseCase: context.read(),
        historyUseCase: context.read(),
      )..getPatientPrescriptionHistory(),
      child: const PrescriptionListView(),
    ),
  );
}

Future<void> _openFormDialog(BuildContext context, {Hospitalization? hospitalization}) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider(
      create: (context) => NewPrescriptionNotifier(
        hospitalization: hospitalization,
        useCase: context.read(),
      ),
      child: NewPrescriptionView(),
    ),
  );

  if (changed == true && context.mounted) {
    context.read<PrescriptionTableNotifier>().getHospitalizations();
  }
}
