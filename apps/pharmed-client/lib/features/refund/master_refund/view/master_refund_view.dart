import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_data_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/empty_widgets/no_selected_hospitalization_view.dart';
import '../../../../widgets/hospitalization_panel/hospitalization_panel.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_refund_execution_notifier.dart';
import '../notifier/master_refund_selection_notifier.dart';

part 'master_refund_selection_view.dart';
part 'master_refund_execution_view.dart';

class MasterRefundView extends ConsumerStatefulWidget {
  const MasterRefundView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterRefundView> createState() => _MasterRefundViewState();
}

class _MasterRefundViewState extends ConsumerState<MasterRefundView> {
  MasterRefundExecutionNotifier? _execution;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterRefundSelectionNotifierProvider).init(widget.stationContext);
    });

    final execution = ref.read(masterRefundExecutionNotifierProvider);
    _execution = execution;
    execution.onQueueFinished = () {
      ref.read(masterRefundSelectionNotifierProvider).refreshAfterExecution();
    };
    execution.addListener(_handleExecutionError);
  }

  @override
  void dispose() {
    _execution?.onQueueFinished = null;
    _execution?.removeListener(_handleExecutionError);
    super.dispose();
  }

  void _handleExecutionError() {
    final execution = _execution;
    if (execution == null) return;
    if (execution.isQueueError) {
      _showQueueErrorDialog(context, execution);
    } else if (execution.failure != null) {
      MessageUtils.showErrorSnackbar(context, execution.failure!.message(context));
      execution.dismissQueueError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterRefundSelectionNotifierProvider);
    final execution = ref.watch(masterRefundExecutionNotifierProvider);

    if (selection.isError) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: execution.isExecuting
          ? MasterRefundExecutionView(
              key: const ValueKey('execution'),
              cabinDataByCabinId: widget.stationContext.cabinDataByCabinId,
            )
          : MasterRefundSelectionView(
              key: const ValueKey('selection'),
              notifier: selection,
              menu: widget.stationContext.menu,
              onStartRefund: () => _startRefund(context, selection, execution),
            ),
    );
  }

  Future<void> _startRefund(
    BuildContext context,
    MasterRefundSelectionNotifier selection,
    MasterRefundExecutionNotifier execution,
  ) async {
    await selection.startRefund(
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg ?? ''),
      onSuccess: () => execution.start(selection.refundTargets),
    );
  }

  void _showQueueErrorDialog(BuildContext context, MasterRefundExecutionNotifier execution) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlem hatası'),
        content: Text(execution.failure?.message(context) ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              execution.abortAfterError();
            },
            child: const Text('Sonlandır'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              execution.continueAfterError();
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }
}
