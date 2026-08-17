// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../unload.dart';
// import 'mobile_unload_dialog.dart';

// class MobileUnloadView extends ConsumerStatefulWidget {
//   const MobileUnloadView({super.key, this.data});

//   final CabinVisualizerData? data;

//   @override
//   ConsumerState<MobileUnloadView> createState() => _MobileUnloadViewState();
// }

// class _MobileUnloadViewState extends ConsumerState<MobileUnloadView> {
//   bool _isDialogOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _initialize(widget.data);
//   }

//   @override
//   void didUpdateWidget(MobileUnloadView old) {
//     super.didUpdateWidget(old);
//     if (widget.data?.cabinId != old.data?.cabinId) {
//       _initialize(widget.data);
//     }
//   }

//   void _initialize(CabinVisualizerData? data) {
//     if (data == null) return;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       ref.read(mobileUnloadNotifierProvider.notifier).init(data);
//     });
//   }

//   void _syncDialog(BuildContext context) {
//     final state = ref.read(mobileUnloadNotifierProvider);
//     final stage = ref.read(mobileDrawerSessionProvider).stage;
//     if (state.shouldKeepDialog(stage) && !_isDialogOpen) {
//       _isDialogOpen = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const MobileUnloadDialog(),
//       ).then((_) => _isDialogOpen = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(mobileUnloadNotifierProvider);
//     final notifier = ref.read(mobileUnloadNotifierProvider.notifier);
//     final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

//     ref.listen<MobileUnloadState>(mobileUnloadNotifierProvider, (_, _) => _syncDialog(context));
//     ref.listen<MobileDrawerSessionState>(mobileDrawerSessionProvider, (_, _) => _syncDialog(context));

//     ref.listen(mobileUnloadNotifierProvider, (_, next) {
//       if (next is MobileUnloadError) {
//         final stage = ref.read(mobileDrawerSessionProvider).stage;
//         if (!next.shouldKeepDialog(stage)) {
//           MessageUtils.showErrorSnackbar(context, next.message);
//           notifier.dismissError();
//         }
//       } else if (next is MobileUnloadFatalError) {
//         MessageUtils.showErrorSnackbar(context, next.failure.message(context));
//         notifier.dismissError();
//       } else if (next is MobileUnloadSuccess) {
//         MessageUtils.showSuccessSnackbar(context, context.l10n.unload_success_completed);
//         notifier.dismissSuccess();
//       }
//     });

//     if (widget.data == null || state is MobileUnloadUninitialized) {
//       return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
//     }

//     return CabinOperationScaffold(
//       leftPanel: MobileCabinOverviewPanel(
//         slots: state.slots,
//         selectedSlotId: state.selectedSlotId,
//         mode: CabinOperationMode.unload,
//         onSlotTap: notifier.onSlotTap,
//       ),
//       centerPanel: MobileCabinDrawerPanel(
//         mode: CabinOperationMode.unload,
//         slot: state.selectedSlot,
//         selectedCell: state.selectedCell,
//         onCellTap: notifier.onCellTap,
//         assignmentByCoord: state.assignmentByCoord,
//       ),
//       rightPanel: MobileUnloadPanel(
//         notifier: notifier,
//         state: state,
//         drawerStage: drawerStage,
//         onStartUnload: notifier.startUnload,
//         onCompleteUnload: notifier.completeUnload,

//         onSelectAssignment: notifier.selectAssignment,
//         onChangePatient: notifier.clearPatientSelection,
//       ),
//     );
//   }
// }
