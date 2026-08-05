// [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının seçim paneli.
//
// RootScaffold artık booting (masterIntake + patientSelection senkron hazır
// olma) mekaniğini merkezi olarak yönetiyor — bu panel yalnızca her iki
// provider da hazırken build edilir, kendi _hasBooted/Offstage mantığına
// ihtiyaç duymaz.
//
// SOL: PatientSelectionPanel — hasta listesi + filtreler + acil hasta barı.
// SAĞ: seçili hastaya ait ilaç listesi (dolum/sayım'daki CabinSelection
//      panelleriyle aynı CabinSelectionContentShell iskeleti kullanılıyor).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../intake.dart';
import '../notifier/redirected_intake_orders_notifier.dart';
import '../notifier/redirected_intake_orders_state.dart';
part 'redirected_orders_content.dart';
part 'rx_orders_content.dart';

final masterIntakeActiveTabProvider = StateProvider<bool>((ref) => false);

class MasterIntakeSelectionView extends ConsumerStatefulWidget {
  const MasterIntakeSelectionView({super.key});

  @override
  ConsumerState<MasterIntakeSelectionView> createState() => _MasterIntakeSelectionViewState();
}

class _MasterIntakeSelectionViewState extends ConsumerState<MasterIntakeSelectionView> {
  @override
  Widget build(BuildContext context) {
    final showRedirected = ref.watch(masterIntakeActiveTabProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);
    final redirectedNotifier = ref.read(redirectedIntakeOrdersNotifierProvider.notifier);
    ref.watch(redirectedIntakeOrdersNotifierProvider);

    final Hospitalization? selectedPatient = showRedirected
        ? redirectedNotifier.selectedHospitalization
        : ref.watch(masterIntakeNotifierProvider).hospitalization;

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedSegmentedButton(
            selectedIndex: showRedirected ? 1 : 0,
            onChanged: (index) => ref.read(masterIntakeActiveTabProvider.notifier).state = index == 1,
            labels: [context.l10n.intake_tab_prescriptions, context.l10n.intake_tab_redirectedOrders],
          ),
          SizedBox(height: 12.0),
          Expanded(
            child: PatientSelectionPanel(
              // Sekme değişince filtre görünürlüğü değiştiği için panel
              // yeniden kurulmalı — showFilters, initState'te bir kez
              // notifier.init()'e geçiyor (bkz. PatientSelectionPanel),
              // sonradan değişmiyor.
              key: ValueKey(showRedirected),
              selectedPatient: selectedPatient,
              showFilters: !showRedirected,
              onPatientSelected: (hospitalization, isOrderless) {
                if (showRedirected) {
                  redirectedNotifier.selectPatient(hospitalization);
                } else {
                  notifier.selectPatient(hospitalization, isOrderless ? IntakeType.orderless : IntakeType.ordered);
                }
              },
            ),
          ),
        ],
      ),
      right: showRedirected ? const RedirectedOrdersContent() : const RxOrdersContent(),
    );
  }
}
