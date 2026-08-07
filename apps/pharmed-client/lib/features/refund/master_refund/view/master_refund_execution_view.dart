import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/master_refund_notifier.dart';
import '../notifier/master_refund_state.dart';

class MasterRefundExecutionView extends ConsumerWidget {
  const MasterRefundExecutionView({super.key, required this.allGroups});
  final List<DrawerGroup> allGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefundNotifierProvider);
    final notifier = ref.read(masterRefundNotifierProvider.notifier);

    final executing = switch (state) {
      MasterRefundExecuting s => s,
      MasterRefundError(previousState: MasterRefundExecuting s) => s,
      _ => null,
    };

    if (executing == null) return const SizedBox.shrink();

    return CabinOperationExecutionLayout(
      progressLabel: context.l10n.refund_label_progress(executing.currentIndex + 1, executing.jobs.length),
      progress: executing.progress,
      onStopConfirmed: notifier.abortAfterError,
      stopLabel: context.l10n.refund_action_stop,
      stopConfirmTitle: context.l10n.refund_action_stopConfirmTitle,
      stopConfirmMessage: context.l10n.refund_action_stopConfirmMessage,
      stopConfirmYesLabel: context.l10n.refund_action_stopConfirmYes,
      cancelLabel: context.l10n.common_cancelButton,
      locationItems: executing.toLocationItems(allGroups),
      activeIndex: executing.currentIndex,
      openedBuilder: (_) => _RefundConfirmForm(executing: executing, notifier: notifier),
    );
  }
}

class _RefundConfirmForm extends StatelessWidget {
  const _RefundConfirmForm({required this.executing, required this.notifier});

  final MasterRefundExecuting executing;
  final MasterRefundNotifier notifier;

  bool get _canConfirm => executing.currentTarget != null;

  /// Aktif target'ı (currentTargetIndex) içeren tek grup — birden fazla
  /// target aynı fiziksel göze düşüyorsa (RefundCellGrouper) toplam miktar
  /// tek kartta gösterilir.
  Widget _cellCard(BuildContext context, RefundDrawerJob job, int ti) {
    if (ti < 0 || ti >= job.targets.length) return const SizedBox.shrink();
    final target = job.targets[ti];

    // RefundCellGrouper SADECE toOrigin hedefleri için anlamlıdır (bkz.
    // grouper dokümantasyonu). İade çekmecesi (toDrawer) job'larında her
    // target kendi ayrı kartında gösterilir, gruplama YAPILMAZ.
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
    final job = executing.currentJob;
    if (job == null) return const SizedBox.shrink();

    if (job.isReturnDrawer) {
      return CabinExecutionGrid(
        maxWidth: 640,
        isLocked: executing.isSaving,
        isKubik: false,
        itemCount: job.targets.length,
        itemBuilder: (context, i) => _cellCard(context, job, i),
        header: null,
        canConfirm: job.targets.isNotEmpty,
        isSaving: executing.isSaving,
        confirmLabel: context.l10n.refund_action_completeRefund,
        onConfirm: notifier.confirmCurrent,
      );
    }

    final ti = executing.currentTargetIndex;
    final isLastTarget = ti >= job.targets.length - 1;
    final confirmLabel = !isLastTarget
        ? context.l10n.refund_action_nextCell
        : context.l10n.refund_action_completeRefund;

    return CabinExecutionGrid(
      maxWidth: 640,
      isLocked: executing.isSaving,
      isKubik: true,
      itemCount: 1,
      itemBuilder: (context, _) => _cellCard(context, job, ti),
      header: null,
      canConfirm: _canConfirm,
      isSaving: executing.isSaving,
      confirmLabel: confirmLabel,
      onConfirm: notifier.confirmCurrent,
    );
  }
}
