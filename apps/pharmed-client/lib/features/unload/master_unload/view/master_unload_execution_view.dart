// execution/master_unload_execution_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_notifier.dart';
import '../notifier/master_unload_state.dart';

class MasterUnloadExecutionView extends ConsumerWidget {
  const MasterUnloadExecutionView({super.key, required this.allGroups});

  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterUnloadNotifierProvider);

    final executing = switch (state) {
      MasterUnloadExecuting e => e,
      MasterUnloadError(previousState: MasterUnloadExecuting e) => e,
      _ => null,
    };
    if (executing == null) return const SizedBox.shrink();

    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    final notifier = ref.read(masterUnloadNotifierProvider.notifier);

    return CabinOperationExecutionLayout(
      progressLabel: context.l10n.unload_label_queueProgress(executing.completedJobs + 1, executing.totalJobs),
      progress: executing.progress,
      onStopConfirmed: notifier.stopQueue,
      stopLabel: context.l10n.unload_action_stop,
      stopConfirmTitle: context.l10n.unload_stop_confirmTitle,
      stopConfirmMessage: context.l10n.unload_stop_confirmMessage,
      stopConfirmYesLabel: context.l10n.unload_stop_confirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: executing.currentIndex,
      openedBuilder: (_) => _UnloadForm(state: executing, job: job, notifier: notifier),
    );
  }
}

class _UnloadForm extends StatelessWidget {
  const _UnloadForm({required this.state, required this.job, required this.notifier});

  final MasterUnloadExecuting state;
  final CabinOperationDrawerJob job;
  final MasterUnloadNotifier notifier;

  bool get _canConfirm {
    final t = state.currentTarget;
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
          onChanged: (v) => notifier.onStepCountChanged(ti, index, v),
        ),
        MedQuantityValueCard(
          label: context.l10n.unload_label_unloadQty,
          value: step.secondaryQuantity,
          onChanged: (v) => notifier.onStepUnloadChanged(ti, index, v),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = state.currentTarget;
    if (target == null) return const SizedBox.shrink();

    final ti = state.currentTargetIndex;
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget ? context.l10n.unload_action_nextCell : context.l10n.unload_action_complete;

    if (job.isKubik) {
      return CabinExecutionGrid(
        maxWidth: 420,
        isLocked: state.isSaving,
        isKubik: true,
        itemCount: 1,
        itemBuilder: (context, _) => _kubikCard(context, target),
        header: null,
        canConfirm: _canConfirm,
        isSaving: state.isSaving,
        confirmLabel: confirmLabel,
        onConfirm: notifier.confirmCurrent,
      );
    }

    return CabinExecutionGrid(
      maxWidth: target.numberOfSteps > 6 ? 1100 : 640,
      isLocked: state.isSaving,
      isKubik: false,
      itemCount: target.steps.length,
      itemBuilder: (context, index) => _stepCard(context, target, ti, index),
      header: null,
      canConfirm: _canConfirm,
      isSaving: state.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
