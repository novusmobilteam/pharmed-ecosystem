import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';
import 'master_unload_execution_view.dart';
import 'master_unload_selection_view.dart';

// view/master_unload_view.dart
class MasterUnloadView extends ConsumerWidget {
  const MasterUnloadView({super.key, required this.data});

  final CabinVisualizerData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterUnloadNotifierProvider);
    final notifier = ref.read(masterUnloadNotifierProvider.notifier);

    ref.listen(masterUnloadNotifierProvider, (_, next) {
      if (next is MasterUnloadError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          action: ConfirmAction.custom,
          customTitle: context.l10n.unload_error_queueTitle,
          confirmButtonText: context.l10n.unload_error_continueNext,
          cancelButtonText: context.l10n.unload_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
          context: context,
        );
      } else if (next is MasterUnloadError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    return MasterCabinRootScaffold<CabinVisualizerData, MasterUnloadState>(
      data: data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      phaseOf: (s) => switch (s) {
        MasterUnloadUninitialized() || MasterUnloadLoading() => const RootBooting(),
        MasterUnloadExecuting() => const RootExecuting(),
        MasterUnloadError(previousState: MasterUnloadExecuting()) => const RootExecuting(),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => MasterUnloadSelectionView(allGroups: data?.groups ?? const []),
      executionBuilder: (_) => MasterUnloadExecutionView(allGroups: data?.groups ?? const []),
    );
  }
}
