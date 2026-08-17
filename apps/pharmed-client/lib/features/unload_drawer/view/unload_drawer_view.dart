// // features/unload_drawer/view/unload_drawer_view.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../widgets/widgets.dart';
// import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
// import '../../dashboard/presentation/notifier/dashboard_state.dart';
// import '../notifier/unload_drawer_notifier.dart';
// import '../notifier/unload_drawer_state.dart';
// import 'unload_drawer_execution_view.dart';
// import 'unload_drawer_selection_view.dart';

// /// Menü/dashboard tarafından çağrılan giriş noktası — RefundView'daki gibi
// /// device-mode switch YOK, çünkü bu feature'ın mobil karşılığı yok
// /// (bkz. cabin-domain: mobile cabin'de iade çekmecesi/kutusu kavramı
// /// tanımlı değil). Sadece cabinVisualizerData'yı dashboard'dan çekip
// /// _UnloadDrawerScaffold'a devrediyor.
// class UnloadDrawerView extends ConsumerWidget {
//   const UnloadDrawerView({super.key, required this.menu});

//   final MenuItem menu;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final cabinData = ref.watch(
//       dashboardNotifierProvider.select(
//         (s) => switch (s) {
//           DashboardLoaded(:final data) => data.cabinVisualizerData,
//           _ => null,
//         },
//       ),
//     );

//     return _UnloadDrawerScaffold(data: cabinData);
//   }
// }

// class _UnloadDrawerScaffold extends ConsumerStatefulWidget {
//   const _UnloadDrawerScaffold({this.data});

//   final CabinVisualizerData? data;

//   @override
//   ConsumerState<_UnloadDrawerScaffold> createState() => _UnloadDrawerScaffoldState();
// }

// class _UnloadDrawerScaffoldState extends ConsumerState<_UnloadDrawerScaffold> {
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(unloadDrawerNotifierProvider);
//     final notifier = ref.read(unloadDrawerNotifierProvider.notifier);

//     ref.listen(unloadDrawerNotifierProvider, (_, next) {
//       if (next is UnloadDrawerError && next.isQueueError) {
//         MessageUtils.showConfirmDialog(
//           context: context,
//           action: ConfirmAction.custom,
//           customTitle: context.l10n.unload_error_queueTitle,
//           confirmButtonText: context.l10n.common_okButton,
//           onConfirm: notifier.abortAfterError,
//         );
//       } else if (next is UnloadDrawerError) {
//         MessageUtils.showErrorSnackbar(context, next.failure.message(context));
//         notifier.dismissError();
//       }
//     });

//     return MasterCabinRootScaffold<CabinVisualizerData, UnloadDrawerState>(
//       data: widget.data,
//       cabinIdOf: (d) => d.cabinId,
//       onInit: (d) => notifier.init(d),
//       state: state,
//       phaseOf: (s) => switch (s) {
//         UnloadDrawerUninitialized() || UnloadDrawerLoading() => const RootBooting(),
//         UnloadDrawerExecuting() => const RootExecuting(),
//         UnloadDrawerError(previousState: UnloadDrawerExecuting()) => const RootExecuting(),
//         _ => const RootSelection(),
//       },
//       selectionBuilder: (_) => const UnloadDrawerSelectionView(),
//       executionBuilder: (_) => UnloadDrawerExecutionView(allGroups: widget.data?.groups ?? const []),
//     );
//   }
// }
