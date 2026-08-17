// [SWREQ-CLI-MCENSUS-008] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/widgets.dart';
import '../../../widgets/cabin_shell_widgets/cabin_operation_execution_layout.dart';
import '../../settings/notifier/settings_notifier.dart';
import '../notifier/destruction_notifier.dart';

class DestructionExecutionView extends StatelessWidget {
  const DestructionExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DestructionNotifier>();

    final job = notifier.currentJob;
    if (job == null) return const SizedBox.shrink();

    return CabinOperationExecutionLayout(
      stage: notifier.orchestrator.stage,
      progressLabel: context.l10n.destruction_label_queueProgress(_completedJobs(notifier) + 1, notifier.jobs.length),
      progress: _progress(notifier),
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.destruction_action_stop,
      stopConfirmTitle: context.l10n.destruction_stop_confirmTitle,
      stopConfirmMessage: context.l10n.destruction_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.destruction_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: _toLocationItems(notifier, allGroups),
      activeIndex: notifier.currentIndex,
      openedBuilder: (_) => _DestructionForm(job: job, notifier: notifier),
      onRequestClose: notifier.orchestrator.confirmClose,
    );
  }

  int _completedJobs(DestructionNotifier notifier) =>
      notifier.jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;

  double _progress(DestructionNotifier notifier) {
    final total = notifier.jobs.length;
    return total == 0 ? 0 : _completedJobs(notifier) / total;
  }

  List<DrawerQueueItem> _toLocationItems(DestructionNotifier notifier, List<DrawerGroup> allGroups) {
    return buildCabinExecutionLocationItems(
      allGroups: allGroups,
      jobs: notifier.jobs,
      currentIndex: notifier.currentIndex,
      currentTargetIndex: notifier.currentTargetIndex,
      cabinDrawerIdOf: (job) => job.cabinDrawerId,
      statusOf: (job) => job.status,
      targetCountOf: (job) => job.targets.length,
      assignmentAt: (job, i) => job.targets[i].assignment,
    );
  }
}

class _DestructionForm extends StatelessWidget {
  const _DestructionForm({required this.job, required this.notifier});

  final CabinDrawerJob<CabinOperationTarget> job;
  final DestructionNotifier notifier;

  static const double _maxWidth = 720.0;
  static const double _stackSpacing = 8;

  bool get _canConfirm {
    final t = notifier.currentTarget;
    return t != null && t.isValid;
  }

  Widget _cellCard(BuildContext context, CabinOperationTarget target, int index, bool isPerCellMiadEnabled) {
    final step = job.isKubik ? null : target.steps[index];
    final currentStock = job.isKubik
        ? target.currentQuantity
        : target.assignment?.toDisplayQuantity(step!.countQuantity ?? 0) ?? 0;
    final count = job.isKubik ? target.cubicCount : step!.countQuantity;
    final destroyQty = job.isKubik ? target.cubicSecondary : step!.secondaryQuantity;
    final miad = job.isKubik ? target.cubicMiad : step!.miadDate;

    final hasEntry = (count ?? 0) > 0;
    final miadHasError = isPerCellMiadEnabled && ((hasEntry && miad == null) || miad.isExpiredMiad);
    final unitSuffix = target.assignment?.medicine?.operationUnitLocalized(context);

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: currentStock,
      stepLabel: job.isKubik ? null : context.l10n.refill_label_cellNo(index + 1),
      density: job.isKubik ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      hasError: miadHasError,
      fields: [
        MedQuantityValueCard(label: context.l10n.refund_label_quantity, value: currentStock, suffix: unitSuffix),
        MedQuantityValueCard(
          label: context.l10n.destruction_label_quantity,
          value: destroyQty,
          suffix: unitSuffix,
          onChanged: (v) =>
              job.isKubik ? notifier.onCubicSecondaryChanged(v) : notifier.onStepSecondaryChanged(index, v),
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
  Widget build(BuildContext context) {
    final target = notifier.currentTarget;
    final ti = notifier.currentTargetIndex;

    final isPerCellMiadEnabled = job.isKubik || context.watch<SettingsNotifier>().isPerCellMiadEnabled;
    final itemCount = job.isKubik ? 1 : (target?.steps.length ?? 0);

    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.destruction_action_nextCell
        : context.l10n.destruction_action_completeDestruction;

    Widget content;
    if (target == null) {
      content = const SizedBox.shrink();
    } else if (job.isKubik) {
      content = SingleChildScrollView(child: _cellCard(context, target, 0, isPerCellMiadEnabled));
    } else {
      final stack = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = itemCount - 1; i >= 0; i--) ...[
            _cellCard(context, target, i, isPerCellMiadEnabled),
            if (i > 0) const SizedBox(height: _stackSpacing),
          ],
        ],
      );

      content = !isPerCellMiadEnabled
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _singleMiadHeader(context, target),
                Expanded(child: SingleChildScrollView(child: stack)),
              ],
            )
          : SingleChildScrollView(child: stack);
    }

    final isSaving = notifier.isLoading(notifier.submitTargetOp);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: isSaving ? 0.55 : 1.0,
                child: IgnorePointer(ignoring: isSaving, child: content),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MedButton(
                label: confirmLabel,
                size: MedButtonSize.lg,
                isLoading: isSaving,
                onPressed: _canConfirm ? notifier.confirmCurrent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
