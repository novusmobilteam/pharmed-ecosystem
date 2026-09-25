// [SWREQ-CLI-MCENSUS-002] [IEC 62304 §5.5]
// Master kabin sayımının donanım yürütme fazı. Kuyruk, durdurma, hata
// kurtarma ve giriş güncellemeleri ortak mixin'lerden gelir — bu sınıf
// yalnızca sayıma özgü kaydı yapar.
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

final masterCensusExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterCensusExecutionNotifier>((ref) {
  return MasterCensusExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    completeCensus: ref.read(completeMasterCensusUseCaseProvider),
    isPerCellMiadEnabled: ref.read(isPerCellMiadEnabledProvider),
  );
});

class MasterCensusExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  MasterCensusExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required CompleteMasterCensusUseCase completeCensus,
    required this.isPerCellMiadEnabled,
  }) : _drawerSession = drawerSession,
       _completeCensus = completeCensus {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final CompleteMasterCensusUseCase _completeCensus;

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

  /// Sayımda hasEntry'ye bakılmaz: 0 da bir sonuçtur ("burada ilaç yok").
  /// Hangi satırların gideceğine mapper karar verir.
  Future<bool> _saveTarget(CabinOperationTarget target) async {
    final params = CabinOperationParamsMapper.toParamsForTarget(target);
    if (params.isEmpty) return true;

    final result = await _completeCensus(params);
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
