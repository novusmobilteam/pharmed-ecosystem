import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';
import 'master_unload_execution_view.dart';
import 'master_unload_selection_view.dart';

class MasterUnloadView extends ConsumerStatefulWidget {
  const MasterUnloadView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MasterUnloadViewState();
}

class _MasterUnloadViewState extends ConsumerState<MasterUnloadView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterUnloadNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.cabinContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterUnloadNotifierProvider);
    final notifier = ref.read(masterUnloadNotifierProvider.notifier);
    final isExecuting =
        state is MasterUnloadExecuting || (state is MasterUnloadError && state.previousState is MasterUnloadExecuting);
    final isLoading = state is MasterUnloadLoading;
    final cabinData = widget.cabinContext.cabinData;

    ref.listen(masterUnloadNotifierProvider, (_, next) {
      if (next is MasterUnloadError && next.isQueueError) {
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: context.l10n.intake_error_queueTitle,
          customMessage: next.failure.message(context).isNotEmpty
              ? next.failure.message(context)
              : context.l10n.intake_error_queueMessage,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.unload_error_continueNext,
          cancelButtonText: context.l10n.unload_error_endProcess,
          onConfirm: notifier.continueAfterError,
          onCancel: notifier.abortAfterError,
        );
      } else if (next is MasterUnloadError) {
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
      return MasterUnloadExecutionView(allGroups: cabinData.groups);
    }

    return MasterUnloadSelectionView(cabinContext: widget.cabinContext);
  }
}
