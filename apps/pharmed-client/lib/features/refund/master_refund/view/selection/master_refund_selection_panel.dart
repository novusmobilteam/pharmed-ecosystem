// // Master kabin İLAÇ İADE ekranının seçim paneli.
// //
// // SOL: PatientSelectionPanel — hasta listesi (filtre alanları kullanılmıyor).
// // SAĞ: seçili hastanın iade edilebilir ilaçları (MedicineIntakeItem).
// // Şahit akışı yoktur.
// //
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// import '../../../../../widgets/widgets.dart';
// import '../../notifier/master_refund_notifier.dart';
// import '../../notifier/master_refund_state.dart';

// class MasterRefundSelectionPanel extends ConsumerWidget {
//   const MasterRefundSelectionPanel({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifier = ref.read(masterRefundNotifierProvider.notifier);

//     return CabinSelectionPanelLayout(
//       leftWidth: 440,
//       left: PatientSelectionPanel(
//         selectedPatient: ref.watch(masterRefundNotifierProvider).hospitalization,
//         onPatientSelected: (hospitalization, _) => notifier.selectPatient(hospitalization),
//       ),
//       right: _buildMedicineContent(context, ref),
//     );
//   }

//   Widget _buildMedicineContent(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(masterRefundNotifierProvider);
//     final notifier = ref.read(masterRefundNotifierProvider.notifier);

//     final selection = switch (state) {
//       MasterRefundMedicineSelection s => s,
//       MasterRefundError(previousState: MasterRefundMedicineSelection s) => s,
//       _ => null,
//     };

//     final bool noPatientSelected = selection == null && state is MasterRefundPatientSelection;
//     final bool isItemsLoading = selection == null && !noPatientSelected;

//     final items = selection?.visibleItems ?? const [];
//     final selectedItemIds = selection?.selectedItemIds ?? const {};
//     final checkStatuses = selection?.checkStatuses ?? const {};

//     return CabinSelectionContentShell(
//       searchQuery: selection?.search ?? '',
//       onSearchQueryChanged: notifier.onSearchChanged,
//       searchHint: context.l10n.refund_hint_searchMedicine,
//       isLoading: isItemsLoading,
//       isEmpty: noPatientSelected || (!isItemsLoading && items.isEmpty),
//       emptyMessage: noPatientSelected
//           ? context.l10n.refund_hint_selectPatientFirst
//           : context.l10n.refund_hint_noMedicineFound,
//       content: (isItemsLoading || noPatientSelected)
//           ? null
//           : CabinOperationCellGrid(
//               singleColumnThreshold: 0,
//               maxColumns: 3,
//               itemCount: items.length,
//               itemBuilder: (context, i) {
//                 final item = items.elementAt(i);
//                 return RefundOperationCard(
//                   item: item,
//                   isSelected: selectedItemIds.contains(item.id),
//                   checkStatus: checkStatuses[item.id] ?? const CheckIdle(),
//                   onTap: () => notifier.toggleItem(item.id),
//                   onAmountChanged: (v) => notifier.updateAmount(item.id, v),
//                 );
//               },
//             ),
//       footer: (selection != null && selection.selectedItems.isNotEmpty)
//           ? MedButton(
//               label: context.l10n.refund_action_start,
//               isLoading: selection.isChecking,
//               suffixIcon: Icon(PhosphorIcons.arrowRight()),
//               onPressed: selection.canStart ? notifier.startRefund : null,
//             )
//           : null,
//     );
//   }
// }
