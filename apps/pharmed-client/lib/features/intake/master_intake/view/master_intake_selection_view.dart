// [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının seçim paneli.
//
// RootScaffold artık booting (masterIntake + patientSelection senkron hazır
// olma) mekaniğini merkezi olarak yönetiyor — bu panel yalnızca her iki
// provider da hazırken build edilir, kendi _hasBooted/Offstage mantığına
// ihtiyaç duymaz.
//
// SOL: ORTAK PatientSelectionPanel (bkz. cabin_shell_widgets/patient_selection)
//      — PatientSelectionConfigs.intake ile sekmeler + acil hasta akışı açık.
// SAĞ: seçili hastaya ait ilaç listesi.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/cabin_shell_widgets/selection/patient_selection/notifier/patient_selection_config.dart';
import '../../../../widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';
import '../notifier/redirected_intake_orders_notifier.dart';
import '../notifier/redirected_intake_orders_state.dart';
part 'redirected_orders_content.dart';
part 'rx_orders_content.dart';

class MasterIntakeSelectionView extends ConsumerWidget {
  const MasterIntakeSelectionView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);
    final redirectedNotifier = ref.read(redirectedIntakeOrdersNotifierProvider.notifier);

    ref.listen(patientSelectionNotifierProvider, (previous, next) {
      final prev = (previous is PatientSelectionReady) ? previous : null;
      final nxt = (next is PatientSelectionReady) ? next : null;
      if (prev == null || nxt == null) return;

      final tabChanged = prev.tab != nxt.tab;
      final orderStatusChanged = prev.viewOrderStatus != nxt.viewOrderStatus;

      if (tabChanged || orderStatusChanged) {
        notifier.resetToPatientSelection();
        redirectedNotifier.resetToPatientSelection();
      }
    });

    final patientState = ref.watch(patientSelectionNotifierProvider);
    final currentTab = switch (patientState) {
      PatientSelectionReady r => r.tab,
      // ignore: unnecessary_type_check
      PatientSelectionError(previousState: final p) when p is PatientSelectionReady => p.tab,
      _ => PatientSelectionTab.prescriptions,
    };
    final showRedirected = currentTab == PatientSelectionTab.redirected;

    final redirectedState = ref.watch(redirectedIntakeOrdersNotifierProvider);
    final Hospitalization? redirectedSelected = switch (redirectedState) {
      RedirectedOrdersLoading(:final hospitalization) => hospitalization,
      RedirectedOrdersLoaded(:final hospitalization) => hospitalization,
      RedirectedOrdersError(:final hospitalization) => hospitalization,
      _ => null,
    };

    final Hospitalization? selectedPatient = showRedirected
        ? redirectedSelected
        : ref.watch(masterIntakeNotifierProvider).hospitalization;

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      flex: 2,
      left: PatientSelectionPanel(
        config: PatientSelectionConfigs.intake,
        selectedPatient: selectedPatient,
        onPatientSelected: (hospitalization, tab, isOrderless) {
          if (tab == PatientSelectionTab.redirected) {
            redirectedNotifier.selectPatient(hospitalization);
          } else {
            notifier.selectPatient(hospitalization, isOrderless ? IntakeType.orderless : IntakeType.ordered);
          }
        },
      ),
      right: showRedirected ? RedirectedOrdersContent(menu: menu) : RxOrdersContent(menu: menu),
    );
  }
}
