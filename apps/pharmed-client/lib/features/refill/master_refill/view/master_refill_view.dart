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

import '../notifier/master_refill_notifier.dart';
import '../notifier/master_refill_state.dart';
import 'master_refill_selection_panel.dart';
import 'master_refill_execution_panel.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterRefillView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterRefillNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefillNotifierProvider);

    ref.listen(masterRefillNotifierProvider, (_, next) {
      if (next is MasterRefillError && next.isQueueError) {
        final notifier = ref.read(masterRefillNotifierProvider.notifier);
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
        ref.read(masterRefillNotifierProvider.notifier).dismissError();
      }
    });

    if (widget.data == null || state is MasterRefillUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MasterRefillLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // Yürütme fazı mı? (hata durumunda previousState'e bakılır)
    final isExecuting = switch (state) {
      MasterRefillExecuting() => true,
      MasterRefillError(previousState: MasterRefillExecuting()) => true,
      _ => false,
    };

    return Padding(
      padding: MedSpacing.insetXl * 2,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isExecuting
            ? MasterRefillExecutionPanel(key: ValueKey('execution'), allGroups: widget.data?.groups ?? [])
            : const MasterRefillSelectionPanel(key: ValueKey('selection')),
      ),
    );
  }
}
