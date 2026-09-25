// [SWREQ-CLI-MDESTRUCTION-002] [IEC 62304 §5.5]
// Master kabin imhasının donanım yürütme fazı. Kayıt CabinStock.id bazlıdır
// (DestructionParamsMapper) — donanım adresi değil.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/hardware/cabin/master_drawer/master_drawer_session.dart';
import '../../../core/hardware/hardware.dart';
import '../../../core/mixins/mixins.dart';
import '../../../core/providers/providers.dart';
import '../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';

final masterDestructionExecutionNotifierProvider =
    ChangeNotifierProvider.autoDispose<MasterDestructionExecutionNotifier>((ref) {
      return MasterDestructionExecutionNotifier(
        drawerSession: ref.read(drawerExecutionSessionProvider),
        completeDispose: ref.read(masterDisposeMaterialUseCaseProvider),
      );
    });

class MasterDestructionExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  MasterDestructionExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required MasterDisposeMaterialUseCase completeDispose,
  }) : _drawerSession = drawerSession,
       _completeDispose = completeDispose {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final MasterDisposeMaterialUseCase _completeDispose;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// İmhada SKT girilmez (CabinOperationMode.destruction.requiresMiad == false)
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
    if (!target.hasEntry) return true; // imha miktarı girilmemiş — bu hedefte imha yok

    final params = DestructionParamsMapper.toParamsForTarget(target);

    // Miktar girildi ama stok kaydı çözülemedi — SESSİZCE geçmek, fiziksel
    // olarak çıkarılan ilacın sistemde kalmasına yol açar. Kuyruk hatası.
    if (params.isEmpty) {
      MedLogger.warn(
        unit: 'MasterDestruction',
        swreq: 'SWREQ-CLI-MDESTRUCTION-002',
        message: 'İmha miktarı girilen hedefin stok kaydı çözülemedi',
        context: {'assignmentId': target.assignment.id},
      );
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets), isQueueError: true);
      return false;
    }

    final result = await _completeDispose(params);
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
