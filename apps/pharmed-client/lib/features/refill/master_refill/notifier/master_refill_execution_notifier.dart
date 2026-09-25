// [SWREQ-CLI-MREFILL-002] [IEC 62304 §5.5]
// Master kabin dolumunun donanım yürütme fazı. Kuyruk, durdurma, hata
// kurtarma ve giriş güncellemeleri ortak mixin'lerden gelir — bu sınıf
// yalnızca dolum kaydını yapar.
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
import '../../../settings/notifier/settings_notifier.dart';

final masterRefillExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefillExecutionNotifier>((ref) {
  return MasterRefillExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    refillCabin: ref.read(refillMasterCabinUseCaseProvider),
    isPerCellMiadEnabled: ref.read(isPerCellMiadEnabledProvider),
  );
});

class MasterRefillExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  MasterRefillExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required RefillMasterCabinUseCase refillCabin,
    required this.isPerCellMiadEnabled,
  }) : _drawerSession = drawerSession,
       _refillCabin = refillCabin {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final RefillMasterCabinUseCase _refillCabin;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// SKT modu — ekran açıldığı anın ayarı, kuyruk boyunca sabit.
  @override
  final bool isPerCellMiadEnabled;

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
    if (!target.hasEntry) return true; // dolum girilmemiş hedef — kayıt yok, ilerle

    final result = await _refillCabin(CabinOperationParamsMapper.toParamsForTarget(target));
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
