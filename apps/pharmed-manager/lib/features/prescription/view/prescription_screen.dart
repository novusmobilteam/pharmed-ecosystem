import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import '../../../core/widgets/dose_stepper.dart';
import '../../../core/widgets/info_chip.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/prescription_detail_notifier.dart';
import '../notifier/prescription_form_notifier.dart';
import '../notifier/prescription_notifier.dart';
import '../widgets/prescription_item_card.dart';
import 'prescription_list_view.dart';

part 'prescription_form_panel.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PrescriptionNotifier(getHospitalizationsWithPrescriptionUseCase: context.read())..getHospitalizations(),
      child: Consumer<PrescriptionNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Reçete İşlemleri',
              subtitle: menu.description,
              onAddPressed: () => notifier.openPanel(),
              actions: [MedButton(label: 'Yeni Reçete', size: MedButtonSize.sm, onPressed: notifier.openPanel)],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: PrescriptionFormPanel(),
                child: UnifiedTableView<Hospitalization>(
                  data: notifier.dateFilteredItems,
                  enableExcel: true,
                  enableSearch: true,
                  isLoading: notifier.isFetching,
                  onSearchChanged: notifier.search,
                  enableDateFilter: true,
                  initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
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
                      onPressed: (data) => notifier.openPanel(hosp: data),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
