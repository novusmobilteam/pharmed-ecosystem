part of 'master_refill_view.dart';

class _FillForm extends StatelessWidget {
  const _FillForm({required this.state, required this.job, required this.notifier});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // Birim dozda 6'dan çok göz grid'e geçer ve daha geniş alan ister;
    // kübik ve kısa birim doz tek sütun kaldığından dar form daha okunaklı.
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: state.isSaving ? 0.55 : 1.0,
                child: IgnorePointer(
                  ignoring: state.isSaving,
                  child: job.isKubik
                      ? _KubikBody(state: state, notifier: notifier)
                      : _UnitDoseBody(state: state, notifier: notifier),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _FooterButton(state: state, job: job, onConfirm: notifier.confirmCurrent),
          ],
        ),
      ),
    );
  }
}

class _KubikBody extends StatelessWidget {
  const _KubikBody({required this.state, required this.notifier});

  final MasterRefillExecuting state;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    final ti = state.currentTargetIndex;
    if (target == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: RefillCellCard(
        density: MedValueCardDensity.comfortable,
        assignment: target.assignment,
        current: target.currentQuantity,
        countQuantity: target.cubicCount,
        fillingQuantity: target.cubicFilling,
        miadDate: target.cubicMiad,
        onCountChanged: (v) => notifier.onCubicCountChanged(ti, v),
        onFillingChanged: (v) => notifier.onCubicFillingChanged(ti, v),
        onMiadChanged: (d) => notifier.onCubicMiadChanged(ti, d),
      ),
    );
  }
}

class _UnitDoseBody extends ConsumerWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterRefillExecuting state;
  final MasterRefillNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();
    const ti = 0; // birim dozda job içinde tek target

    // MiadDate=0 → hücre bazlı SKT kapalı, dolum yapılan tüm gözler için
    // tek bir SKT girilir (target.singleMiad). Mapper zaten bu fallback'i
    // destekliyor: step.miadDate null ise target.singleMiad kullanılıyor
    // (bkz. RefillJobParamsMapper._targetToParams).
    final isPerCellMiadEnabled = ref.watch(isPerCellMiadEnabledProvider);

    Widget cardFor(int stepIndex) {
      final step = target.steps[stepIndex];
      return RefillCellCard(
        assignment: target.assignment,
        stepLabel: context.l10n.refill_label_cellNo(stepIndex + 1),
        current: target.assignment.toDisplayQuantity(step.countQuantity),
        countQuantity: step.countQuantity,
        fillingQuantity: step.fillingQuantity,
        miadDate: step.miadDate,
        onCountChanged: (v) => notifier.onStepCountChanged(ti, stepIndex, v),
        onFillingChanged: (v) => notifier.onStepFillingChanged(ti, stepIndex, v),
        onMiadChanged: isPerCellMiadEnabled ? (d) => notifier.onStepMiadChanged(ti, stepIndex, d) : null,
      );
    }

    final count = target.steps.length;

    Widget cellList() {
      return CabinOperationCellGrid(
        itemCount: count,
        targetItemWidth: 300,
        itemBuilder: (context, i) => cardFor(i),
        shrinkWrap: !isPerCellMiadEnabled,
        physics: isPerCellMiadEnabled ? null : const NeverScrollableScrollPhysics(),
      );
    }

    if (isPerCellMiadEnabled) {
      return cellList();
    }

    // Hücre bazlı SKT kapalı: üstte tek bir SKT girişi, altta gözler
    // (miad kartı olmadan). Hata/zorunlu vurgusu: ya en az bir gözde dolum
    // girilmişken SKT boşsa, ya da girilmiş SKT süresi geçmişse — per-cell
    // karttaki kuralla aynı.
    final singleMiadError = (target.hasFilling && target.singleMiad == null) || target.singleMiad.isExpiredMiad;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _SingleMiadHeader(
          miadDate: target.singleMiad,
          hasError: singleMiadError,
          onTap: () => _openSingleMiadPicker(context, target.singleMiad, (d) => notifier.onSingleMiadChanged(ti, d)),
        ),
        Expanded(child: cellList()),
      ],
    );
  }

  static Future<void> _openSingleMiadPicker(
    BuildContext context,
    DateTime? current,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      // Aynı çökme senaryosu: var olan singleMiad geçmişteyse initialDate'i
      // bugüne kenetle, aksi halde showDatePicker hata fırlatır.
      initialDate: current.clampedForPicker(),
      firstDate: todayDateOnly(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) onChanged(picked);
  }
}

class _SingleMiadHeader extends StatelessWidget {
  const _SingleMiadHeader({required this.miadDate, required this.hasError, required this.onTap});

  final DateTime? miadDate;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = miadDate != null;
    return MedValueCard(
      density: MedValueCardDensity.compact,
      label: context.l10n.dateField_placeholder,
      value: hasValue ? miadDate.formattedDate : context.l10n.dateField_placeholder,
      placeholder: !hasValue,
      hasError: hasError,
      trailingIcon: PhosphorIcons.calendarBlank(),
      onTap: onTap,
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.state, required this.job, required this.onConfirm});

  final MasterRefillExecuting state;
  final RefillDrawerJob job;
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
        ? context.l10n.refill_action_nextCell
        : context.l10n.refill_action_completeFilling;

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
