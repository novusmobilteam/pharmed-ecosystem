import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../prescription.dart';
part 'table_view.dart';

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
              menu: menu,
              actions: [
                MedButton(
                  label: context.l10n.prescription_newTitle,
                  size: MedButtonSize.sm,
                  onPressed: () => showPrescriptionFormDialog(context),
                ),
              ],
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: PrescriptionDetailPanel(key: ValueKey(notifier.selectedHospitalization?.id ?? 'detail')),
                child: TableView(notifier: notifier),
              ),
            ),
          );
        },
      ),
    );
  }
}
