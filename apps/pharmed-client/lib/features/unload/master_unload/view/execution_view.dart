part of 'master_unload_view.dart';

class MasterUnloadExecutionView extends StatelessWidget {
  const MasterUnloadExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MasterUnloadNotifier>();

    final job = notifier.currentJob;
    if (job == null) return const SizedBox.shrink();

    return CabinOperationExecutionLayout(
      stage: notifier.orchestrator.stage,
      progressLabel: context.l10n.unload_label_queueProgress(_completedJobs(notifier) + 1, notifier.jobs.length),
      progress: _progress(notifier),
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.unload_action_stop,
      stopConfirmTitle: context.l10n.unload_stop_confirmTitle,
      stopConfirmMessage: context.l10n.unload_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.unload_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: _toLocationItems(notifier, allGroups),
      activeIndex: notifier.currentIndex,
      openedBuilder: (_) => _UnloadForm(job: job, notifier: notifier),
      onRequestClose: notifier.orchestrator.confirmClose,
    );
  }

  int _completedJobs(MasterUnloadNotifier notifier) =>
      notifier.jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;

  double _progress(MasterUnloadNotifier notifier) {
    final total = notifier.jobs.length;
    return total == 0 ? 0 : _completedJobs(notifier) / total;
  }

  List<DrawerQueueItem> _toLocationItems(MasterUnloadNotifier notifier, List<DrawerGroup> allGroups) {
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

class _UnloadForm extends StatelessWidget {
  const _UnloadForm({required this.job, required this.notifier});

  final CabinDrawerJob<CabinOperationTarget> job;
  final MasterUnloadNotifier notifier;

  static const double _maxWidth = 720.0;
  static const double _stackSpacing = 8;

  bool get _canConfirm {
    final t = notifier.currentTarget;
    return t != null && t.isValid;
  }

  Widget _kubikCard(BuildContext context, CabinOperationTarget target) {
    final count = target.cubicCount;
    final unload = target.cubicSecondary;

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: target.currentQuantity,
      density: MedValueCardDensity.comfortable,
      fields: [
        MedQuantityValueCard(
          label: context.l10n.unload_label_countQty,
          value: count,
          onChanged: (v) => notifier.onCubicCountChanged(v),
        ),
        MedQuantityValueCard(
          label: context.l10n.unload_label_unloadQty,
          value: unload,
          onChanged: (v) => notifier.onCubicUnloadChanged(v),
        ),
      ],
    );
  }

  Widget _stepCard(BuildContext context, CabinOperationTarget target, int ti, int index) {
    final step = target.steps[index];

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: target.currentQuantity,
      stepLabel: '${index + 1}',
      density: MedValueCardDensity.compact,
      fields: [
        MedQuantityValueCard(
          label: context.l10n.unload_label_countQty,
          value: step.countQuantity,
          onChanged: (v) => notifier.onStepCountChanged(ti, v),
        ),
        MedQuantityValueCard(
          label: context.l10n.unload_label_unloadQty,
          value: step.secondaryQuantity,
          onChanged: (v) => notifier.onStepUnloadChanged(ti, v),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = notifier.currentTarget;
    if (target == null) return const SizedBox.shrink();

    final ti = notifier.currentTargetIndex;
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget ? context.l10n.unload_action_nextCell : context.l10n.unload_action_complete;

    final Widget content;
    if (job.isKubik) {
      content = SingleChildScrollView(child: _kubikCard(context, target));
    } else {
      final itemCount = target.steps.length;
      // Fiziksel çekmecenin ÜSTTEN GÖRÜNÜMÜ: en yüksek göz numarası EN
      // ÜSTTE, göz 1 EN ALTTA — bkz. master-refill-flow skill §10.1.
      content = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = itemCount - 1; i >= 0; i--) ...[
              _stepCard(context, target, ti, i),
              if (i > 0) const SizedBox(height: _stackSpacing),
            ],
          ],
        ),
      );
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
            MedRectangleButton(
              label: confirmLabel,
              suffixIcon: PhosphorIcons.check(),
              foregroundColor: Colors.white,
              isLoading: isSaving,
              isActive: _canConfirm,
              onTap: () => _canConfirm ? notifier.confirmCurrent() : null,
            ),
          ],
        ),
      ),
    );
  }
}
