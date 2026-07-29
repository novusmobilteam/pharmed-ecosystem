// [SWREQ-CLI-MREFILL-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin dolum ekranının root view'ı.
//
// HMI tek-iş prensibi: her an ekranda TEK panel tam ekran gösterilir.
//   - Selection fazı → MasterRefillSelectionPanel
//   - Executing fazı → MasterRefillExecutionPanel (çekmece açılıyor / form)
// Panel geçişi state tipine göre yapılır; iki panel asla yan yana durmaz.
//
// Sorumluluk:
//   - CabinVisualizerData ile MasterRefillNotifier'ı initialize eder
//   - Kuyruk hatası dialog'unu yönetir
//   - MasterDrawerOperationWrapper ile sarar (sol alt köşe çekmece banner'ı)
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/hardware.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../refill.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);

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

    return MasterCabinRootScaffold<CabinVisualizerData, MasterRefillState>(
      data: widget.data,
      cabinIdOf: (d) => d.cabinId,
      onInit: (d) => notifier.init(d),
      state: state,
      phaseOf: (s) => switch (s) {
        MasterRefillUninitialized() || MasterRefillLoading() => const RootBooting(),
        MasterRefillExecuting() => const RootExecuting(),
        MasterRefillError(previousState: MasterRefillExecuting()) => const RootExecuting(),
        _ => const RootSelection(),
      },
      selectionBuilder: (_) => MasterRefillSelectionView(allGroups: widget.data?.groups ?? const []),
      executionBuilder: (_) => MasterRefillExecutionView(allGroups: widget.data?.groups ?? const []),
    );
  }
}
