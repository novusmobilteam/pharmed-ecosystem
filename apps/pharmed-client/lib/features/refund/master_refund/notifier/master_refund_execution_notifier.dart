import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/mixins.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';

// [SWREQ-CLI-MREFUND-EXEC-001] [IEC 62304 §5.5]
// Master kabin iadesinin donanım yürütme fazı. Kuyruk, durdurma, hata
// kurtarma ve kapak akışı ortak mixin'lerden gelir. İadeye özgü:
//   - Target'lar fiziksel birim bazında gruplanır (RefundJobMapper); bir
//     target birden fazla iade kalemi taşıyabilir.
//   - Kayıt target girdisinden DEĞİL, kalemlerden yapılır: her kalem için
//     ayrı CompleteRefund isteği, kalemin kendi miktarıyla.
//   - Tamamlanan kalemler işaretlenir — aynı target'ın kaydı tekrar
//     tetiklense bile (ör. kısmi başarıdan sonra) bir kalem İKİNCİ KEZ
//     iade edilmez.
//   - Hedef "Tamamla" butonuyla YA DA fiziksel kapanışla tamamlanır
//     (completesOnPhysicalClose) — alımla aynı davranış.
//
// Sınıf: Class B

final masterRefundExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterRefundExecutionNotifier>((ref) {
  return MasterRefundExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    completeRefund: ref.read(completeRefundUseCaseProvider),
    recordingCoordinator: ref.read(operationRecordingCoordinatorProvider),
  );
});

class MasterRefundExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin,
        CabinOperationRecordingMixin<CabinOperationDrawerJob, CabinOperationTarget>
    implements CabinOperationExecutionController {
  MasterRefundExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required OperationRecordingCoordinator recordingCoordinator,
    required CompleteRefundUseCase completeRefund,
  }) : _drawerSession = drawerSession,
       _recordingCoordinator = recordingCoordinator,
       _completeRefund = completeRefund {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final OperationRecordingCoordinator _recordingCoordinator;
  final CompleteRefundUseCase _completeRefund;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  /// İadede miktar seçim ekranında belirlenir — kapanışta otomatik kayıt
  /// güvenlidir (alımla aynı).
  @override
  bool get completesOnPhysicalClose => true;

  /// İadede SKT girilmez (CabinOperationMode.refund.requiresMiad == false)
  /// — alan hiç çizilmediği için değeri anlamsız.
  @override
  bool get isPerCellMiadEnabled => true;

  @override
  OperationRecordingCoordinator get recordingCoordinator => _recordingCoordinator;

  @override
  RecordedOperationType get recordedOperationType => RecordedOperationType.refund;

  /// target.sourceId → o target'ta kaydedilecek kalemler.
  Map<int, List<RefundableItem>> _itemsBySourceId = const {};

  /// Bu kuyrukta başarıyla iade edilmiş kalemler (RefundableItem.id).
  Set<int> _completedItemIds = {};

  List<RefundableItem> itemsOf(CabinOperationTarget target) {
    final id = target.sourceId;
    return id == null ? const [] : (_itemsBySourceId[id] ?? const []);
  }

  double refundQuantityOf(CabinOperationTarget target) =>
      itemsOf(target).fold(0, (sum, item) => sum + RefundJobMapper.quantityOf(item));

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  /// Kuyruğu başlatır. Fiziksel çekmecesi çözülemeyen kalem varsa kuyruk
  /// HİÇ başlatılmaz ve o kalemler döner — kısmi bir iade listesiyle
  /// yürütmeye geçilmez.
  Future<List<RefundableItem>> start(List<RefundableItem> items) async {
    final plan = RefundJobMapper.build(items);

    if (plan.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterRefundExecution',
        swreq: 'SWREQ-CLI-MREFUND-EXEC-001',
        message: 'İade kuyruğu başlatılmadı — fiziksel çekmecesi çözülemeyen kalem var',
        context: {
          'skippedItemIds': [for (final i in plan.skipped) i.id],
        },
      );
      return plan.skipped;
    }

    _itemsBySourceId = plan.itemsBySourceId;
    _completedItemIds = {};
    await startQueue(plan.jobs);
    return const [];
  }

  /// "Tamamla" yolu — kayıt hemen atılır, tamamlama fiziksel kapanışta.
  @override
  Future<void> confirmCurrent() async {
    if (isStopping || currentTarget == null) return;
    await confirmSingleTarget(saveTarget: _saveTarget);
  }

  /// "Tamamla"ya basılmadan kapak/çekmece kapandı — kayıt burada atılır.
  @override
  Future<bool> saveTargetOnPhysicalClose(CabinOperationTarget target) => _saveTarget(target);

  // ── Kayıt ─────────────────────────────────────────────────────────────

  Future<bool> _saveTarget(CabinOperationTarget target) async {
    final items = itemsOf(target);
    if (items.isEmpty) {
      // Kalemi olmayan target kuyruğa girmemeliydi — sessizce geçmek iadeyi
      // kaydetmeden çekmeceyi kapatırdı.
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets), isQueueError: true);
      return false;
    }

    for (final item in items) {
      if (_completedItemIds.contains(item.id)) continue;

      final ok = await _completeItem(item);
      if (!ok) return false;
      _completedItemIds.add(item.id);
    }
    return true;
  }

  Future<bool> _completeItem(RefundableItem item) async {
    final returnType = item.returnType;
    if (returnType == null) {
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets), isQueueError: true);
      return false;
    }

    final result = await _completeRefund.call(
      CompleteRefundParams(
        type: returnType,
        id: item.id,
        quantity: RefundJobMapper.quantityOf(item),
        cabinDrawerDetailId: item.source.stock?.cabinDrawerDetailId,
      ),
    );

    return result.when(
      ok: (_) => true,
      error: (e) {
        // Eskiden isQueueError verilmiyordu — yalnızca snackbar çıkıyor,
        // kullanıcıya devam/sonlandır seçeneği sunulmuyordu.
        setQueueFailure(CabinApiFailure(message: e.message), isQueueError: true);
        return false;
      },
    );
  }

  // ── Konum rehberi ─────────────────────────────────────────────────────

  @override
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => locationItemsUsing(
    allGroups: allGroups,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    // İade çekmecesine giden kalemin kaynak gözü bu çekmecede değil —
    // vurgulanacak yer iade bölmesinin kendisi (isReturnDrawerTargetOf).
    stockIdAt: (job, i) => job.isReturnDrawer ? null : itemsOf(job.targets[i]).firstOrNull?.source.stock?.id,
    stockIdsAt: (job, i) =>
        job.isReturnDrawer ? const [] : [for (final item in itemsOf(job.targets[i])) ?item.source.stock?.id],
    isReturnDrawerTargetOf: (job) => job.isReturnDrawer,
  );
}
