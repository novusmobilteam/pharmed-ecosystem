import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../dashboard/dashboard.dart';
import '../../census.dart';
import '../notifier/master_census_notifier.dart';
import '../notifier/master_census_state.dart';

class MasterCensusView extends ConsumerStatefulWidget {
  const MasterCensusView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  ConsumerState<MasterCensusView> createState() => _MasterCensusViewState();
}

class _MasterCensusViewState extends ConsumerState<MasterCensusView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterCensusNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.cabinContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterCensusNotifierProvider);
    final notifier = ref.read(masterCensusNotifierProvider.notifier);
    final isExecuting =
        state is MasterCensusExecuting || (state is MasterCensusError && state.previousState is MasterCensusExecuting);
    final isLoading = state is MasterCensusLoading;
    final cabinData = widget.cabinContext.cabinData;

    ref.listen(masterCensusNotifierProvider, (_, next) {
      if (next is MasterCensusError && next.isQueueError) {
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
      } else if (next is MasterCensusError) {
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
      return MasterCensusExecutionView(allGroups: cabinData.groups);
    }

    return MasterCensusSelectionView(cabinContext: widget.cabinContext);
  }
}
