// // [SWREQ-CLI-INTAKE-010] [IEC 62304 §5.5]
// // Mobil ilaç alım işlemi tam ekran dialog'u.
// //
// // Çekmece açıldığında otomatik gösterilir, alım tamamlanınca kapanır.
// // State değişiklikleri ref.watch ile yansır.
// //
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../widgets/cabin_operation_dialog/cabin_operation_dialog.dart';
// import '../../intake.dart';

// part 'items_list.dart';
// part 'footer.dart';

// class MobileIntakeDialog extends ConsumerWidget {
//   const MobileIntakeDialog({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(mobileIntakeNotifierProvider);
//     final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
//     final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

//     if (!state.shouldKeepDialog(drawerStage)) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (context.mounted && Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//       });
//       return const SizedBox.shrink();
//     }

//     final ready = state.readyContext;

//     if (ready == null) {
//       return const SizedBox.shrink();
//     }

//     final errorMessage = state is MobileIntakeError ? state.message : null;

//     return CabinOperationDialog(
//       type: CabinInventoryType.intake,
//       statusInput: OperationStatusInput(
//         phase: _intakePhase(state),
//         drawerStage: drawerStage,
//         baselineCompleted: ready.baselineCompleted,
//         canComplete: ready.canComplete,
//       ),
//       stats: [
//         StatCellData(
//           label: context.l10n.cabinOperation_label_selected,
//           value: context.l10n.refill_label_multiMedicine(ready.selectedItemIds.length),
//         ),
//         StatCellData(
//           label: context.l10n.intake_label_readInCabin,
//           value: context.l10n.intake_label_tagCount(ready.totalReadCount),
//         ),
//         StatCellData(label: context.l10n.intake_label_takenCount, value: '${ready.takenEpcs.length}'),
//         StatCellData(
//           label: context.l10n.intake_label_unauthorizedTake,
//           value: '${ready.unplannedMovements.length}',
//           valueColor: ready.unplannedMovements.isNotEmpty ? MedColors.red : null,
//         ),
//       ],
//       banners: [
//         if (errorMessage != null) OperationErrorBanner(message: context.l10n.intake_error_retryOrFinish),
//         if (ready.hasExtraPlacement) UnexpectedTagBanner(epcs: ready.placedEpcs),
//         if (ready.hasUnplannedMovement) UnplannedMovementBanner(epcs: ready.unplannedMovements),
//       ],
//       footerContent: _intakeFooter(context, state, drawerStage, ready, notifier),
//       child: _ItemsList(),
//     );
//   }
// }

// OperationPhase _intakePhase(MobileIntakeState s) {
//   if (s is MobileIntakeFatalError) return OperationPhase.fatal;
//   if (s is MobileIntakeSaving) return OperationPhase.saving;
//   if (s is MobileIntakeError) return OperationPhase.error;
//   return OperationPhase.normal;
// }
