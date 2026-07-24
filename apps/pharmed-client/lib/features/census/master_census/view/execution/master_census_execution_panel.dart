// [SWREQ-CLI-MCENSUS-008] [IEC 62304 §5.5]
// Sayım kuyruğunun işlendiği tam-ekran yürütme akışı — MasterCabinExecutionScaffold
// (dolum/alım ile ORTAK iskelet) üzerine kurulu. Fark sadece içerik:
// CensusCellCard (sayım+miad, dolum yok) ve tek-SKT toggle'ı hiç yok (sayımda
// SKT her zaman per-cell). Çekmece durum mesajları (açılıyor/kapatın vb.)
// artık ekrandan bağımsız — bkz. MasterCabinExecutionScaffold.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../../widgets/widgets.dart';
import '../../notifier/master_census_notifier.dart';
import '../../notifier/master_census_state.dart';

class MasterCensusExecutionPanel extends ConsumerWidget {
  const MasterCensusExecutionPanel({super.key, required this.allGroups});

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

    return MasterCabinExecutionScaffold(
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

class _CensusForm extends StatelessWidget {
  const _CensusForm({required this.state, required this.job, required this.notifier});

  final MasterCensusExecuting state;
  final CensusDrawerJob job;
  final MasterCensusNotifier notifier;

  bool get _canConfirm {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.canComplete;
  }

  @override
  Widget build(BuildContext context) {
    final isWideGrid = !job.isKubik && job.targets.isNotEmpty && job.targets.first.steps.length > 6;
    final maxWidth = isWideGrid ? 1100.0 : 640.0;

    final target = state.currentTarget;
    final ti = job.isKubik ? state.currentTargetIndex : 0;

    final entries = job.isKubik
        ? (target == null
              ? const <CabinCellEntry>[]
              : [
                  CabinCellEntry(
                    assignment: target.assignment,
                    current: target.currentQuantity,
                    countQuantity: target.cubicCount,
                    miadDate: target.cubicMiad,
                  ),
                ])
        : (target?.steps
                  .map(
                    (step) => CabinCellEntry(
                      assignment: target.assignment,
                      current: target.assignment.toDisplayQuantity(step.countQuantity),
                      countQuantity: step.countQuantity,
                      miadDate: step.miadDate,
                    ),
                  )
                  .toList() ??
              const <CabinCellEntry>[]);

    final isLastCubicCell = job.isKubik && state.currentTargetIndex >= job.targets.length - 1;
    final confirmLabel = (job.isKubik && !isLastCubicCell)
        ? context.l10n.census_action_nextCell
        : context.l10n.census_action_completeCensus;

    return CabinCellOperationForm(
      maxWidth: maxWidth,
      isLocked: state.isSaving,
      isKubik: job.isKubik,
      entries: entries,
      onCountChanged: (index, v) =>
          job.isKubik ? notifier.onCubicCountChanged(ti, v) : notifier.onStepCountChanged(ti, index, v),
      // showFilling verilmiyor → false (varsayılan) — sayımda dolum alanı yok.
      isPerCellMiadEnabled: true, // sayımda SKT her zaman per-cell.
      onMiadChanged: (index, d) =>
          job.isKubik ? notifier.onCubicMiadChanged(ti, d) : notifier.onStepMiadChanged(ti, index, d),
      stepLabelBuilder: (index) => context.l10n.refill_label_cellNo(index + 1),
      canConfirm: _canConfirm,
      isSaving: state.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
