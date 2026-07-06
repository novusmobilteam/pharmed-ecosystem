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

  /// Saving sırasında çekmece kapandıysa true. Kayıt sonucu gelince
  /// (_completeRefill) değerlendirilir: OK → doğrudan Success, hata → Error.
  bool _closedDuringSaving = false;

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

  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileUnloadReady) return;

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || !(item.status?.canUnload ?? false)) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
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

  /// Boşaltmaya başla — check YOK, direkt çekmece aç.
  ///
  /// SWREQ-CLI-UNLOAD-002
  Future<void> startUnload() async {
    final current = state;
    if (current is! MobileUnloadReady) return;

    state = MobileUnloadDrawerOpening(ready: current.copyWith(baselineCompleted: false));

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
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
  Future<void> _scanCabin() async {
    final current = state;
    if (current is MobileUnloadError) return;

    final ready = current.readyContext;
    if (ready == null) return;

    // Beklenen kabin tag'lerini çek — reconciliation için DEĞİL,
    // yalnızca kapanışta EPC → prescriptionItemId çözümü için lookup.
    final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);
    String? errorMessage;

    expectedResult.when(
      ok: (value) => _expectedMap = {
        for (final e in value)
          if (e.rfidTag != null) e.rfidTag!: e,
      },
      error: (e) => errorMessage = e.message,
    );

    if (errorMessage != null) {
      state = MobileUnloadError(message: errorMessage!, previousState: ready);
      return;
    }

    // Snapshot → baseline (bölünmez, hepsi eşit)
    final observed = await _drawer.snapshot();
    final after = state;
    final afterReady = after.readyContext;
    if (afterReady == null) return;
    state = _withReady(after, afterReady.copyWith(baselineCompleted: true, baselineEpcs: observed));
  }

  /// ClosedEarly / Error → "İptal". Kayıt YOK. İşlemi bitirir, Idle'a döner.
  Future<void> cancelEarlyClose() async {
    final current = state;
    final ready = current.readyContext;

    await _drawer.stop();
    _resetExpectedMap();
    _closedDuringSaving = false;

    if (ready == null) {
      state = const MobileUnloadIdle(slots: [], mobileSlots: [], assignments: [], cabinId: 0);
      return;
    }

    // Sahne KORUNUR — slot/hasta listesi ekranda kalır
    state = MobileUnloadIdle(
      slots: ready.slots,
      mobileSlots: ready.mobileSlots,
      assignments: ready.assignments,
      cabinId: ready.cabinId,
    );
  }

  /// ClosedEarly → "Tekrar Dene". Çekmece yeniden açılır (Sayım'da check YOK zaten).
  /// Baseline + _expectedMap + runtime kümeleri KORUNUR.
  Future<void> retryEarlyClose() async {
    final current = state;
    final ready = current.readyContext;
    if (ready == null) return;

    _closedDuringSaving = false;

    // ready olduğu gibi taşınır (baseline + placedEpcs + baselineLostEpcs dahil).
    // Sadece baselineCompleted false → UI "Tarama yapılıyor" gösterir,
    // complete butonu reopen tamamlanana kadar disabled.
    final reopening = ready.copyWith(baselineCompleted: false);
    state = MobileUnloadDrawerOpening(ready: reopening);

    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Checkbox — RFID'siz item'ı boşaltmaya dahil et / çıkar.
  /// Default dahildir; kapatılınca hariç tutulur. Dahil edilince eksik işareti kalkar.
  /// SWREQ-CLI-UNLOAD-007
  void toggleUnloadInclude(int itemId) {
    final current = state;
    final ready = current.readyContext;
    if (ready == null) return;

    final excluded = ready.unloadExcludedItemIds;
    final wasExcluded = excluded.contains(itemId);
    // wasExcluded ise şimdi dahil ediyoruz (setten çıkar), değilse hariç tut (sete ekle).
    final nextExcluded = wasExcluded ? (Set<int>.from(excluded)..remove(itemId)) : {...excluded, itemId};

    // Boşaltmaya dahil edildiyse (wasExcluded==true) eksik işaretini kaldır.
    final nextMissing = wasExcluded
        ? (Set<int>.from(ready.markedMissingItemIds)..remove(itemId))
        : ready.markedMissingItemIds;

    state = _withReady(current, ready.copyWith(unloadExcludedItemIds: nextExcluded, markedMissingItemIds: nextMissing));
  }

  /// Toggle — RFID'siz item'ı eksik işaretle / kaldır.
  /// Eksik işaretlenince boşaltmadan çıkar (ikisi bir arada olamaz).
  /// SWREQ-CLI-UNLOAD-007
  void toggleMarkMissing(int itemId) {
    final current = state;
    final ready = current.readyContext;
    if (ready == null) return;

    final marked = ready.markedMissingItemIds;
    final wasMarked = marked.contains(itemId);
    final nextMissing = wasMarked ? (Set<int>.from(marked)..remove(itemId)) : {...marked, itemId};

    // Eksik işaretlendiyse (yeni marked) boşaltmadan çıkar → hariç tut.
    final nextExcluded = wasMarked ? ready.unloadExcludedItemIds : {...ready.unloadExcludedItemIds, itemId};

    state = _withReady(current, ready.copyWith(unloadExcludedItemIds: nextExcluded, markedMissingItemIds: nextMissing));
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

    if (_drawerStage is! MobileDrawerOpened) return;

    state = MobileUnloadSaving(ready: current);

    // Asıl boşaltma kaydı — seçim yok, tüm hasta ilaçları.
    // Boşaltılan = (RFID'li takenEpcs) + (RFID'siz, eksik İŞARETLENMEYEN).
    // notFound (hiç okunmayan) ve manuel eksik işaretlenenler dışlanır.
    final params = current.prescriptionItems
        .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending)
        .where((i) {
          final epc = i.rfidTag;
          if (epc != null) {
            // RFID'li: yalnızca fiziksel çıkarılanlar boşaltılır
            return current.takenEpcs.contains(epc);
          }
          // RFID'siz: eksik işaretlenmediyse boşaltılır
          return current.isUnloadIncluded(i.id!);
        })
        .map((i) => MobileUnloadParams(prescriptionDetailId: i.id!))
        .toList();

    final result = await _completeUnload(params);

    await result.when(
      ok: (_) async {
        // WaitingClose → drawer fiziksel kapanınca _onDrawerStageChange
        // eksik bildirimlerini topluca yapar, sonra Success.
        state = MobileUnloadWaitingClose(ready: current);
      },
      error: (e) async {
        // Kayıt FAIL — RFID state KORUNUR, drawer açık, retry edilebilir.
        state = MobileUnloadError(message: e.message, previousState: current);
      },
    );
  }

  /// Error → "Tekrar Dene". Çekmece açık; kaydı yeniden dener (reopen YOK).
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileUnloadError) return;
    final ready = current.previousState.readyContext;
    if (ready == null) return;

    state = ready;
    await completeUnload();
  }

  /// Plan-dışı hareketleri bildirir (fire-and-forget, complete sonrası).
  /// Her UNPLANNED EPC için EXPECTED_MAP'ten materialId/itemId çözülür.
  /// Hata kullanıcıyı durdurmaz — kayıt zaten başarılı (skill §7).
  ///
  /// SWREQ-CLI-UNLOAD-008
  Future<void> _reportUnplannedMovements(MobileUnloadReady ready, Map<String, CabinExpectedEpc> expectedMap) async {
    // a) Otomatik eksik — missingEpcs → prescriptionItemId (EXPECTED_MAP'ten)
    for (final epc in ready.missingEpcs) {
      final itemId = expectedMap[epc]?.prescriptionItem?.id;
      if (itemId == null) continue;
      final r = await _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.unload);
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-008',
          message: 'otomatik eksik bildirimi başarısız (retry yok)',
          context: {'itemId': itemId, 'epc': epc, 'error': r.error.message},
        );
      }
    }

    // b) Manuel eksik — markedMissingItemIds (RFID'siz item'lar)
    for (final itemId in ready.markedMissingItemIds) {
      final r = await _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.unload);
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileUnloadNotifier',
          swreq: 'SWREQ-CLI-UNLOAD-008',
          message: 'manuel eksik bildirimi başarısız (retry yok)',
          context: {'itemId': itemId, 'error': r.error.message},
        );
      }
    }

    // Boşaltmada fazla stok bildirimi YOK (sayım kapsamı değil).
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
    final ready = current.readyContext;
    if (ready == null) return;

    // KORUMA: baseline bitmediyse okunan her etiket kabinin kendi malı;
    // unexpected/placed sayılamaz.
    if (!ready.baselineCompleted) return;

    // Baseline'daki tag geri okundu → lost'tan kurtar (kullanıcı geri koydu).
    if (ready.baselineEpcs.contains(epc)) {
      if (ready.baselineLostEpcs.contains(epc)) {
        state = _withReady(
          current,
          ready.copyWith(baselineLostEpcs: Set<String>.from(ready.baselineLostEpcs)..remove(epc)),
        );
      }
      return;
    }

    // Baseline'da yok → sonradan konan tag.
    if (ready.placedEpcs.contains(epc)) return;
    state = _withReady(current, ready.copyWith(placedEpcs: {...ready.placedEpcs, epc}));
  }

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
    final ready = current.readyContext;
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // Baseline'daki tag çıktı → kabinden alındı.
    // Seçili → missing/taken, seçili değil → unplanned (getter türetir).
    if (ready.baselineEpcs.contains(epc)) {
      if (ready.baselineLostEpcs.contains(epc)) return; // dedup
      state = _withReady(current, ready.copyWith(baselineLostEpcs: {...ready.baselineLostEpcs, epc}));

      return;
    }

    // Sonradan konan yabancı tag çıktı → kullanıcı geri aldı (düzeltici).
    // placedEpcs'ten silinince unexpected uyarısı/blokajı kalkar. Bildirim YOK.
    if (ready.placedEpcs.contains(epc)) {
      state = _withReady(current, ready.copyWith(placedEpcs: Set<String>.from(ready.placedEpcs)..remove(epc)));
      return;
    }

    // Ne baseline ne placed — ignore
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    // ── Çekmece açıldı → sahneye geç, baseline tara ──────────────────────
    if (next is MobileDrawerOpened) {
      final current = state;
      // Sayımda check YOK: ilk açılış VE reopen ikisi de DrawerOpening → Ready.
      final ready = switch (current) {
        MobileUnloadDrawerOpening(:final ready) => ready,
        _ => null,
      };
      if (ready != null) {
        state = ready;
        unawaited(_scanCabin());
      }
    }

    // ── Çekmece kapandı ──────────────────────────────────────────────────
    if (next is MobileDrawerClosed) {
      final current = state;
      switch (current) {
        // Normal: kayıt gitti, kapanış bekleniyordu → bildir + Success
        case MobileUnloadWaitingClose(:final ready):
          final expectedSnapshot = Map<String, CabinExpectedEpc>.of(_expectedMap);
          unawaited(_reportUnplannedMovements(ready, expectedSnapshot));
          unawaited(_drawer.stop());
          state = MobileUnloadSuccess(
            slots: ready.slots,
            mobileSlots: ready.mobileSlots,
            selectedSlot: ready.selectedSlot,
            assignments: ready.assignments,
            cabinId: ready.cabinId,
            message: '',
            ready: ready.clearedRfidState,
          );
          _resetExpectedMap();

        // Kayıt uçuşta kapandı → flag'le; Saving çözülünce değerlendir
        case MobileUnloadSaving():
          _closedDuringSaving = true;

        // Tamamla denmeden kapandı → kullanıcıya karar sor
        case MobileUnloadReady r:
          state = MobileUnloadClosedEarly(ready: r);

        default:
          break;
      }
    }

    // ── Çekmece donanım hatası → kurtarılamaz, FatalError ────────────────
    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileUnloadReady r => r.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileUnloadDrawerOpening(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileUnloadSaving(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileUnloadWaitingClose(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileUnloadClosedEarly(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        _ => current,
      };
      state = MobileUnloadFatalError(message: next.message, previousState: cleaned);
    }
  }

  void dismissError() {
    final current = state;
    final previous = switch (current) {
      MobileUnloadError(:final previousState) => previousState,
      MobileUnloadFatalError(:final previousState) => previousState,
      _ => null,
    };
    if (previous == null) return;

    unawaited(_drawer.stop());
    _resetExpectedMap();

    // previousState'ten gerçek Ready'yi çıkar — wrapper/NoPatient olabilir.
    final ready = current.readyContext;
    state = ready ?? previous;
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

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. RFID event'i işlenmemesi gereken state'ler değişmeden döner.
  MobileUnloadState _withReady(MobileUnloadState s, MobileUnloadReady ready) => switch (s) {
    MobileUnloadReady _ => ready,
    MobileUnloadDrawerOpening _ => MobileUnloadDrawerOpening(ready: ready),
    MobileUnloadSaving _ => MobileUnloadSaving(ready: ready),
    _ => s,
  };
}
