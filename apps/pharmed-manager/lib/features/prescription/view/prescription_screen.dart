import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../prescription.dart';

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
              actions: [
                MedButton(
                  label: 'Yeni Reçete',
                  size: MedButtonSize.sm,
                  onPressed: () => showPrescriptionFormDialog(context),
                ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: PrescriptionDetailPanel(key: ValueKey(notifier.selectedHospitalization?.id ?? 'detail')),
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
                      onPressed: notifier.openPanel,
                    ),
                    TableActionItem<Hospitalization>(
                      icon: PhosphorIcons.plus(),
                      tooltip: 'Yeni Reçete',
                      onPressed: (hosp) => showPrescriptionFormDialog(context, hospitalization: hosp),
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
}
