import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../dashboard/dashboard.dart';
import '../../refill.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.cabinContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final isExecuting =
        state is MasterRefillExecuting || (state is MasterRefillError && state.previousState is MasterRefillExecuting);
    final isLoading = state is MasterRefillLoading;
    final cabinData = widget.cabinContext.cabinData;

    ref.listen(masterRefillNotifierProvider, (_, next) {
      if (next is MasterRefillError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.refill_error_queueTitle,
          customMessage: next.failure.message(context).isNotEmpty
              ? next.failure.message(context)
              : context.l10n.refill_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterRefillError) {
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
      return MasterRefillExecutionView(allGroups: cabinData.groups);
    }

    return MasterRefillSelectionView(cabinContext: widget.cabinContext);
  }
}
