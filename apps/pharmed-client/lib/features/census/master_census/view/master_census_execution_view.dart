// [SWREQ-CLI-MCENSUS-008] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../../../settings/notifier/settings_notifier.dart';
import '../notifier/master_census_notifier.dart';
import '../notifier/master_census_state.dart';

class MasterCensusExecutionView extends ConsumerWidget {
  const MasterCensusExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterCensusNotifierProvider);

    final executing = switch (state) {
      MasterCensusExecuting e => e,
      MasterCensusError(previousState: MasterCensusExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    final notifier = ref.read(masterCensusNotifierProvider.notifier);

    return CabinOperationExecutionLayout(
      progressLabel: context.l10n.census_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
      progress: executing.progress,
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.census_action_stop,
      stopConfirmTitle: context.l10n.census_stop_confirmTitle,
      stopConfirmMessage: context.l10n.census_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.census_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: executing.currentIndex,
      openedBuilder: (_) => _CensusForm(state: executing, job: job, notifier: notifier),
    );
  }
}

class _CensusForm extends ConsumerWidget {
  const _CensusForm({required this.state, required this.job, required this.notifier});

  final MasterCensusExecuting state;
  final CabinOperationDrawerJob job;
  final MasterCensusNotifier notifier;

  bool get _canConfirm {
    final t = state.currentTarget;
    return t != null && t.isValid;
  }

  Widget _cellCard(
    BuildContext context,
    WidgetRef ref,
    CabinOperationTarget target,
    int index,
    int ti,
    bool isPerCellMiadEnabled,
  ) {
    final step = job.isKubik ? null : target.steps[index];
    final count = job.isKubik ? target.cubicCount : step!.countQuantity;
    final miad = job.isKubik ? target.cubicMiad : step!.miadDate;

    final hasEntry = (count ?? 0) > 0;
    final miadHasError = isPerCellMiadEnabled && ((hasEntry && miad == null) || miad.isExpiredMiad);

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: job.isKubik ? target.currentQuantity : target.assignment.toDisplayQuantity(step!.countQuantity),
      stepLabel: job.isKubik ? null : context.l10n.refill_label_cellNo(index + 1),
      density: job.isKubik ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      hasError: miadHasError,
      fields: [
        MedQuantityValueCard(
          label: context.l10n.census_label_countQty,
          value: count,
          onChanged: (v) =>
              job.isKubik ? notifier.onCubicCountChanged(ti, v) : notifier.onStepCountChanged(ti, index, v),
        ),
        if (isPerCellMiadEnabled)
          MedDateValueCard(label: context.l10n.refill_label_expiryDate, date: miad, hasError: miadHasError),
      ],
    );
  }

  Widget _singleMiadHeader(BuildContext context, CabinOperationTarget target) {
    final singleMiad = target.singleMiad;
    final hasError = (target.hasEntry && singleMiad == null) || singleMiad.isExpiredMiad;
    return MedDateValueCard(label: context.l10n.refill_label_expiryDate, date: singleMiad, hasError: hasError);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    final target = state.currentTarget;
    final ti = state.currentTargetIndex;

    final isPerCellMiadEnabled = job.isKubik || ref.watch(isPerCellMiadEnabledProvider);

    final itemCount = job.isKubik ? 1 : (target?.steps.length ?? 0);

    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.census_action_nextCell
        : context.l10n.census_action_completeCensus;

    return CabinExecutionGrid(
      maxWidth: maxWidth,
      isLocked: state.isSaving,
      isKubik: job.isKubik,
      itemCount: itemCount,
      itemBuilder: target == null
          ? (_, _) => const SizedBox.shrink()
          : (context, index) => _cellCard(context, ref, target, index, ti, isPerCellMiadEnabled),
      header: (!isPerCellMiadEnabled && target != null) ? (ctx) => _singleMiadHeader(ctx, target) : null,
      canConfirm: _canConfirm,
      isSaving: state.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
