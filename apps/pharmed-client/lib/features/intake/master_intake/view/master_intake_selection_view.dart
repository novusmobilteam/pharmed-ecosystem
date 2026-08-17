// // [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// // İlaç-merkezli master kabin İLAÇ ALIM ekranının seçim paneli.
// //
// // RootScaffold artık booting (masterIntake + patientSelection senkron hazır
// // olma) mekaniğini merkezi olarak yönetiyor — bu panel yalnızca her iki
// // provider da hazırken build edilir, kendi _hasBooted/Offstage mantığına
// // ihtiyaç duymaz.
// //
// // SOL: PatientSelectionPanel — hasta listesi + filtreler + acil hasta barı.
// // SAĞ: seçili hastaya ait ilaç listesi (dolum/sayım'daki CabinSelection
// //      panelleriyle aynı CabinSelectionContentShell iskeleti kullanılıyor).
// //
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_client/features/intake/master_intake/patient_selection/view/patient_selection_panel_2.dart';
// import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:pharmed_utils/pharmed_utils.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// import '../../../../widgets/widgets.dart';
// import '../../intake.dart';
// import '../notifier/redirected_intake_orders_notifier.dart';
// import '../notifier/redirected_intake_orders_state.dart';
// import '../patient_selection/notifier/patient_selection_notifier.dart';
// import '../patient_selection/notifier/patient_selection_state.dart';
// import '../patient_selection/view/patient_selection_panel.dart';
// part 'redirected_orders_content.dart';
// part 'rx_orders_content.dart';

// // [SWREQ-CLI-MINTAKE-004] güncellendi — masterIntakeActiveTabProvider kaldırıldı,
// // tab artık IntakePatientSelectionPanel içinde yaşıyor.

// class MasterIntakeSelectionView extends ConsumerWidget {
//   const MasterIntakeSelectionView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifier = ref.read(masterIntakeNotifierProvider.notifier);
//     final redirectedNotifier = ref.read(redirectedIntakeOrdersNotifierProvider.notifier);

//     ref.listen(intakePatientSelectionNotifierProvider, (previous, next) {
//       final prev = (previous is IntakePatientSelectionReady) ? previous : null;
//       final nxt = (next is IntakePatientSelectionReady) ? next : null;
//       if (prev == null || nxt == null) return;

//       final tabChanged = prev.tab != nxt.tab;
//       final orderStatusChanged = prev.viewOrderStatus != nxt.viewOrderStatus;

//       if (tabChanged || orderStatusChanged) {
//         notifier.resetToPatientSelection();
//         redirectedNotifier.resetToPatientSelection();
//       }
//     });

//     final patientState = ref.watch(intakePatientSelectionNotifierProvider);
//     final currentTab = switch (patientState) {
//       IntakePatientSelectionReady r => r.tab,
//       IntakePatientSelectionError(previousState: final r) => r.tab,
//       _ => IntakePatientTab.prescriptions,
//     };
//     final showRedirected = currentTab == IntakePatientTab.redirected;

//     final redirectedState = ref.watch(redirectedIntakeOrdersNotifierProvider);
//     final Hospitalization? redirectedSelected = switch (redirectedState) {
//       RedirectedOrdersLoading(:final hospitalization) => hospitalization,
//       RedirectedOrdersLoaded(:final hospitalization) => hospitalization,
//       RedirectedOrdersError(:final hospitalization) => hospitalization,
//       _ => null,
//     };

//     final Hospitalization? selectedPatient = showRedirected
//         ? redirectedSelected
//         : ref.watch(masterIntakeNotifierProvider).hospitalization;

//     return Row(
//       children: [
//         Expanded(flex: 3, child: PatientSelectionPanel2()),
//         VerticalDivider(color: MedColors.text3, width: 1, thickness: 1),
//         Expanded(flex: 7, child: SizedBox()),
//       ],
//     );

//     // return CabinOperationSelectionLayout(
//     //   leftWidth: 440,
//     //   //left: PatientSelectionPanel2(),
//     //   left: IntakePatientSelectionPanel(
//     //     selectedPatient: selectedPatient,
//     //     onPatientSelected: (hospitalization, tab, isOrderless) {
//     //       if (tab == IntakePatientTab.redirected) {
//     //         redirectedNotifier.selectPatient(hospitalization);
//     //       } else {
//     //         notifier.selectPatient(hospitalization, isOrderless ? IntakeType.orderless : IntakeType.ordered);
//     //       }
//     //     },
//     //   ),
//     //   right: showRedirected ? const RedirectedOrdersContent() : const RxOrdersContent(),
//     // );
//   }
// }
