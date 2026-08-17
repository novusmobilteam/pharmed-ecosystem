// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../widgets/widgets.dart';
// import '../notifier/master_refund_notifier.dart';
// import '../notifier/master_refund_state.dart';
// import 'master_refund_execution_view.dart';
// import 'master_refund_selection_view.dart';

// class MasterRefundView extends ConsumerStatefulWidget {
//   const MasterRefundView({super.key, this.data});

//   final CabinVisualizerData? data;

//   @override
//   ConsumerState<MasterRefundView> createState() => _MasterRefundViewState();
// }

// class _MasterRefundViewState extends ConsumerState<MasterRefundView> {
//   bool _isPatientReady(PatientSelectionState state) => state is PatientSelectionReady;

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(masterRefundNotifierProvider);
//     final notifier = ref.read(masterRefundNotifierProvider.notifier);

//     ref.listen(masterRefundNotifierProvider, (_, next) {
//       if (next is MasterRefundError && next.isQueueError) {
//         MessageUtils.showConfirmDialog(
//           context: context,
//           action: ConfirmAction.custom,
//           customTitle: context.l10n.refund_error_queueTitle,
//           confirmButtonText: context.l10n.refund_error_continueNext,
//           cancelButtonText: context.l10n.refund_error_endProcess,
//           onConfirm: notifier.continueAfterError,
//           onCancel: notifier.abortAfterError,
//         );
//       } else if (next is MasterRefundError) {
//         MessageUtils.showErrorSnackbar(context, next.failure.message(context));
//         notifier.dismissError();
//       }
//     });

//     return MasterCabinRootScaffold<CabinVisualizerData, MasterRefundState>(
//       data: widget.data,
//       cabinIdOf: (d) => d.cabinId,
//       onInit: (d) => notifier.init(d),
//       state: state,
//       extraBootGate: () => !_isPatientReady(ref.watch(patientSelectionNotifierProvider)),
//       phaseOf: (s) => switch (s) {
//         MasterRefundUninitialized() || MasterRefundLoading() => const RootBooting(),
//         MasterRefundExecuting() => const RootExecuting(),
//         MasterRefundError(previousState: MasterRefundExecuting()) => const RootExecuting(),
//         _ => const RootSelection(),
//       },
//       selectionBuilder: (_) => const MasterRefundSelectionView(),
//       executionBuilder: (_) => MasterRefundExecutionView(allGroups: widget.data?.groups ?? const []),
//     );
//   }
// }
