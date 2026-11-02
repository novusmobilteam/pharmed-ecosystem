import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../../../widgets/widgets.dart';
import '../notifier/overdue_applications_notifier.dart';
import '../notifier/unapplied_prescriptions_notifier.dart';

part 'table_view.dart';
part 'overdue_table_view.dart';
part 'detail_panel.dart';

class UnappliedPrescriptionsScreen extends StatelessWidget {
  const UnappliedPrescriptionsScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UnappliedPrescriptionsNotifier(
            getUnappliedPrescriptionsUseCase: context.read(),
            getUnappliedPrescriptionDetailUseCase: context.read(),
          )..fetch(),
        ),
        // Geciken uygulamalar tablosu açıldığında (OverdueTableView) yüklenir.
        ChangeNotifierProvider(
          create: (context) => OverdueApplicationsNotifier(getOverduePrescriptionsUseCase: context.read()),
        ),
      ],
      builder: (context, child) {
        return Consumer<UnappliedPrescriptionsNotifier>(
          builder: (context, notifier, child) {
            return MedResponsiveLayout(
              mobile: const MedMobileLayout(),
              tablet: const MedTabletLayout(),
              desktop: MedDesktopLayout(
                menu: menu,
                showAddButton: false,
                child: SidePanelWrapper(
                  isOpen: notifier.isPanelOpen,
                  width: 700,
                  panel: DetailPanel(key: ValueKey(notifier.selectedPrescription?.id ?? 'detail')),
                  child: notifier.showOverdue
                      ? OverdueTableView(
                          notifier: context.read<OverdueApplicationsNotifier>(),
                          onToggle: notifier.toggleOverdue,
                        )
                      : TableView(notifier: notifier),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
