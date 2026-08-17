part of 'master_census_view.dart'; // ya da projenin mevcut import yapısına göre ayarla

class MasterCensusExecutionView extends StatelessWidget {
  const MasterCensusExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MasterCensusNotifier>();

    final job = notifier.currentJob;
    if (job == null) return const SizedBox.shrink();

    return CabinOperationExecutionLayout(
      stage: notifier.orchestrator.stage,
      progressLabel: context.l10n.census_label_queueProgress(_completedJobs(notifier) + 1, notifier.jobs.length),
      progress: _progress(notifier),
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.census_action_stop,
      stopConfirmTitle: context.l10n.census_stop_confirmTitle,
      stopConfirmMessage: context.l10n.census_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.census_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: _toLocationItems(notifier, allGroups),
      activeIndex: notifier.currentIndex,
      openedBuilder: (_) => _CensusForm(job: job, notifier: notifier),
      onRequestClose: notifier.orchestrator.confirmClose,
    );
  }

  int _completedJobs(MasterCensusNotifier notifier) =>
      notifier.jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;

  double _progress(MasterCensusNotifier notifier) {
    final total = notifier.jobs.length;
    return total == 0 ? 0 : _completedJobs(notifier) / total;
  }

  List<DrawerQueueItem> _toLocationItems(MasterCensusNotifier notifier, List<DrawerGroup> allGroups) {
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

class _CensusForm extends StatelessWidget {
  const _CensusForm({required this.job, required this.notifier});

  final CabinDrawerJob<CabinOperationTarget> job;
  final MasterCensusNotifier notifier;

  static const double _maxWidth = 720.0;
  static const double _stackSpacing = 8;

  bool get _canConfirm {
    final t = notifier.currentTarget;
    return t != null && t.isValid;
  }

  Widget _cellCard(BuildContext context, CabinOperationTarget target, int index, bool isPerCellMiadEnabled) {
    final step = job.isKubik ? null : target.steps[index];
    final count = job.isKubik ? target.cubicCount : step!.countQuantity;
    final miad = job.isKubik ? target.cubicMiad : step!.miadDate;

    final hasEntry = (count ?? 0) > 0;
    final miadHasError = isPerCellMiadEnabled && ((hasEntry && miad == null) || miad.isExpiredMiad);
    final unitSuffix = target.assignment.medicine?.operationUnitLocalized(context);

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: job.isKubik ? target.currentQuantity : target.assignment.toDisplayQuantity(step!.countQuantity ?? 0),
      stepLabel: job.isKubik ? null : context.l10n.refill_label_cellNo(index + 1),
      density: job.isKubik ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      hasError: miadHasError,
      fields: [
        MedQuantityValueCard(
          label: context.l10n.census_label_countQty,
          value: count,
          suffix: unitSuffix,
          onChanged: (v) => job.isKubik ? notifier.onCubicCountChanged(v) : notifier.onStepCountChanged(index, v),
        ),
        if (isPerCellMiadEnabled)
          MedDateValueCard(
            label: context.l10n.refill_label_expiryDate,
            date: miad,
            hasError: miadHasError,
            onChanged: (d) => job.isKubik ? notifier.onCubicMiadChanged(d) : notifier.onStepMiadChanged(index, d),
          ),
      ],
    );
  }

  Widget _singleMiadHeader(BuildContext context, CabinOperationTarget target) {
    final singleMiad = target.singleMiad;
    final hasError = (target.hasEntry && singleMiad == null) || singleMiad.isExpiredMiad;

    return MedDateValueCard(
      label: context.l10n.refill_label_expiryDate,
      date: singleMiad,
      hasError: hasError,
      onChanged: notifier.onSingleMiadChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = notifier.currentTarget;
    final ti = notifier.currentTargetIndex;

    final isPerCellMiadEnabled = context.read<SettingsNotifier>().isPerCellMiadEnabled;

    final itemCount = job.isKubik ? 1 : (target?.steps.length ?? 0);

    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.census_action_nextCell
        : context.l10n.census_action_completeCensus;

    Widget content;
    if (target == null) {
      content = const SizedBox.shrink();
    } else if (job.isKubik) {
      content = SingleChildScrollView(child: _cellCard(context, target, 0, isPerCellMiadEnabled));
    } else {
      // Fiziksel çekmecenin ÜSTTEN GÖRÜNÜMÜ: en yüksek göz numarası EN
      // ÜSTTE, göz 1 EN ALTTA — bkz. master-refill-flow skill §10.1.
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
              child: MedRectangleButton(
                label: confirmLabel,
                isLoading: isSaving,
                foregroundColor: Colors.white,
                suffixIcon: PhosphorIcons.check(),
                isActive: _canConfirm,
                onTap: _canConfirm ? notifier.confirmCurrent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
