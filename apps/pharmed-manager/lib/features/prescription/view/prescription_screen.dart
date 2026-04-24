import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import '../../../core/widgets/dose_stepper.dart';
import '../../../core/widgets/info_chip.dart';
import '../../../core/widgets/rx_group_card.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/prescription_detail_notifier.dart';
import '../notifier/prescription_form_notifier.dart';
import '../notifier/prescription_notifier.dart';
import '../widgets/prescription_item_card.dart';

part 'prescription_form_panel.dart';
part 'prescription_detail_panel.dart';

// lib/features/prescription/presentation/view/prescription_screen.dart
//
// [SWREQ-MGR-RX-003] [IEC 62304 §5.5]
// Reçete listesi ekranı.
// Panel tipi PrescriptionPanelType'a göre form veya detay panelini açar.
// Sınıf: Class B

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              PrescriptionNotifier(getHospitalizationsWithPrescriptionUseCase: context.read())..getHospitalizations(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PrescriptionDetailNotifier(submitUseCase: context.read(), historyUseCase: context.read()),
        ),
      ],
      child: Consumer<PrescriptionNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Reçete İşlemleri',
              subtitle: menu.description,
              actions: [MedButton(label: 'Yeni Reçete', size: MedButtonSize.sm, onPressed: notifier.openFormPanel)],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: _buildPanel(notifier),
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
                      onPressed: notifier.openDetailPanel,
                    ),
                    TableActionItem<Hospitalization>(
                      icon: PhosphorIcons.plus(),
                      tooltip: 'Yeni Reçete',
                      onPressed: (hosp) => notifier.openFormPanel(hosp: hosp),
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

  /// Panel tipine göre doğru widget'ı döndürür.
  /// ValueKey ile hospitalization değiştiğinde PrescriptionDetailPanel
  /// rebuild olur ve load() tekrar tetiklenir.
  Widget _buildPanel(PrescriptionNotifier notifier) {
    if (notifier.panelType == PrescriptionPanelType.detail) {
      return PrescriptionDetailPanel(key: ValueKey(notifier.selectedHospitalization?.id ?? 'detail'));
    }
    return PrescriptionFormPanel(key: ValueKey(notifier.selectedHospitalization?.id ?? 'form'));
  }
}
