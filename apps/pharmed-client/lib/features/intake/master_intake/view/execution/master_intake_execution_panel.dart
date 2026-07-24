// [SWREQ-CLI-MINTAKE-006] [IEC 62304 §5.5]
// FAZ 3 — Alım kuyruğunun işlendiği panel.
//
// master-cabin-operations §5'teki execution panel deseni (dolum/sayımla
// BİREBİR AYNI iskelet): CabinOperationTopStrip (ilerleme+dur) →
// CabinOperationBody (sol CabinLocationGuide + sağ form/bekleme) →
// CabinOperationFillArea (form + footer).
//
// Form içeriği "dolum" değil "sayım"dır:
//   - Kübik: yalnızca o an açık olan TEK gözün sayım formu (lid-by-lid).
//   - Birim doz/standart: çekmecenin tüm hedefleri tek formda.
//
// CountType davranışı:
//   - noCount: sayım girişi gösterilmez, yalnızca alınan miktar; doğrudan onay.
//   - normalCount: mevcut stok dolu gelir, kullanıcı düzeltir.
//   - blindCount: boş gelir, kullanıcı girer.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../../widgets/widgets.dart';
import '../../../intake.dart';

part 'intake_cell_card.dart';

class MasterIntakeExecutionPanel extends ConsumerWidget {
  const MasterIntakeExecutionPanel({super.key, required this.allGroups});

  /// CabinVisualizerData.groups — tüm kabin çekmeceleri, notInQueue için lazım.
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

    return MasterCabinExecutionScaffold(
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
    return job.canComplete;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: job.isKubik ? 420 : 640),
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
            _FormFooter(
              canConfirm: _canConfirm,
              isSaving: state.isSaving,
              isKubik: job.isKubik,
              isLastCubicCell: job.isKubik && state.currentTargetIndex >= job.targets.length - 1,
              onConfirm: notifier.confirmCurrent,
            ),
          ],
        ),
      ),
    );
  }
}

class _KubikBody extends StatelessWidget {
  const _KubikBody({required this.state, required this.notifier});

  final MasterIntakeExecuting state;
  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final job = state.currentJob;
    if (job == null) return const SizedBox.shrink();

    final groups = IntakeCellGrouper.group(job.targets);
    final ti = state.currentTargetIndex;
    // Kübikte lid-by-lid akış: o an açık gözün target'ına ait grupları göster.
    final activeGroups = groups.where((g) => g.refs.any((r) => r.$1 == ti)).toList();
    if (activeGroups.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        spacing: 8,
        children: activeGroups
            .map(
              (group) => IntakeCellCard(
                group: group,
                targets: job.targets,
                stepLabel: context.l10n.refill_label_cellProgress(ti + 1, job.targets.length),
                onCountChanged: (v) => notifier.onGroupCountChanged(group, v),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _UnitDoseBody extends StatelessWidget {
  const _UnitDoseBody({required this.state, required this.notifier});

  final MasterIntakeExecuting state;
  final MasterIntakeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final job = state.currentJob;
    if (job == null) return const SizedBox.shrink();

    final groups = IntakeCellGrouper.group(job.targets);

    return ListView.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final group = groups[index];
        return IntakeCellCard(
          group: group,
          targets: job.targets,
          stepLabel: '${index + 1}',
          onCountChanged: (v) => notifier.onGroupCountChanged(group, v),
        );
      },
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.canConfirm,
    required this.isSaving,
    required this.isKubik,
    required this.isLastCubicCell,
    required this.onConfirm,
  });

  final bool canConfirm;
  final bool isSaving;
  final bool isKubik;
  final bool isLastCubicCell;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final label = (isKubik && !isLastCubicCell)
        ? context.l10n.refill_action_nextCell
        : context.l10n.intake_action_complete;
    final hint = (isKubik && !isLastCubicCell)
        ? context.l10n.intake_hint_nextCellOpens
        : context.l10n.intake_hint_confirmCloses;

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Text(hint, style: MedTextStyles.bodySm(color: MedColors.text3)),
        ),
        MedButton(label: label, isLoading: isSaving, onPressed: canConfirm ? onConfirm : null),
      ],
    );
  }
}
