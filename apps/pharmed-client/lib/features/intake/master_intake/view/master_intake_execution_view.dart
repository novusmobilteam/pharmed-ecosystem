import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
import '../../intake.dart';

part 'intake_cell_card.dart';

class MasterIntakeExecutionView extends ConsumerWidget {
  const MasterIntakeExecutionView({super.key, required this.cabinDataByCabinId});

  final Map<int, CabinVisualizerData> cabinDataByCabinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    final executing = switch (state) {
      MasterIntakeExecuting e => e,
      MasterIntakeError(previousState: MasterIntakeExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    // Şu an işlenen job'ın hedef kabini — her job farklı fiziksel kabine ait
    // olabilir (bkz. IntakeQueueBuilder.build → MedicineAssignment.drawerUnit
    // ?.drawerSlot?.cabinId), bu yüzden allGroups SABİT değil, currentCabinId
    // değiştikçe yeniden çözülür.
    final cabinId = executing.currentCabinId;
    final allGroups = cabinId != null
        ? (cabinDataByCabinId[cabinId]?.groups ?? const <DrawerGroup>[])
        : const <DrawerGroup>[];

    return CabinOperationExecutionLayout(
      progressLabel: context.l10n.intake_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
      progress: executing.progress,
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.intake_action_stop,
      stopConfirmTitle: context.l10n.intake_stop_confirmTitle,
      stopConfirmMessage: context.l10n.intake_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.intake_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: executing.currentIndex,
      isLastJob: executing.currentIndex >= executing.jobs.length - 1,
      openedBuilder: (_) => _IntakeForm(state: executing, job: job, notifier: notifier),
    );
  }
}

class _IntakeForm extends StatelessWidget {
  const _IntakeForm({required this.state, required this.job, required this.notifier});

  final MasterIntakeExecuting state;
  final IntakeDrawerJob job;
  final MasterIntakeNotifier notifier;

  static const double _maxWidth = 720.0;

  bool get _canConfirm {
    final steps = IntakeCellGrouper.group(job.targets);
    final ti = state.currentTargetIndex;
    if (ti < 0 || ti >= steps.length) return false;

    final step = steps[ti];
    return step.refs.every((ref) => job.targets[ref.$1].isValid);
  }

  /// Artık kübik/birim doz farkı YOK - ikisi de aktif STEP'i (currentTargetIndex)
  /// tek kart olarak gösterir. Birim dozda farklı ilaçlar (farklı portlar)
  /// artık ASLA aynı ekranda birlikte gösterilmez - sırayla, port kapanınca
  /// bir sonraki açılır (2026 düzeltmesi).
  Widget _activeContent(BuildContext context, int stepIndex) {
    final steps = IntakeCellGrouper.group(job.targets);
    if (stepIndex < 0 || stepIndex >= steps.length) return const SizedBox.shrink();
    final step = steps[stepIndex];
    return IntakeCellCard(
      group: step,
      targets: job.targets,
      stepLabel: context.l10n.refill_label_cellProgress(stepIndex + 1, steps.length),
      onCountChanged: (v) => notifier.onGroupCountChanged(step, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ti = state.currentTargetIndex;
    final steps = IntakeCellGrouper.group(job.targets);
    final isLastTarget = ti >= steps.length - 1;
    final confirmLabel = !isLastTarget ? context.l10n.refill_action_nextCell : context.l10n.intake_action_complete;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: state.isSaving ? 0.55 : 1.0,
                child: IgnorePointer(
                  ignoring: state.isSaving,
                  child: SingleChildScrollView(child: _activeContent(context, ti)),
                ),
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
