import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_client/core/mixins/master_drawer_execution_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/cabin_drawer_queue_mixin.dart';
import '../../../../core/providers/providers.dart';

final masterRefundExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefundExecutionNotifier>((ref) {
  return MasterRefundExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    completeRefund: ref.read(completeRefundUseCaseProvider),
  );
});

class MasterRefundExecutionNotifier extends ChangeNotifier
    with MasterDrawerExecutionMixin, CabinDrawerQueueMixin<RefundDrawerJob, RefundTarget> {
  final IMasterDrawerSession _drawerSession;
  final CompleteRefundUseCase _completeRefund;

  MasterRefundExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required CompleteRefundUseCase completeRefund,
  }) : _drawerSession = drawerSession,
       _completeRefund = completeRefund {
    attachDrawerSession();
  }

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  Future<void> start(List<RefundTarget> targets) => startQueue(RefundQueueBuilder.build(targets));

  Future<void> confirmCurrent() async {
    final job = currentJob;
    if (job == null || isSaving) return;

    if (job.isReturnDrawer) {
      isSaving = true;
      for (final target in job.targets) {
        final ok = await _completeTarget(target);
        if (!ok) return;
      }
      isSaving = false;
      confirmDrawerClose();
      return;
    }

    final target = currentTarget;
    if (target == null) return;

    if (job.isKubik) {
      isSaving = true;
      final ok = await _completeCurrentCellTargets();
      if (!ok) return;
      await _advanceWithinOpenDrawer();
    } else {
      isSaving = true;
      final ok = await _completeTarget(target);
      if (!ok) return;
      isSaving = false;
      confirmDrawerClose();
    }
  }

  Future<bool> _completeCurrentCellTargets() async {
    final job = currentJob;
    if (job == null) return false;

    var index = currentTargetIndex;
    final cellId = job.targets[index].assignment.drawerUnit?.id;

    while (true) {
      final ok = await _completeTarget(job.targets[index]);
      if (!ok) return false;

      final nextIndex = index + 1;
      final sameCell = nextIndex < job.targets.length && job.targets[nextIndex].assignment.drawerUnit?.id == cellId;
      if (!sameCell) break;

      index = nextIndex;
      _setCurrentTargetIndex(index);
    }

    return true;
  }

  /// Aynı gözdeyken ardışık target ilerletmek Katman 2'nin normal
  /// _openJobAt/_advanceAfterClose akışının DIŞINDA — donanıma hiç yeni
  /// komut gitmiyor, sadece hangi target'ın "aktif" göründüğü değişiyor.
  /// Bu yüzden CabinDrawerQueueMixin'e `currentTargetIndex` için protected
  /// bir setter eklememiz gerekiyor (bkz. not).
  void _setCurrentTargetIndex(int index) => setCurrentTargetIndexForSameCell(index);

  Future<void> _advanceWithinOpenDrawer() async {
    final job = currentJob;
    if (job == null) return;

    final nextIndex = currentTargetIndex + 1;
    if (nextIndex < job.targets.length) {
      final currentCellId = job.targets[currentTargetIndex].assignment.drawerUnit?.id;
      final nextCellId = job.targets[nextIndex].assignment.drawerUnit?.id;
      final sameCellAsCurrent = currentCellId != null && currentCellId == nextCellId;

      _setCurrentTargetIndex(nextIndex);
      isSaving = false;

      if (job.isKubik && !sameCellAsCurrent) {
        await openCubicLid(job.targets[nextIndex].assignment);
      }
    } else {
      isSaving = false;
      confirmDrawerClose();
    }
  }

  Future<bool> _completeTarget(RefundTarget target) async {
    final item = target.item;
    final result = await _completeRefund.call(
      CompleteRefundParams(
        type: item.returnType!,
        id: item.id,
        quantity: (item.returnQuantity ?? item.appliedQuantity).toDouble(),
        cabinDrawerDetailId: item.source.stock?.cabinDrawerDetailId,
      ),
    );

    return result.when(
      ok: (_) => true,
      error: (e) {
        setQueueFailure(CabinApiFailure(message: e.message));
        return false;
      },
    );
  }

  @override
  void onLidRejected(MasterDrawerFailure failure, String? detail) {
    MedLogger.warn(
      unit: 'MasterRefundExecution',
      swreq: 'SWREQ-CLI-MREFUND-EXEC-001',
      message: 'Kübik kapak açma reddedildi',
      context: {'failure': failure.name, 'detail': detail},
    );
  }

  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => locationItemsUsing(
    allGroups: allGroups,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    stockIdAt: (job, i) => job.targets[i].item.source.stock?.id,
    isReturnDrawerTargetOf: (job) => job.isReturnDrawer,
  );
}
