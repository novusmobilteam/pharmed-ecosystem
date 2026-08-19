// features/unload_drawer/view/unload_drawer_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';

import '../notifier/unload_drawer_notifier.dart';
import '../notifier/unload_drawer_state.dart';
import 'unload_drawer_execution_view.dart';
import 'unload_drawer_selection_view.dart';

class UnloadDrawerView extends ConsumerWidget {
  const UnloadDrawerView({super.key, required this.menu, this.cabinData});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _UnloadDrawerScaffold(data: cabinData);
  }
}

class _UnloadDrawerScaffold extends ConsumerStatefulWidget {
  const _UnloadDrawerScaffold({this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<_UnloadDrawerScaffold> createState() => _UnloadDrawerScaffoldState();
}

class _UnloadDrawerScaffoldState extends ConsumerState<_UnloadDrawerScaffold> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unloadDrawerNotifierProvider);
    final notifier = ref.read(unloadDrawerNotifierProvider.notifier);

    ref.listen(unloadDrawerNotifierProvider, (_, next) {
      if (next is UnloadDrawerError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.unload_error_queueTitle,
          confirmButtonText: context.l10n.common_okButton,
          onConfirm: notifier.abortAfterError,
        );
      } else if (next is UnloadDrawerError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    return MasterCabinRootScaffold<CabinVisualizerData, UnloadDrawerState>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      phaseOf: (s) => switch (s) {
        UnloadDrawerUninitialized() || UnloadDrawerLoading() => const RootBooting(),
        UnloadDrawerExecuting() => const RootExecuting(),
        UnloadDrawerError(previousState: UnloadDrawerExecuting()) => const RootExecuting(),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => const UnloadDrawerSelectionView(),
      executionBuilder: (_) => UnloadDrawerExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }
}
