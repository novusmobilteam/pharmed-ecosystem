// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../widgets/widgets.dart';
// import '../notifier/master_waste_notifier.dart';
// import '../notifier/master_waste_state.dart';
// import 'master_waste_selection_view.dart';

// class MasterWasteView extends ConsumerStatefulWidget {
//   const MasterWasteView({super.key, this.data});
//   final CabinVisualizerData? data;

//   @override
//   ConsumerState<MasterWasteView> createState() => _MasterWasteViewState();
// }

// class _MasterWasteViewState extends ConsumerState<MasterWasteView> {
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(masterWasteNotifierProvider);
//     final notifier = ref.read(masterWasteNotifierProvider.notifier);

//     ref.listen(masterWasteNotifierProvider, (_, next) {
//       // Donanım kuyruğu yok → isQueueError dalı gerekmiyor, refund/intake'in
//       // aksine tek tip hata dinleme yeterli.
//       if (next is MasterWasteError) {
//         MessageUtils.showErrorSnackbar(context, next.failure.message(context));
//         notifier.dismissError();
//       }
//     });

//     return MasterCabinRootScaffold<CabinVisualizerData, MasterWasteState>(
//       data: widget.data,
//       cabinIdOf: (d) => d.cabinId,
//       onInit: (d) => notifier.init(d),
//       state: state,
//       phaseOf: (s) => switch (s) {
//         MasterWasteUninitialized() || MasterWasteLoading() => const RootBooting(),
//         _ => const RootSelection(),
//       },
//       selectionBuilder: (_) => const MasterWasteSelectionView(),
//       executionBuilder: (_) => const SizedBox.shrink(), // hiç tetiklenmez — execution fazı yok
//     );
//   }
// }
