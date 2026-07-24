import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../../widgets/widgets.dart';
import '../../../../settings/notifier/settings_notifier.dart';
import '../../../refill.dart';

class MasterRefillExecutionPanel extends ConsumerWidget {
  const MasterRefillExecutionPanel({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefillNotifierProvider);

    final executing = switch (state) {
      MasterRefillExecuting e => e,
      MasterRefillError(previousState: MasterRefillExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    final notifier = ref.read(masterRefillNotifierProvider.notifier);

    return MasterCabinExecutionScaffold(
      progressLabel: context.l10n.refill_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
      progress: executing.progress,
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.refill_action_stop,
      stopConfirmTitle: context.l10n.refill_stop_confirmTitle,
      stopConfirmMessage: context.l10n.refill_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.refill_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: executing.currentIndex,
      openedBuilder: (_) => _FillForm(state: executing, job: job, notifier: notifier),
    );
  }
}

class _FillForm extends ConsumerWidget {
  const _FillForm({required this.state, required this.job, required this.notifier});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;
  final MasterRefillNotifier notifier;

  bool get _canConfirm {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    final target = state.currentTarget;
    final ti = job.isKubik ? state.currentTargetIndex : 0;

    // Kübikte tek-SKT fallback'i hiç yok — her zaman per-cell.
    final isPerCellMiadEnabled = job.isKubik || ref.watch(isPerCellMiadEnabledProvider);

    final entries = job.isKubik
        ? (target == null
              ? const <CabinCellEntry>[]
              : [
                  CabinCellEntry(
                    assignment: target.assignment,
                    current: target.currentQuantity,
                    countQuantity: target.cubicCount,
                    fillingQuantity: target.cubicFilling,
                    miadDate: target.cubicMiad,
                  ),
                ])
        : (target?.steps
                  .map(
                    (step) => CabinCellEntry(
                      assignment: target.assignment,
                      current: target.assignment.toDisplayQuantity(step.countQuantity),
                      countQuantity: step.countQuantity,
                      fillingQuantity: step.fillingQuantity,
                      miadDate: step.miadDate,
                    ),
                  )
                  .toList() ??
              const <CabinCellEntry>[]);

    final isLastCubicCell = job.isKubik && state.currentTargetIndex >= job.targets.length - 1;
    final confirmLabel = (job.isKubik && !isLastCubicCell)
        ? context.l10n.refill_action_nextCell
        : context.l10n.refill_action_completeFilling;

    return CabinCellOperationForm(
      maxWidth: maxWidth,
      isLocked: state.isSaving,
      isKubik: job.isKubik,
      entries: entries,
      onCountChanged: (index, v) =>
          job.isKubik ? notifier.onCubicCountChanged(ti, v) : notifier.onStepCountChanged(ti, index, v),
      showFilling: true,
      onFillingChanged: (index, v) =>
          job.isKubik ? notifier.onCubicFillingChanged(ti, v) : notifier.onStepFillingChanged(ti, index, v),
      isPerCellMiadEnabled: isPerCellMiadEnabled,
      onMiadChanged: (index, d) =>
          job.isKubik ? notifier.onCubicMiadChanged(ti, d) : notifier.onStepMiadChanged(ti, index, d),
      singleMiadDate: target?.singleMiad,
      onSingleMiadChanged: (d) => notifier.onSingleMiadChanged(ti, d),
      stepLabelBuilder: (index) => context.l10n.refill_label_cellNo(index + 1),
      canConfirm: _canConfirm,
      isSaving: state.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
