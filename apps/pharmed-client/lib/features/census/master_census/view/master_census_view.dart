import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../census.dart';
import '../notifier/master_census_notifier.dart';
import '../notifier/master_census_state.dart';

class MasterCensusView extends ConsumerStatefulWidget {
  const MasterCensusView({super.key, this.data, required this.menu});

  final CabinVisualizerData? data;
  final MenuItem menu;

  @override
  ConsumerState<MasterCensusView> createState() => _MasterCensusViewState();
}

class _MasterCensusViewState extends ConsumerState<MasterCensusView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterCensusNotifierProvider);
    final notifier = ref.read(masterCensusNotifierProvider.notifier);

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

    return MasterCabinRootScaffold<CabinVisualizerData, MasterCensusState>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      phaseOf: (s) => switch (s) {
        MasterCensusUninitialized() || MasterCensusLoading() => const RootBooting(),
        MasterCensusExecuting() => const RootExecuting(),
        MasterCensusError(previousState: MasterCensusExecuting()) => const RootExecuting(),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => MasterCensusSelectionView(allGroups: widget.data?.groups ?? const [], menu: widget.menu),
      executionBuilder: (_) => MasterCensusExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }
}
