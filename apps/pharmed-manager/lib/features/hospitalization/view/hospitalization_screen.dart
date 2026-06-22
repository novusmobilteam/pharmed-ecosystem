import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_manager/core/core.dart';
import '../../../../widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

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
      create: (BuildContext context) => HospitalizationNotifier(
        getActiveHospitalizationsUseCase: context.read(),
        getHospitalizationsUseCase: context.read(),
      )..fetch(),
      child: Consumer<HospitalizationNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
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
                child: MedTable<Hospitalization>(
                  data: notifier.items,
                  isLoading: notifier.isFetching,
                  enableExcel: true,
                  enableSearch: true,
                  enablePDF: true,
                  enableDateFilter: true,
                  onSearchChanged: notifier.search,
                  initialDateRange: notifier.dateRange,
                  onDateRangeChanged: notifier.setDateRange,
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
                  toolbarActions: [
                    MedRectangleIconButton(
                      tooltip: notifier.showDischarged ? 'Aktif yatışları getir' : 'Taburcu olanları göster',
                      iconData: notifier.showDischarged ? PhosphorIcons.userMinus() : PhosphorIcons.userCheck(),
                      color: MedColors.amberLight,
                      iconColor: MedColors.amber,
                      onPressed: notifier.toggleDischarged,
                    ),
                  ],

                  enablePagination: true,
                  pageSize: notifier.pageSize,
                  currentPage: notifier.currentPage,
                  onPageChanged: (page) => notifier.setPage(page),
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
      MedButton(
        onPressed: () => notifier.openPanel(HospitalizationPanelMode.newPatient),
        size: MedButtonSize.sm,
        label: 'Yeni Hasta Oluştur',
      ),
      // Yeni Yatış
      MedButton(
        onPressed: () => notifier.openPanel(HospitalizationPanelMode.newHospitalization),
        size: MedButtonSize.sm,
        label: 'Yeni Yatış Oluştur',
      ),
    ];
  }
}
