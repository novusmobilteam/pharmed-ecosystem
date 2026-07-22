part of 'master_census_view.dart';

class _CensusForm extends StatelessWidget {
  const _CensusForm({required this.state, required this.job, required this.notifier});

  final MasterCensusExecuting state;
  final CensusDrawerJob job;
  final MasterCensusNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    return CabinOperationFillArea(
      maxWidth: maxWidth,
      isLocked: state.isSaving,
      content: job.isKubik
          ? _KubikBody(state: state, notifier: notifier)
          : _UnitDoseBody(state: state, notifier: notifier),
      footer: _FooterButton(state: state, job: job, onConfirm: notifier.confirmCurrent),
    );
  }
}

class _KubikBody extends StatelessWidget {
  const _KubikBody({required this.state, required this.notifier});

  final MasterCensusExecuting state;
  final MasterCensusNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    final ti = state.currentTargetIndex;
    if (target == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: CensusCellCard(
        density: MedValueCardDensity.comfortable,
        assignment: target.assignment,
        current: target.currentQuantity,
        countQuantity: target.cubicCount,
        miadDate: target.cubicMiad,
        onCountChanged: (v) => notifier.onCubicCountChanged(ti, v),
        onMiadChanged: (d) => notifier.onCubicMiadChanged(ti, d),
      ),
    );
  }
}

class _UnitDoseBody extends StatelessWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterCensusExecuting state;
  final MasterCensusNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();
    const ti = 0; // birim dozda job içinde tek target

    // Refill'in aksine burada isPerCellMiadEnabled kontrolü YOK — sayımda
    // SKT her zaman per-cell (bkz. CensusTarget.isValid).
    return CabinOperationCellGrid(
      itemCount: target.steps.length,
      targetItemWidth: 300,
      itemBuilder: (context, i) {
        final step = target.steps[i];
        return CensusCellCard(
          assignment: target.assignment,
          stepLabel: context.l10n.refill_label_cellNo(i + 1),
          current: target.assignment.toDisplayQuantity(step.countQuantity),
          countQuantity: step.countQuantity,
          miadDate: step.miadDate,
          onCountChanged: (v) => notifier.onStepCountChanged(ti, i, v),
          onMiadChanged: (d) => notifier.onStepMiadChanged(ti, i, d),
        );
      },
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.state, required this.job, required this.onConfirm});

  final MasterCensusExecuting state;
  final CensusDrawerJob job;
  final Future<void> Function() onConfirm;

  bool get _canConfirm {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }

  @override
  Widget build(BuildContext context) {
    final isLastCubicCell = job.isKubik && state.currentTargetIndex >= job.targets.length - 1;
    final label = (job.isKubik && !isLastCubicCell)
        ? context.l10n.census_action_nextCell
        : context.l10n.census_action_completeCensus;

    return SizedBox(
      width: double.infinity,
      child: MedButton(
        label: label,
        size: MedButtonSize.lg,
        isLoading: state.isSaving,
        onPressed: _canConfirm ? () => onConfirm() : null,
      ),
    );
  }
}
