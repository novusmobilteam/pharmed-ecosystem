import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../unload.dart';

// [SWREQ-CLI-UNLOAD-001] [IEC 62304 §5.5]
// Mobil kabin ilaç boşaltma ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Boşaltma başlatma → check YOK — direkt çekmece açar
//   - RFID kaybı → takenEpcs günceller (alımla aynı: kayıp = boşaltıldı)
//   - EPC geri gelirse takenEpcs'ten çıkarılır
//   - Boşaltma tamamlama → çekmece kapalıyken CompleteMobileUnloadUseCase çağırır
//
// Alımdan farkı:
//   - CheckUseCase YOK — startUnload direkt _drawer.open() çağırır
//   - Use case'e sadece prescriptionDetailId listesi gönderilir (epc/dosePiece yok)
//
// Sınıf: Class B

final mobileUnloadNotifierProvider = NotifierProvider<MobileUnloadNotifier, MobileUnloadState>(
  MobileUnloadNotifier.new,
);

class MobileUnloadNotifier extends Notifier<MobileUnloadState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  GetCabinExpectedEpcsUseCase get _getCabinExpectedEpcs => ref.read(getCabinExpectedEpcsUseCaseProvider);
  CompleteMobileUnloadUseCase get _completeUnload => ref.read(completeMobileUnloadUseCaseProvider);
  ReportMissingStockUseCase get _reportMissingStock => ref.read(reportMissingStockUseCaseProvider);

  // ── EXPECTED_MAP (§3) ───────────────────────────────────────────────────
  // Baseline scan'in yan ürünü; reconciliation kümeleri kurulurken ve
  // bildirim üretirken (EPC → itemId/materialId çözümü) kullanılır.
  // State class'larında tutulmaz çünkü boyutu büyüyebilir ve reactive UI'a
  // ihtiyaç duyulmaz. cancel/error/success akışlarında temizlenir.
  Map<String, CabinExpectedEpc> _expectedMap = const <String, CabinExpectedEpc>{};

  @override
  MobileUnloadState build() {
    _drawer = MobileDrawerOrchestrator(ref: ref)
      ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);

    ref.onDispose(() => _drawer.dispose());

    return const MobileUnloadUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    final mobileSlots = data.mobileSlots;

    state = MobileUnloadLoading(slots: slots, cabinId: data.cabinId);

    final assignmentResult = await _getAssignments.call(data.cabinId);

    state = assignmentResult.when(
      ok: (assignments) =>
          MobileUnloadIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
      error: (e) => MobileUnloadError(
        message: e.message,
        previousState: MobileUnloadIdle(
          slots: slots,
          mobileSlots: mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      ),
    );
  }

  Future<void> selectAssignment(BedAssignment assignment) async {
    if (assignment.cellId == null) return;

    final coord = state.assignmentByCoord.entries
        .where((e) => e.value.id == assignment.id)
        .map((e) => e.key)
        .firstOrNull;
    if (coord == null) return;

    final slot = state.slots.where((s) => s.slotId == coord.$1).firstOrNull;
    if (slot == null) return;
    if (state.selectedSlotId != slot.slotId) {
      onSlotTap(slot);
    }

    await onCellTap(coord);
  }

  void clearPatientSelection() {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    state = MobileUnloadSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileUnloadReady) return;

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || !(item.status?.canUnload ?? false)) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  void onDatePresetChanged(DateRangePreset preset) {
    final current = state;
    if (current is! MobileUnloadReady) return;
    state = current.copyWith(datePreset: preset);
    _reloadPrescriptions();
  }

  void onStatusFilterChanged(PrescriptionMovementType? type) {
    final current = state;
    if (current is! MobileUnloadReady) return;
    state = current.copyWith(statusFilter: type, clearStatusFilter: type == null);
    _reloadPrescriptions();
  }

  Future<void> _reloadPrescriptions() async {
    final current = state;
    if (current is! MobileUnloadReady) return;

    final result = await _getPrescriptionHistory.call(
      current.patient.id!,
      params: PagedQueryParamsBuilder.fromPreset(
        preset: current.datePreset,
        filters: [if (current.statusFilter != null) Filter.eq('lastMovement.detailStatusId', current.statusFilter!.id)],
      ),
    );

    result.when(
      ok: (items) => state = current.copyWith(
        prescriptionItems: items,
        selectedItemIds: {}, // filtre değişince seçimi sıfırla
      ),
      error: (e) => state = MobileUnloadError(message: e.message, previousState: current),
    );
  }

  /// Boşaltmaya başla — check YOK, direkt çekmece aç.
  ///
  /// SWREQ-CLI-UNLOAD-002
  Future<void> startUnload() async {
    final current = state;
    if (current is! MobileUnloadReady) return;

    // Çekmece idle olmalı (henüz açılmamış)
    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerIdle) return;

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  Future<void> reopenDrawer() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  Future<void> cancelUnload() async {
    final current = state;
    final ready = switch (current) {
      MobileUnloadReady r => r,
      MobileUnloadSaving(:final ready) => ready,
      _ => null,
    };

    final stage = _drawerStage;

    if (stage is MobileDrawerIdle) {
      if (ready == null) return;
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {}, takenEpcs: {});
      return;
    }

    if ((stage is MobileDrawerOpening || stage is MobileDrawerOpened) && (ready?.takenEpcs.isNotEmpty ?? false)) {
      return;
    }

    await _drawer.stop();

    if (ready != null) {
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {}, takenEpcs: {});
    }
  }

  /// Boşaltmayı tamamla — çekmece kapalıyken çağrılır.
  ///
  /// Asıl kayıt başarısızsa ROLLBACK: çekmece otomatik açılır, kullanıcı
  /// çıkardığı ilaçları geri koyar (previouslyTakenEpcs).
  ///
  /// SWREQ-CLI-UNLOAD-003
  Future<void> completeUnload() async {
    final current = state;
    if (current is! MobileUnloadReady) return;
    if (!current.canComplete) return;

    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerClosed) return;

    state = MobileUnloadSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    // 1) NotFound + manuel hariç tutulan RFID'siz item'lar için eksik bildirimi.
    //    Henüz fiziksel kayıt yok → fail olursa Error (rollback DEĞİL).
    final missingItems = current.prescriptionItems.where((i) {
      if (i.id == null) return false;
      final epc = i.rfidTag;
      // RFID'li & baseline'da bulunamadı → otomatik eksik
      if (epc != null && current.notFoundEpcs.contains(epc)) return true;
      return false;
    }).toList();

    for (final item in missingItems) {
      final r = await _reportMissingStock(prescriptionItemId: item.id!, type: CabinInventoryType.unload);
      if (r is Error) {
        MedLogger.warn(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-007',
          message: 'Auto eksik stok bildirimi başarısız — complete iptal',
          context: {'itemId': item.id, 'error': r.error.message},
        );
        state = MobileUnloadError(
          message: 'Eksik stok bildirimi başarısız: ${r.error.message}',
          previousState: current,
        );
        return;
      }
    }

    // 3) Asıl boşaltma kaydı — seçim yok, tüm hasta ilaçları.
    //    Boşaltılan = (RFID'li takenEpcs) + (RFID'siz, excludedItemIds'te DEĞİL).
    //    notFound ve excluded dışlanır.
    final params = current.prescriptionItems
        .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending)
        .where((i) {
          final epc = i.rfidTag;
          if (epc != null) {
            // RFID'li: yalnızca fiziksel çıkarılanlar boşaltılır
            return current.takenEpcs.contains(epc);
          }
          // RFID'siz: hariç tutulmadıysa boşaltılır
          return !current.excludedItemIds.contains(i.id);
        })
        .map((i) => MobileUnloadParams(prescriptionDetailId: i.id!))
        .toList();

    if (params.isEmpty) {
      // Boşaltılacak bir şey yok → doğrudan Success
      await _drawer.stop();
      _resetExpectedMap();
      state = MobileUnloadSuccess(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: current.selectedSlot,
        assignments: current.assignments,
        cabinId: current.cabinId,
        message: '',
        ready: current.clearedRfidState,
      );
      return;
    }

    final result = await _completeUnload(params);

    await result.when(
      ok: (_) async {
        await _drawer.stop();

        // Plan-dışı bildirimi — kayıt OK olduktan SONRA (skill §7), fire-and-forget
        if (current.unplannedMovements.isNotEmpty) {
          final expectedSnapshot = _expectedMap;
          unawaited(_reportUnplannedMovements(current.unplannedMovements, expectedSnapshot));
        }
        _resetExpectedMap();

        state = MobileUnloadSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: '',
          ready: current.clearedRfidState,
        );
      },
      error: (e) async {
        // BAŞARISIZ → ROLLBACK: ilaçlar fiziksel çıktı ama kayıt geçmedi.
        MedLogger.warn(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-003',
          message: 'Complete başarısız — rollback başlatılıyor',
          context: {'error': e.message, 'takenCount': current.takenEpcs.length},
        );

        final rollbackReady = current.copyWith(previouslyTakenEpcs: current.takenEpcs, rfidReadEpcs: const {});

        state = MobileUnloadRollbackInProgress(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          ready: rollbackReady,
        );

        await _drawer.open(slots: current.slots, slot: current.selectedSlot);
      },
    );
  }

  /// Plan-dışı hareketleri bildirir (fire-and-forget, complete sonrası).
  /// Her UNPLANNED EPC için EXPECTED_MAP'ten materialId/itemId çözülür.
  /// Hata kullanıcıyı durdurmaz — kayıt zaten başarılı (skill §7).
  ///
  /// SWREQ-CLI-UNLOAD-008
  Future<void> _reportUnplannedMovements(Set<String> unplannedEpcs, Map<String, CabinExpectedEpc> expectedMap) async {
    for (final epc in unplannedEpcs) {
      final exp = expectedMap[epc];
      final itemId = exp?.prescriptionItem?.id;
      if (itemId == null) {
        MedLogger.warn(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-008',
          message: 'Plan-dışı için itemId çözülemedi',
          context: {'epc': epc},
        );
        continue;
      }
      final r = await _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.unload);
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-008',
          message: 'Plan-dışı bildirimi başarısız (retry yok)',
          context: {'epc': epc, 'itemId': itemId, 'error': r.error.message},
        );
      }
    }
  }

  /// Error sonrası boşaltmayı yeniden dener — completeUnload'u baştan çalıştırır.
  /// Çekmece kapalı, RFID/baseline state korunmuş; dokunulmaz.
  ///
  /// SWREQ-CLI-UNLOAD-003
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileUnloadError) return;
    final previous = current.previousState;
    if (previous is! MobileUnloadReady) return;

    state = previous;
    await completeUnload();
  }

  /// Eksik stok bildir — ilaç fiziksel olarak kabinde yok.
  ///
  /// Backend bildirimi başarılıysa reçete yeniden çekilir; ilgili item
  /// artık "Alım Bekliyor" olmaktan çıkar ve seçiliyse seçimi kaldırılır.
  ///
  /// Süreç (orchestrator) aktifken çağrılmaz — buton zaten gizli olur.
  ///
  /// SWREQ-CLI-INTAKE-006
  Future<void> reportMissingStock(int itemId) async {
    final current = state;
    if (current is! MobileUnloadReady) return;
    if (current.reportingItemIds.contains(itemId)) return; // zaten işlemde
    if (current.reportedMissingItemIds.contains(itemId)) return; // zaten bildirildi

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;
    if (!(item.status?.canReportShortage ?? false)) return;

    state = current.copyWith(reportingItemIds: {...current.reportingItemIds, itemId});

    final result = await _reportMissingStock.call(prescriptionItemId: itemId, type: CabinInventoryType.unload);

    result.when(
      ok: (_) async {
        state = current.copyWith(
          reportingItemIds: {...current.reportingItemIds}..remove(itemId),
          reportedMissingItemIds: {...current.reportedMissingItemIds, itemId},
        );
        return;
      },
      error: (e) => state = MobileUnloadError(
        message: e.message,
        previousState: current.copyWith(reportingItemIds: {...current.reportingItemIds}..remove(itemId)),
      ),
    );
  }

  /// Çekmece açıldıktan sonra baseline snapshot alır ve reconciliation yapar.
  ///
  /// Boşaltma seçimsizdir — tüm hasta ilaçları boşaltılacak (sayım gibi),
  /// fiziksel olarak çıkarılır (alım gibi). Reconciliation EXPECTED üzerinden:
  ///   - matched (EXPECTED ∩ OBSERVED) → rfidReadEpcs (kabinde, boşaltılmayı bekliyor)
  ///   - notFound (EXPECTED ∖ OBSERVED) → notFoundEpcs (boşaltılacak ama yok → otomatik eksik)
  ///   - unexpected (OBSERVED ∖ EXPECTED) → unexpectedEpcs (sessiz, lost olursa unplanned)
  ///
  /// SWREQ-CLI-UNLOAD-009
  Future<void> _performBaselineScan() async {
    final current = state;
    if (current is MobileUnloadError || current is MobileUnloadRollbackInProgress) return;

    final ready = _readyOf(current);
    if (ready == null) return;

    // EXPECTED: tüm kabin stoğu (PASSIVE ayrımı için)
    final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);
    List<CabinExpectedEpc>? expected;
    String? errorMessage;
    expectedResult.when(ok: (v) => expected = v, error: (e) => errorMessage = e.message);
    if (errorMessage != null) {
      state = MobileUnloadError(message: errorMessage!, previousState: ready);
      return;
    }

    _expectedMap = {for (final e in expected!) (e.rfidTag ?? ''): e};
    final expectedSet = _expectedMap.keys.toSet();

    // TARGET: boşaltılacak gözün RFID'li ilaçları (seçim yok — tüm hasta ilaçları)
    final targetSet = ready.prescriptionItems
        .where((i) => i.rfidTag != null && i.status == PrescriptionMovementType.purchasePending)
        .map((i) => i.rfidTag!)
        .toSet();

    final observed = await _drawer.snapshot();

    final after = state;
    final afterReady = _readyOf(after);
    if (afterReady == null) return;

    // Dört küme
    final matched = targetSet.intersection(observed); // boşaltılacak, kabinde
    final notFound = targetSet.difference(observed); // boşaltılacak ama yok
    final passive = expectedSet.difference(targetSet).intersection(observed); // başka göz stoğu
    final unexpected = observed.difference(expectedSet); // kabine ait değil

    final updatedReady = afterReady.copyWith(
      baselineCompleted: true,
      rfidReadEpcs: matched,
      notFoundEpcs: notFound,
      passiveEpcs: passive,
      unexpectedEpcs: unexpected,
    );

    state = _withReady(after, updatedReady);
  }

  /// RFID'siz bir item'ı "boşaltma dışı" (kabinde kalacak) işaretler / kaldırır.
  /// Servise gitmez — completeUnload params'ında dışlanır.
  ///
  /// SWREQ-CLI-UNLOAD-007
  void toggleExclude(int itemId) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;

    final excluded = ready.excludedItemIds;
    final next = excluded.contains(itemId) ? (Set<int>.from(excluded)..remove(itemId)) : {...excluded, itemId};

    state = _withReady(current, ready.copyWith(excludedItemIds: next));
  }

  /// EPC okundu — çekmecede tag göründü.
  ///
  ///   - Rollback sırasında: kullanıcı boşalttığı ilacı geri koyuyor →
  ///     rfidReadEpcs'e ekle; previouslyTakenEpcs hepsi geri konunca finalize.
  ///   - Baseline öncesi → ignore
  ///   - Baseline sonrası:
  ///     · takenEpcs'te → boşaltılan ilaç geri konuldu, takenEpcs'ten çıkar
  ///     · notFoundEpcs'te → eksikti, geç okundu, çıkar → matched'a dön
  ///     · expected'da → matched (rfidReadEpcs)
  ///     · değilse → unexpected
  ///
  /// SWREQ-CLI-UNLOAD-004
  void _onEpcRead(String epc) {
    final current = state;

    // ── Rollback: geri konan tag'i izle ──────────────────────────────────
    if (current is MobileUnloadRollbackInProgress) {
      final ready = current.ready;
      if (!ready.previouslyTakenEpcs.contains(epc)) return;
      if (ready.rfidReadEpcs.contains(epc)) return; // dedup

      final updatedReady = ready.copyWith(rfidReadEpcs: {...ready.rfidReadEpcs, epc});
      state = current.copyWith(ready: updatedReady);

      MedLogger.info(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-004',
        message: 'Rollback — boşaltılan tag kabine geri kondu',
        context: {'epc': epc, 'pending': updatedReady.pendingRollbackEpcs.length},
      );
      return;
    }

    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // Hata kümelerinden geri dönüş
    final wasUnplanned = ready.unplannedMovements.contains(epc);

    // Zaten bilinen aktif kümede mi? dedup
    final alreadyKnown =
        ready.rfidReadEpcs.contains(epc) || ready.passiveEpcs.contains(epc) || ready.unexpectedEpcs.contains(epc);
    if (!wasUnplanned && alreadyKnown) return;

    var newRead = ready.rfidReadEpcs;
    var newNotFound = Set<String>.from(ready.notFoundEpcs)..remove(epc);
    var newPassive = ready.passiveEpcs;
    var newUnexpected = ready.unexpectedEpcs;
    var newUnplanned = ready.unplannedMovements;
    var newTaken = Set<String>.from(ready.takenEpcs)..remove(epc);

    final isTarget = _isTargetEpc(ready, epc);
    final isExpected = _expectedMap.containsKey(epc);

    if (wasUnplanned) {
      // Plan dışı çıkarılan geri kondu → PASSIVE'e geri yükle
      newUnplanned = Set<String>.from(newUnplanned)..remove(epc);
      newPassive = {...newPassive, epc};
    } else if (isTarget) {
      newRead = {...newRead, epc}; // boşaltma hedefi, kabinde
    } else if (isExpected) {
      newPassive = {...newPassive, epc}; // başka gözün stoğu
    } else {
      newUnexpected = {...newUnexpected, epc}; // kabine ait değil
    }

    state = _withReady(
      current,
      ready.copyWith(
        rfidReadEpcs: newRead,
        takenEpcs: newTaken,
        notFoundEpcs: newNotFound,
        passiveEpcs: newPassive,
        unexpectedEpcs: newUnexpected,
        unplannedMovements: newUnplanned,
      ),
    );
  }

  bool _isTargetEpc(MobileUnloadReady ready, String epc) =>
      ready.prescriptionItems.any((i) => i.status == PrescriptionMovementType.purchasePending && i.rfidTag == epc);

  /// EPC kayboldu — çekmeceden tag çıktı.
  ///
  ///   - Rollback sırasında: geri konan tag tekrar çıkarıldı → rfidReadEpcs'ten düş
  ///   - Baseline öncesi → ignore
  ///   - Baseline sonrası:
  ///     · rfidReadEpcs'te (matched) → takenEpcs'e geç (boşaltıldı — normal akış)
  ///     · unexpectedEpcs'te → unplannedMovements'a geç (plan dışı çıkış)
  ///     · Bilinmiyor → ignore
  ///
  /// SWREQ-CLI-UNLOAD-005
  void _onEpcLost(String epc) {
    final current = state;

    // ── Rollback: geri konmuş tag tekrar çıktıysa geri al ─────────────────
    if (current is MobileUnloadRollbackInProgress) {
      final ready = current.ready;
      if (!ready.rfidReadEpcs.contains(epc)) return;

      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);
      state = current.copyWith(ready: ready.copyWith(rfidReadEpcs: newRead));

      MedLogger.info(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-005',
        message: 'Rollback — geri konan tag tekrar çıkarıldı',
        context: {'epc': epc},
      );
      return;
    }

    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    if (ready.takenEpcs.contains(epc)) return; // zaten boşaltıldı

    // MATCHED → TAKEN (boşaltıldı — normal akış)
    if (ready.rfidReadEpcs.contains(epc)) {
      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);
      final newTaken = {...ready.takenEpcs, epc};
      state = _withReady(current, ready.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken));

      MedLogger.info(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-005',
        message: 'EPC çekmeceden çıktı — boşaltıldı',
        context: {'epc': epc},
      );
      return;
    }

    // PASSIVE → UNPLANNED (başka gözün ilacı çıkarıldı → plan dışı, YAPILMAMALI)
    if (ready.passiveEpcs.contains(epc)) {
      final newPassive = Set<String>.from(ready.passiveEpcs)..remove(epc);
      final newUnplanned = {...ready.unplannedMovements, epc};
      state = _withReady(current, ready.copyWith(passiveEpcs: newPassive, unplannedMovements: newUnplanned));

      MedLogger.warn(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-008',
        message: 'Plan dışı — boşaltma hedefi olmayan kabin ilacı çıkarıldı',
        context: {'epc': epc},
      );
      return;
    }

    // UNEXPECTED → UNPLANNED (plan dışı çıkış → eksik bildirim)
    if (ready.unexpectedEpcs.contains(epc)) {
      final newUnexpected = Set<String>.from(ready.unexpectedEpcs)..remove(epc);
      final newUnplanned = {...ready.unplannedMovements, epc};
      state = _withReady(current, ready.copyWith(unexpectedEpcs: newUnexpected, unplannedMovements: newUnplanned));

      MedLogger.warn(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-008',
        message: 'Plan dışı hareket — beklenmeyen EPC kabinden çıktı',
        context: {'epc': epc},
      );
      return;
    }
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    // Çekmece açıldı → baseline scan (rollback'te değil, RFID state korunur)
    if (next is MobileDrawerOpened) {
      final current = state;
      if (current is! MobileUnloadRollbackInProgress) {
        unawaited(_performBaselineScan());
      }
    }

    if (next is MobileDrawerClosed) {
      final current = state;

      // Rollback: tüm boşaltılan tag'ler kabine geri kondu mu?
      if (current is MobileUnloadRollbackInProgress) {
        if (current.ready.isRollbackComplete) {
          unawaited(_finalizeRollback(current));
        }
        // else: hâlâ eksik tag var, state aynı kalır.
        // Footer "Çekmeceyi Aç" / "Tekrar Dene" gösterir.
      }
    }

    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileUnloadReady r => r.clearedRfidState,
        MobileUnloadSaving(:final ready) => ready.clearedRfidState,
        MobileUnloadRollbackInProgress(:final ready) => ready.clearedRfidState,
        _ => current,
      };
      state = MobileUnloadFatalError(message: next.message, previousState: cleaned);
    }
  }

  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedSlotId == slot.slotId) {
      state = MobileUnloadIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = MobileUnloadSlotSelected(
      slots: slots,
      mobileSlots: ms,
      selectedSlot: slot,
      assignments: assignments,
      cabinId: cabinId,
    );
  }

  Future<void> onCellTap(MobileCellCoord coord) async {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedCell == coord) {
      state = MobileUnloadSlotSelected(
        slots: slots,
        mobileSlots: ms,
        selectedSlot: selectedSlot,
        assignments: assignments,
        cabinId: cabinId,
      );
      return;
    }

    final assignment = current.assignmentByCoord[coord];

    if (assignment?.hospitalization?.patient == null) {
      state = MobileUnloadNoPatient(
        slots: slots,
        mobileSlots: ms,
        selectedSlot: selectedSlot,
        selectedCell: coord,
        assignments: assignments,
        cabinId: cabinId,
      );
      return;
    }

    await _loadPrescriptions(
      slots: slots,
      mobileSlots: ms,
      selectedSlot: selectedSlot,
      selectedCell: coord,
      assignments: assignments,
      cabinId: cabinId,
      assignment: assignment!,
    );
  }

  Future<void> _loadPrescriptions({
    required List<MobileSlotVisual> slots,
    required List<MobileDrawerSlot> mobileSlots,
    required MobileSlotVisual selectedSlot,
    required MobileCellCoord selectedCell,
    required List<BedAssignment> assignments,
    required int cabinId,
    required BedAssignment assignment,
  }) async {
    final patient = assignment.hospitalization?.patient;
    if (patient?.id == null) return;

    state = MobileUnloadLoading(
      slots: slots,
      cabinId: cabinId,
      selectedSlot: selectedSlot,
      mobileSlots: mobileSlots,
      assignments: assignments,
    );

    final result = await _getPrescriptionHistory(
      patient!.id!,
      params: PagedQueryParamsBuilder.fromPreset(
        preset: DateRangePreset.today,
        filters: [Filter.eq('lastMovement.detailStatusId', PrescriptionMovementType.purchasePending.id)],
      ),
    );

    result.when(
      ok: (items) {
        state = MobileUnloadReady(
          slots: slots,
          mobileSlots: mobileSlots,
          selectedSlot: selectedSlot,
          selectedCell: selectedCell,
          assignments: assignments,
          cabinId: cabinId,
          patient: patient,
          bed: assignment.bed,
          room: assignment.bed?.room,
          prescriptionItems: items,
          rfidReadEpcs: const {},
          takenEpcs: const {},
          selectedItemIds: const {},
        );
      },
      error: (e) {
        state = MobileUnloadError(
          message: e.message,
          previousState: MobileUnloadNoPatient(
            slots: slots,
            mobileSlots: mobileSlots,
            selectedSlot: selectedSlot,
            selectedCell: selectedCell,
            assignments: assignments,
            cabinId: cabinId,
          ),
        );
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! MobileUnloadError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileUnloadSuccess) return;
    state = MobileUnloadIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  /// Baseline'ın yan ürünü olan EXPECTED_MAP'i boşaltır.
  void _resetExpectedMap() {
    _expectedMap = const <String, CabinExpectedEpc>{};
  }

  /// Rollback başarıyla tamamlandı — drawer + RFID temizliği yapar,
  /// state'i RollbackCompleted'e, ardından Idle'a çeker.
  ///
  /// SWREQ-CLI-UNLOAD-014
  Future<void> _finalizeRollback(MobileUnloadRollbackInProgress current) async {
    MedLogger.info(
      unit: 'MobileUnloadNotifier',
      swreq: 'SWREQ-CLI-UNLOAD-014',
      message: 'Rollback tamamlandı — tüm tag\'ler kabine geri kondu',
      context: {
        'previouslyTakenCount': current.ready.previouslyTakenEpcs.length,
        'unplannedCount': current.ready.unplannedMovements.length,
      },
    );

    await _drawer.stop();
    _resetExpectedMap();

    state = MobileUnloadRollbackCompleted(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );

    unawaited(
      Future.microtask(() {
        final s = state;
        if (s is MobileUnloadRollbackCompleted) {
          state = MobileUnloadIdle(
            slots: s.slots,
            mobileSlots: s.mobileSlots,
            assignments: s.assignments,
            cabinId: s.cabinId,
          );
        }
      }),
    );
  }

  MobileUnloadReady? _readyOf(MobileUnloadState s) => switch (s) {
    MobileUnloadReady r => r,
    MobileUnloadSaving(:final ready) => ready,
    MobileUnloadSuccess(:final ready) => ready,
    MobileUnloadError(:final previousState) => _readyOf(previousState),
    MobileUnloadRollbackInProgress(:final ready) => ready,
    _ => null,
  };

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  MobileUnloadState _withReady(MobileUnloadState s, MobileUnloadReady ready) => switch (s) {
    MobileUnloadReady _ => ready,
    MobileUnloadSaving w => MobileUnloadSaving(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileUnloadRollbackInProgress w => MobileUnloadRollbackInProgress(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    _ => s,
  };
}
