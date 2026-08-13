import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../../../settings/notifier/settings_notifier.dart';
import '../../refill.dart';

class MasterRefillExecutionView extends ConsumerWidget {
  const MasterRefillExecutionView({super.key, required this.allGroups});

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

    return CabinOperationExecutionLayout(
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
      onRequestClose: () => ref.read(masterDrawerSessionProvider.notifier).confirmClose(),
    );
  }
}

class _FillForm extends ConsumerWidget {
  const _FillForm({required this.state, required this.job, required this.notifier});

  final MasterRefillExecuting state;
  final CabinOperationDrawerJob job;
  final MasterRefillNotifier notifier;

  static const double _maxWidth = 720.0;
  static const double _stackSpacing = 8;

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
    final filling = job.isKubik ? target.cubicSecondary : step!.secondaryQuantity;
    final miad = job.isKubik ? target.cubicMiad : step!.miadDate;

    final hasEntry = (filling ?? 0) > 0;
    final miadHasError = isPerCellMiadEnabled && ((hasEntry && miad == null) || miad.isExpiredMiad);
    final unitSuffix = target.assignment.medicine?.fillingUnitLocalized(context);

    return CabinExecutionGridCard(
      assignment: target.assignment,
      current: job.isKubik ? target.currentQuantity : target.assignment.toDisplayQuantity(step!.countQuantity),
      stepLabel: job.isKubik ? null : context.l10n.refill_label_cellNo(index + 1),
      density: job.isKubik ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      hasError: miadHasError,
      fields: [
        MedQuantityValueCard(
          label: context.l10n.refill_label_countQty,
          value: count,
          suffix: unitSuffix,
          onChanged: (v) =>
              job.isKubik ? notifier.onCubicCountChanged(ti, v) : notifier.onStepCountChanged(ti, index, v),
        ),
        MedQuantityValueCard(
          label: context.l10n.refill_label_fillQty,
          value: filling,
          suffix: unitSuffix,
          onChanged: (v) =>
              job.isKubik ? notifier.onCubicFillingChanged(ti, v) : notifier.onStepFillingChanged(ti, index, v),
        ),
        if (isPerCellMiadEnabled)
          MedDateValueCard(
            label: context.l10n.refill_label_expiryDate,
            date: miad,
            hasError: miadHasError,
            onChanged: (d) =>
                job.isKubik ? notifier.onCubicMiadChanged(ti, d) : notifier.onStepMiadChanged(ti, index, d),
          ),
      ],
    );
  }

  Widget _singleMiadHeader(BuildContext context, CabinOperationTarget target, int ti) {
    final singleMiad = target.singleMiad;
    final hasError = (target.hasEntry && singleMiad == null) || singleMiad.isExpiredMiad;

    return MedDateValueCard(
      label: context.l10n.refill_label_expiryDate,
      date: singleMiad,
      hasError: hasError,
      onChanged: (d) => notifier.onSingleMiadChanged(ti, d),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = state.currentTarget;
    // Artık kübik/birim doz farkı gözetmeksizin — currentTargetIndex her iki
    // durumda da job.targets içindeki gerçek aktif hedefi gösterir (bkz.
    // notifier: birim dozda birden fazla ilaç varsa her biri kendi
    // open→confirmClose döngüsünü yaşar, currentTargetIndex buna göre ilerler).
    final ti = state.currentTargetIndex;

    // Kübikte tek-SKT fallback'i hiç yok — her zaman per-cell.
    final isPerCellMiadEnabled = job.isKubik || ref.watch(isPerCellMiadEnabledProvider);

    final itemCount = job.isKubik ? 1 : (target?.steps.length ?? 0);

    // Job'daki son hedefteyiz mi — kübikte "son lid", birim dozda "son
    // (fiziksel) ilaç/port" anlamına gelir; ikisi de aynı karşılaştırma.
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.refill_action_nextCell
        : context.l10n.refill_action_completeFilling;

    Widget content;

    if (target == null) {
      content = const SizedBox.shrink();
    } else if (job.isKubik) {
      content = SingleChildScrollView(child: _cellCard(context, ref, target, 0, ti, isPerCellMiadEnabled));
    } else {
      // Fiziksel çekmecenin ÜSTTEN GÖRÜNÜMÜ: en yüksek göz numarası EN
      // ÜSTTE, göz 1 EN ALTTA render edilir — sadece görsel sıra ters
      // çevrilir, _cellCard'a giden [index] her zaman gerçek (0-tabanlı)
      // step index'idir, callback'ler dokunulmadan doğru hedefi alır.
      final stack = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = itemCount - 1; i >= 0; i--) ...[
            _cellCard(context, ref, target, i, ti, isPerCellMiadEnabled),
            if (i > 0) const SizedBox(height: _stackSpacing),
          ],
        ],
      );

      content = !isPerCellMiadEnabled
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _singleMiadHeader(context, target, ti),
                Expanded(child: SingleChildScrollView(child: stack)),
              ],
            )
          : SingleChildScrollView(child: stack);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: state.isSaving ? 0.55 : 1.0,
                child: IgnorePointer(ignoring: state.isSaving, child: content),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MedButton(
                label: confirmLabel,
                size: MedButtonSize.lg,
                isLoading: state.isSaving,
                onPressed: _canConfirm ? () => notifier.confirmCurrent() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
