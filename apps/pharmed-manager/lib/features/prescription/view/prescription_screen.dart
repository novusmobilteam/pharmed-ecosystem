import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/auth/notifier/auth_notifier.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../notifier/prescription_detail_notifier.dart';
import '../notifier/prescription_form_notifier.dart';
import '../notifier/prescription_notifier.dart';

part 'prescription_form_panel.dart';
part 'prescription_detail_panel.dart';

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
          create: (context) => PrescriptionNotifier(
            getActiveHospitalizationsUseCase: context.read(),
            getHospitalizationsUseCase: context.read(),
          )..fetch(),
        ),
        ChangeNotifierProvider(
          create: (context) => PrescriptionDetailNotifier(
            submitUseCase: context.read(),
            historyUseCase: context.read(),
            assignRfidTagUseCase: context.read(),
            deleteRfidTagUseCase: context.read(),
            checkAndApproveUseCase: context.read(),
          ),
        ),
      ],
      child: Consumer<PrescriptionNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              title: menu.name ?? 'Reçete İşlemleri',
              subtitle: menu.description,
              actions: [MedButton(label: 'Yeni Reçete', size: MedButtonSize.sm, onPressed: notifier.openFormPanel)],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: _buildPanel(notifier),
                child: MedTable<Hospitalization>(
                  data: notifier.items,
                  enableExcel: true,
                  enableSearch: true,
                  enablePDF: true,

                  isLoading: notifier.isFetching,
                  onSearchChanged: notifier.search,
                  enableDateFilter: true,

                  initialDateRange: notifier.dateRange,
                  onDateRangeChanged: notifier.setDateRange,
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
