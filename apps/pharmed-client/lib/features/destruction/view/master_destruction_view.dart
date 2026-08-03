// master_destruction_view.dart
// İsim MasterCensusView ile tutarlı (Master + ekran adı) — eski
// "DesctructionView" yazım hatası düzeltildi, ayrıca artık data widget'a
// dışarıdan sabit geçilmiyor, üstteki DestructionView tarafından ref.watch
// ile canlı izlenip aktarılıyor (CensusView ile aynı desen).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';
import '../../../widgets/widgets.dart';
import '../notifier/destruction_notifier.dart';
import '../notifier/destruction_state.dart';
import 'destruction_execution_view.dart';
import 'destruction_selection_view.dart';

class MasterDestructionView extends ConsumerStatefulWidget {
  const MasterDestructionView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterDestructionView> createState() => _MasterDestructionViewState();
}

class _MasterDestructionViewState extends ConsumerState<MasterDestructionView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(destructionNotifierProvider);
    final notifier = ref.read(destructionNotifierProvider.notifier);

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

    return MasterCabinRootScaffold<CabinVisualizerData, DestructionState>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      phaseOf: (s) => switch (s) {
        DestructionUninitialized() || DestructionLoading() => const RootBooting(),
        DestructionExecuting() => const RootExecuting(),
        DestructionError(previousState: DestructionExecuting()) => const RootExecuting(),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => DestructionSelectionView(allGroups: widget.data?.groups ?? const []),
      executionBuilder: (_) => DestructionExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }
}
