import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';

import '../../dashboard/dashboard.dart';
import '../notifier/unload_drawer_notifier.dart';
import '../notifier/unload_drawer_state.dart';
import 'unload_drawer_execution_view.dart';
import 'unload_drawer_selection_view.dart';

class UnloadDrawerScreen extends ConsumerStatefulWidget {
  const UnloadDrawerScreen({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  ConsumerState<UnloadDrawerScreen> createState() => UnloadDrawerScreenState();
}

class UnloadDrawerScreenState extends ConsumerState<UnloadDrawerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unloadDrawerNotifierProvider);
    final notifier = ref.read(unloadDrawerNotifierProvider.notifier);
    final isExecuting =
        state is UnloadDrawerExecuting || (state is UnloadDrawerError && state.previousState is UnloadDrawerExecuting);
    final isLoading = state is UnloadDrawerLoading;
    final cabinData = widget.cabinRouteContext.cabinData;

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

    if (cabinData == null) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }

    if (isExecuting) {
      return UnloadDrawerExecutionView(allGroups: cabinData.groups);
    }

    return UnloadDrawerSelectionView(cabinContext: widget.cabinRouteContext);
  }
}
