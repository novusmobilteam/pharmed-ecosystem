import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/refill_list_notifier.dart';
import '../notifier/refill_list_state.dart';
import 'refill_list_execution_view.dart';
import 'refill_list_selection_view.dart';

class RefillListView extends ConsumerStatefulWidget {
  const RefillListView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<RefillListView> createState() => _RefillListViewState();
}

class _RefillListViewState extends ConsumerState<RefillListView> {
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(refillListNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refillListNotifierProvider);
    final notifier = ref.read(refillListNotifierProvider.notifier);
    final isExecuting =
        state is RefillListExecuting || (state is RefillListError && state.previousState is RefillListExecuting);
    final isLoading = state is RefillListLoading;

    ref.listen(refillListNotifierProvider, (_, next) {
      if (next is RefillListError && next.isQueueError) {
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
      } else if (next is RefillListError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    if (isLoading) {
      return Center(child: MedLoadingIndicator());
    }

    if (isExecuting) {
      return RefillListExecutionView(cabinDataByCabinId: widget.stationContext.cabinDataByCabinId);
    }

    return RefillListSelectionView(stationContext: widget.stationContext);
  }
}
