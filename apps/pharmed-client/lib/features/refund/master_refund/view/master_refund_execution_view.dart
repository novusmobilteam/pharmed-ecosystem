part of 'master_refund_view.dart';

class MasterRefundExecutionView extends ConsumerWidget {
  const MasterRefundExecutionView({super.key, required this.cabinDataByCabinId});

  final Map<int, CabinVisualizerData> cabinDataByCabinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.watch(masterRefundExecutionNotifierProvider);

    if (!execution.isExecuting) return const SizedBox.shrink();

    final job = execution.currentJob;
    if (job == null) return const SizedBox.shrink();

    final cabinId = job.cabinId;
    final allGroups = cabinId != null
        ? (cabinDataByCabinId[cabinId]?.groups ?? const <DrawerGroup>[])
        : const <DrawerGroup>[];

    return CabinOperationExecutionLayout(
      stage: execution.drawerStage,
      progressLabel: context.l10n.refund_label_progress(execution.currentIndex + 1, execution.jobs.length),
      progress: execution.progress,
      onStopConfirmed: execution.abortAfterError,
      stopLabel: context.l10n.refund_action_stop,
      stopConfirmTitle: context.l10n.refund_action_stopConfirmTitle,
      stopConfirmMessage: context.l10n.refund_action_stopConfirmMessage,
      stopConfirmYesLabel: context.l10n.refund_action_stopConfirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: execution.toLocationItems(allGroups),
      activeIndex: execution.currentIndex,
      isLastJob: execution.currentIndex >= execution.jobs.length - 1,
      openedBuilder: (_) => _RefundConfirmForm(execution: execution),
    );
  }
}

class _RefundConfirmForm extends StatelessWidget {
  const _RefundConfirmForm({required this.execution});

  final MasterRefundExecutionNotifier execution;

  bool get _canConfirm => execution.currentTarget != null;

  Widget _cellCard(BuildContext context, RefundDrawerJob job, int ti) {
    if (ti < 0 || ti >= job.targets.length) return const SizedBox.shrink();
    final target = job.targets[ti];

    final RefundCellGroup? myGroup = job.isReturnDrawer
        ? null
        : RefundCellGrouper.group(job.targets).firstWhereOrNull((g) => g.targetIndexes.contains(ti));

    final representative = myGroup != null ? job.targets[myGroup.targetIndexes.first] : target;
    final totalQuantity = myGroup != null
        ? myGroup.totalQuantity(job.targets)
        : (target.item.returnQuantity ?? target.item.appliedQuantity);

    final item = representative.item;
    final unit = item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    return CabinExecutionGridCard(
      assignment: representative.assignment,
      current: representative.assignment.toDisplayQuantity(representative.assignment.totalQuantity),
      density: (job.isKubik || job.isReturnDrawer) ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      fields: [
        MedValueCard(
          label: context.l10n.refund_label_quantity,
          value: totalQuantity.toDouble().formatFractional,
          suffix: unit,
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = execution.currentJob;
    if (job == null) return const SizedBox.shrink();

    if (job.isReturnDrawer) {
      return CabinExecutionGrid(
        maxWidth: 640,
        isLocked: execution.isSaving,
        isKubik: false,
        itemCount: job.targets.length,
        itemBuilder: (context, i) => _cellCard(context, job, i),
        header: null,
        canConfirm: job.targets.isNotEmpty,
        isSaving: execution.isSaving,
        confirmLabel: context.l10n.refund_action_completeRefund,
        onConfirm: execution.confirmCurrent,
      );
    }

    final ti = execution.currentTargetIndex;
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.refund_action_nextCell
        : context.l10n.refund_action_completeRefund;

    return CabinExecutionGrid(
      maxWidth: 640,
      isLocked: execution.isSaving,
      isKubik: true,
      itemCount: 1,
      itemBuilder: (context, _) => _cellCard(context, job, ti),
      header: null,
      canConfirm: _canConfirm,
      isSaving: execution.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: execution.confirmCurrent,
    );
  }
}
