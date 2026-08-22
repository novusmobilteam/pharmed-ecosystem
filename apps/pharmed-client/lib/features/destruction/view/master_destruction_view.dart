import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/destruction_notifier.dart';
import '../notifier/destruction_state.dart';
import 'destruction_execution_view.dart';
import 'destruction_selection_view.dart';

class MasterDestructionView extends ConsumerStatefulWidget {
  const MasterDestructionView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  ConsumerState<MasterDestructionView> createState() => _MasterDestructionViewState();
}

class _MasterDestructionViewState extends ConsumerState<MasterDestructionView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(destructionNotifierProvider);
    final notifier = ref.read(destructionNotifierProvider.notifier);
    final isExecuting =
        state is DestructionExecuting || (state is DestructionError && state.previousState is DestructionExecuting);
    final isLoading = state is DestructionLoading;
    final cabinData = widget.cabinContext.cabinData;

    ref.listen(destructionNotifierProvider, (_, next) {
      if (next is DestructionError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.census_error_queueTitle,
          customMessage: next.failure.message(context).isNotEmpty
              ? next.failure.message(context)
              : context.l10n.census_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.census_error_continueNext,
          cancelButtonText: context.l10n.census_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is DestructionError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    if (cabinData == null) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }

    if (isLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (isExecuting) {
      return DestructionExecutionView(allGroups: cabinData.groups);
    }

    return DestructionSelectionView(cabinContext: widget.cabinContext);
  }
}
