import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../dashboard/dashboard.dart';
import '../../intake.dart';

class MasterIntakeView extends ConsumerStatefulWidget {
  const MasterIntakeView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MasterIntakeViewState();
}

class _MasterIntakeViewState extends ConsumerState<MasterIntakeView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterIntakeNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);
    final isExecuting =
        state is MasterIntakeExecuting ||
        (state is MasterIntakeError && (state).previousState is MasterIntakeExecuting);

    ref.listen(masterIntakeNotifierProvider, (_, next) {
      if (next is MasterIntakeError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.intake_error_queueTitle,
          customMessage: next.failure.message(context).isNotEmpty
              ? next.failure.message(context)
              : context.l10n.intake_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterIntakeError) {
        MessageUtils.showErrorSnackbar(context, next.failure.message(context));
        notifier.dismissError();
      }
    });

    if (state is MasterIntakeUninitialized) {
      return const Center(child: MedLoadingIndicator());
    }

    if (isExecuting) {
      return MasterIntakeExecutionView(cabinDataByCabinId: widget.stationContext.cabinDataByCabinId);
    }

    return MasterIntakeSelectionView(menu: widget.stationContext.menu);
  }
}
