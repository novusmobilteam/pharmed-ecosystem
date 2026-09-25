// [SWREQ-CLI-RFLIST-001] [IEC 62304 §5.5]
// Dolum listesi donanım yürütme fazı. Liste/detay/seçim mantığı
// RefillListSelectionNotifier'da — bu sınıf yalnızca hazır job listesini
// kuyruğa alıp fiziksel çekmeceyi yönetir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_session.dart';
import 'package:pharmed_client/core/mixins/mixins.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/hardware/hardware.dart';
import '../../../core/providers/providers.dart';
import '../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../settings/notifier/settings_notifier.dart';

final refillListExecutionNotifierProvider = ChangeNotifierProvider.autoDispose<RefillListExecutionNotifier>((ref) {
  return RefillListExecutionNotifier(
    drawerSession: ref.read(drawerExecutionSessionProvider),
    refillCabin: ref.read(refillListRefillUseCaseProvider),
    isPerCellMiadEnabled: ref.read(isPerCellMiadEnabledProvider),
  );
});

class RefillListExecutionNotifier extends ChangeNotifier
    with
        MasterDrawerExecutionMixin,
        CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>,
        CabinOperationEntryMixin
    implements CabinOperationExecutionController {
  RefillListExecutionNotifier({
    required IMasterDrawerSession drawerSession,
    required RefillListRefillUseCase refillCabin,
    required this.isPerCellMiadEnabled,
  }) : _drawerSession = drawerSession,
       _refillCabin = refillCabin {
    attachDrawerSession();
  }

  final IMasterDrawerSession _drawerSession;
  final RefillListRefillUseCase _refillCabin;

  @override
  IMasterDrawerSession get drawerSession => _drawerSession;

  int? _fillingListId;
  int? get fillingListId => _fillingListId;

  /// Fiziksel çekmece kimliği çözülemediği için kuyruğa alınamayan satır
  /// sayısı — execution ekranında bilgi banner'ı için.
  int _skippedCount = 0;
  int get skippedCount => _skippedCount;

  /// Kuyruğa alınan satırlar, satır id'sine (RefillListDetail.id) göre — başlık
  /// tablodakiyle AYNI etiket/durum mantığını kullanabilsin diye. Target
  /// refillListDetailId taşıdığı için eşleşme her zaman tekil.
  Map<int, RefillListDetail> _detailsById = const {};

  RefillListDetail? detailFor(CabinOperationTarget target) {
    final id = target.sourceId;
    return id == null ? null : _detailsById[id];
  }

  /// SKT modu — ekran açıldığı anın ayarı. Kuyruk boyunca sabit kalır, böylece
  /// ekranın gösterdiği mod ile kaydın/doğrulamanın kullandığı mod ayrışmaz.
  @override
  final bool isPerCellMiadEnabled;

  @override
  void dispose() {
    detachDrawerSession();
    super.dispose();
  }

  Future<void> start(
    List<CabinOperationDrawerJob> jobs, {
    required int fillingListId,
    required List<RefillListDetail> details,
    int skippedCount = 0,
  }) {
    _fillingListId = fillingListId;
    _skippedCount = skippedCount;
    _detailsById = {
      for (final d in details)
        if (d.id != null) d.id!: d,
    };
    return startQueue(jobs);
  }

  @override
  Future<void> confirmCurrent() async {
    final target = currentTarget;
    if (isStopping || target == null || !target.isValid) return;
    await confirmSingleTarget(saveTarget: _saveTarget);
  }

  Future<bool> _saveTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return true; // dolum girilmemiş hedef — kayıt yok, ilerle

    final params = RefillListParamsMapper.toParamsForTarget(target);
    final result = await _refillCabin(params);

    return result.when(
      ok: (_) => true,
      error: (e) {
        // Kuyruk hatası: kullanıcıya "sonraki çekmece / işlemi sonlandır" sunulur.
        setQueueFailure(CabinApiFailure(message: e.message), isQueueError: true);
        return false;
      },
    );
  }

  @override
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) =>
      locationItemsUsing(allGroups: allGroups, cabinDrawerIdOf: (job) => job.cabinDrawerId, stockIdAt: (_, _) => null);
}
