import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../../intake.dart';
import '../notifier/redirected_intake_orders_notifier.dart';
import '../notifier/redirected_intake_orders_state.dart';
part 'redirected_orders_content.dart';
part 'rx_orders_content.dart';

class MasterIntakeSelectionView extends ConsumerWidget {
  const MasterIntakeSelectionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

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
        config: PatientSelectionConfig.intake,
        currentStation: stationContext.station!,
        selectedPatient: selectedPatient,
        onPatientSelected: (hospitalization, tab, mode) {
          if (tab == PatientSelectionTab.redirected) {
            redirectedNotifier.selectPatient(hospitalization);
            return;
          }
          final intakeType = switch (mode) {
            PatientIntakeMode.ordered => IntakeType.ordered,
            PatientIntakeMode.orderless => IntakeType.orderless,
            PatientIntakeMode.free => IntakeType.free,
          };
          notifier.selectPatient(hospitalization, intakeType);
        },
        onUrgentPatientCreated: (hospitalization, scope) {
          final intakeType = scope == UrgentPatientMedicineScope.allMedicines ? IntakeType.urgent : IntakeType.free;
          notifier.selectPatient(hospitalization, intakeType);
        },
      ),
      right: showRedirected
          ? RedirectedOrdersContent(menu: stationContext.menu)
          : RxOrdersContent(menu: stationContext.menu),
    );
  }
}
