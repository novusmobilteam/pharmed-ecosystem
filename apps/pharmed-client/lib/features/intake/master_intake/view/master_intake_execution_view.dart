// [SWREQ-CLI-MINTAKE-006] [IEC 62304 §5.5]
// FAZ 3 — Alım kuyruğunun işlendiği panel. Kübik/birim-doz ayrımı YOK —
// ikisi de artık aynı sıralı akışla ilerliyor (tek target aç → işle →
// kapat). Ekranda her zaman SADECE aktif target'a (currentTargetIndex) ait
// hücreler gösterilir; aynı gözün detayları birden fazla stockId'ye
// bölünmüşse (FIFO split) birden fazla kart görünebilir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
import '../../intake.dart';

part 'intake_cell_card.dart';

class MasterIntakeExecutionView extends ConsumerWidget {
  const MasterIntakeExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);

    final executing = switch (state) {
      MasterIntakeExecuting e => e,
      MasterIntakeError(previousState: MasterIntakeExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

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
      openedBuilder: (_) => _IntakeForm(state: executing, job: job, notifier: notifier),
    );
  }
}

class _IntakeForm extends StatelessWidget {
  const _IntakeForm({required this.state, required this.job, required this.notifier});

  final MasterIntakeExecuting state;
  final IntakeDrawerJob job;
  final MasterIntakeNotifier notifier;

  bool get _canConfirm {
    if (job.isKubik) {
      final t = state.currentTarget;
      return t != null && t.isValid;
    }
    return job.targets.every((t) => t.isValid); // birim doz: TÜM hedefler geçerli olmalı
  }

  /// Sadece aktif target'a (ti) ait gruplar — itemBuilder(context, 0) tek
  /// çağrılır, içine bu kartların tamamını Column olarak koyuyoruz.
  Widget _activeContent(BuildContext context, int ti) {
    final groups = IntakeCellGrouper.group(job.targets);

    if (job.isKubik) {
      if (ti < 0 || ti >= groups.length) return const SizedBox.shrink();
      final group = groups[ti];
      return IntakeCellCard(
        group: group,
        targets: job.targets,
        stepLabel: context.l10n.refill_label_cellProgress(ti + 1, groups.length),
        onCountChanged: (v) => notifier.onGroupCountChanged(group, v),
      );
    }

    // Birim doz/standart — tek açılış, kaç fiziksel grup varsa hepsi birden.
    return Column(
      spacing: 8,
      children: groups
          .asMap()
          .entries
          .map(
            (e) => IntakeCellCard(
              group: e.value,
              targets: job.targets,
              stepLabel: context.l10n.refill_label_cellProgress(e.key + 1, groups.length),
              onCountChanged: (v) => notifier.onGroupCountChanged(e.value, v),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ti = state.currentTargetIndex;
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget ? context.l10n.refill_action_nextCell : context.l10n.intake_action_complete;

    return CabinExecutionGrid(
      maxWidth: 640,
      isLocked: state.isSaving,
      isKubik: true,
      itemCount: 1,
      itemBuilder: (context, _) => _activeContent(context, ti),
      header: null,
      canConfirm: _canConfirm,
      isSaving: state.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
