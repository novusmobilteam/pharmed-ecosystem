import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/hospitalization_form_notifier.dart';
import '../notifier/patient_form_notifier.dart';

import '../notifier/hospitalization_notifier.dart';

part 'hospitalization_form_panel.dart';
part 'patient_form_panel.dart';

/// Yatan hasta listesi ekranı.
///
/// Bu ekran:
/// - Yatan hastaların listesini tablo olarak gösterir
/// - Hasta ve yatış ekleme/düzenleme işlemlerini destekler
/// - Arama ve tarih filtreleme özelliklerine sahiptir
class HospitalizationScreen extends StatelessWidget {
  const HospitalizationScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          HospitalizationNotifier(hospitalizationRepository: context.read())..getHospitalizations(),
      child: Consumer<HospitalizationNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'Hasta İşlemleri',
              subtitle: menu.description,
              actions: _buildActions(context, notifier),
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 480,
                panel: switch (notifier.panelMode) {
                  HospitalizationPanelMode.newPatient || HospitalizationPanelMode.editPatient => PatientFormPanel(),
                  HospitalizationPanelMode.newHospitalization ||
                  HospitalizationPanelMode.newHospitalizationWithPatient ||
                  HospitalizationPanelMode.editHospitalization => HospitalizationPanel(),
                  HospitalizationPanelMode.none => const SizedBox.shrink(),
                },
                child: UnifiedTableView<Hospitalization>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isFetching,
                  enableExcel: true,
                  enableSearch: true,
                  enablePDF: true,
                  enableDateFilter: true,
                  // selectionMode: TableSelectionMode.single,
                  onSearchChanged: notifier.search,
                  initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                  onDateRangeChanged: (range) {
                    notifier.setStartDate(range?.start);
                    notifier.setEndDate(range?.end);
                  },
                  // onSingleSelectionChanged: (data) {
                  //   notifier.selectHospitalization(data);
                  // },
                  actions: [
                    TableActionItem(
                      icon: PhosphorIcons.pen(),
                      tooltip: 'Yatış Düzenle',
                      onPressed: (hospitalization) {
                        notifier.selectHospitalization(hospitalization);
                        notifier.openPanel(HospitalizationPanelMode.editHospitalization);
                      },
                    ),
                    TableActionItem(
                      icon: PhosphorIcons.user(),
                      tooltip: 'Hasta Bilgileri Düzenle',
                      onPressed: (hospitalization) {
                        notifier.selectHospitalization(hospitalization);
                        notifier.openPanel(HospitalizationPanelMode.editPatient);
                      },
                    ),
                    TableActionItem(
                      icon: PhosphorIcons.plus(),
                      tooltip: 'Yeni Yatış Gir',
                      onPressed: (hospitalization) {
                        notifier.selectHospitalization(hospitalization);
                        notifier.openPanel(HospitalizationPanelMode.newHospitalizationWithPatient);
                      },
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

  List<Widget> _buildActions(BuildContext context, HospitalizationNotifier notifier) {
    return [
      // Yeni Hasta
      IconButton(
        onPressed: () => notifier.openPanel(HospitalizationPanelMode.newPatient),
        tooltip: 'Yeni Hasta Oluştur',
        icon: Icon(PhosphorIcons.userPlus()),
      ),
      // Yeni Yatış
      IconButton(
        onPressed: () => notifier.openPanel(HospitalizationPanelMode.newHospitalization),
        tooltip: 'Yeni Yatış Oluştur',
        icon: Icon(PhosphorIcons.bed()),
      ),
    ];
  }
}
