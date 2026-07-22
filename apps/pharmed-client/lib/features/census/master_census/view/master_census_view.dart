// [SWREQ-CLI-MCENSUS-003] [IEC 62304 §5.5]
// Sayım ekranı giriş noktası — MasterRefillView ile birebir aynı desende.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/cabin_operation_panel/cabin_operation_panel.dart';
import '../notifier/master_census_notifier.dart';
import '../notifier/master_census_state.dart';

part 'master_census_execution_panel.dart';
part 'master_census_selection_panel.dart';
part 'census_cell_card.dart';
part 'census_form.dart';

class MasterCensusView extends ConsumerStatefulWidget {
  const MasterCensusView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterCensusView> createState() => _MasterCensusViewState();
}

class _MasterCensusViewState extends ConsumerState<MasterCensusView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterCensusView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterCensusNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterCensusNotifierProvider);

    ref.listen(masterCensusNotifierProvider, (_, next) {
      if (next is MasterCensusError && next.isQueueError) {
        final notifier = ref.read(masterCensusNotifierProvider.notifier);
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
        ref.read(masterCensusNotifierProvider.notifier).dismissError();
      }
    });

    if (widget.data == null || state is MasterCensusUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MasterCensusLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final isExecuting = switch (state) {
      MasterCensusExecuting() => true,
      MasterCensusError(previousState: MasterCensusExecuting()) => true,
      _ => false,
    };

    return Padding(
      padding: MedSpacing.insetXl * 2,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isExecuting
            ? MasterCensusExecutionPanel(key: const ValueKey('execution'), allGroups: widget.data?.groups ?? [])
            : MasterCensusSelectionPanel(key: const ValueKey('selection'), allGroups: widget.data?.groups ?? []),
      ),
    );
  }
}
