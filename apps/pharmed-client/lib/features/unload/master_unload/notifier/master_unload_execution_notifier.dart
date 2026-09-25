// [SWREQ-CLI-MUNLOAD-003] [IEC 62304 §5.5]
// Master kabin boşaltmasının donanım yürütme fazı. Kuyruk, durdurma, hata
// kurtarma ve giriş güncellemeleri ortak mixin'lerden gelir — bu sınıf
// yalnızca boşaltma kaydını yapar.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_session.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';

final masterUnloadExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterUnloadExecutionNotifier>((ref) {
  return MasterUnloadExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    completeUnload: ref.read(completeMasterUnloadUseCaseProvider),
  );
});

class MasterUnloadExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  MasterUnloadExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required CompleteMasterUnloadUseCase completeUnload,
  }) : _drawerSession = drawerSession,
       _completeUnload = completeUnload {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final CompleteMasterUnloadUseCase _completeUnload;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// Boşaltmada SKT girilmez (CabinOperationMode.unload.requiresMiad == false)
  /// — alan hiç çizilmediği için değeri anlamsız.
  @override
  bool get isPerCellMiadEnabled => true;

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  Future<void> start(List<CabinOperationDrawerJob> jobs) => startQueue(jobs);

  @override
  Future<void> confirmCurrent() async {
    final target = currentTarget;
    if (isStopping || target == null || !target.isValid) return;
    await confirmSingleTarget(saveTarget: _saveTarget);
  }

  Future<bool> _saveTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return true; // boşaltım girilmemiş hedef — kayıt yok, ilerle

    final result = await _completeUnload.call(CabinOperationParamsMapper.toParamsForTarget(target));
    return result.when(
      ok: (_) => true,
      error: (e) {
        setQueueFailure(CabinApiFailure(message: e.message), isQueueError: true);
        return false;
      },
    );
  }

  @override
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) =>
      locationItemsUsing(allGroups: allGroups, cabinDrawerIdOf: (job) => job.cabinDrawerId, stockIdAt: (_, _) => null);
}
