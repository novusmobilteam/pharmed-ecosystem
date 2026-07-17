import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../census.dart';

// [SWREQ-CLI-CENSUS-001] [IEC 62304 §5.5]
// Mobil kabin ilaç sayım ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Sayım başlatma → check YOK — direkt çekmece açar
//   - RFID okundu → rfidReadEpcs'e ekle (ilaç kabinde mevcut)
//   - RFID kayboldu → rfidReadEpcs'ten çıkar (ilaç kabinden çıkarıldı)
//   - canComplete: seçili RFID'li item'ların EPC'si rfidReadEpcs'te mi?
//   - Sayım tamamlama → çekmece kapalıyken CompleteMobileCensusUseCase çağırır
//
// Alımdan farkı:
//   - CheckUseCase YOK — startCensus direkt _drawer.open() çağırır
//   - takenEpcs YOK — sadece rfidReadEpcs takip edilir (dolumla aynı mantık)
//   - canComplete: EPC'nin kaybolması değil, okunuyor olması beklenir
//
// Sınıf: Class B

final mobileCensusNotifierProvider = NotifierProvider<MobileCensusNotifier, MobileCensusState>(
  MobileCensusNotifier.new,
);

class MobileCensusNotifier extends Notifier<MobileCensusState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  GetCabinExpectedEpcsUseCase get _getCabinExpectedEpcs => ref.read(getCabinExpectedEpcsUseCaseProvider);
  CompleteMobileCensusUseCase get _completeCensus => ref.read(completeMobileCensusUseCaseProvider);
  ReportMissingStockUseCase get _reportMissingStock => ref.read(reportMissingStockUseCaseProvider);
  ReportExcessStockUseCase get _reportExcessStock => ref.read(reportExcessStockUseCaseProvider);

  // ── EXPECTED_MAP (§3) ───────────────────────────────────────────────────
  // Baseline scan'in yan ürünü; reconciliation kümeleri kurulurken ve
  // bildirim üretirken (EPC → itemId/materialId çözümü) kullanılır.
  // State class'larında tutulmaz çünkü boyutu büyüyebilir ve reactive UI'a
  // ihtiyaç duyulmaz. cancel/error/success akışlarında temizlenir.
  Map<String, CabinExpectedEpc> _expectedMap = const <String, CabinExpectedEpc>{};

  /// Saving sırasında çekmece kapandıysa true. Kayıt sonucu gelince
  /// (_completeRefill) değerlendirilir: OK → doğrudan Success, hata → Error.
  // ignore: unused_field
  bool _closedDuringSaving = false;

  @override
  MobileCensusState build() {
    _drawer = MobileDrawerOrchestrator(ref: ref)
      ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);

    ref.onDispose(() => _drawer.dispose());

    return const MobileCensusUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    final mobileSlots = data.mobileSlots;

    state = MobileCensusLoading(slots: slots, cabinId: data.cabinId);

    final assignmentResult = await _getAssignments.call(data.cabinId);

    state = assignmentResult.when(
      ok: (assignments) =>
          MobileCensusIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
      error: (e) => MobileCensusError(
        message: e.message,
        previousState: MobileCensusIdle(
          slots: slots,
          mobileSlots: mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      ),
    );
  }

  /// Panel'deki hasta listesinden bir hasta seçildiğinde çağrılır.
  /// İlgili göze otomatik gider — mevcut [onCellTap] akışını kullanır.
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
      state = MobileCensusIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = MobileCensusSlotSelected(
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
      state = MobileCensusSlotSelected(
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
      state = MobileCensusNoPatient(
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

  /// Ready state'inden hasta listesine geri döner.
  /// Slot seçimi korunur.
  void clearPatientSelection() {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    state = MobileCensusSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  void onDatePresetChanged(DateRangePreset preset) {
    final current = state;
    if (current is! MobileCensusReady) return;
    state = current.copyWith(datePreset: preset);
    _reloadPrescriptions();
  }

  void onStatusFilterChanged(PrescriptionMovementType? type) {
    final current = state;
    if (current is! MobileCensusReady) return;
    state = current.copyWith(statusFilter: type, clearStatusFilter: type == null);
    _reloadPrescriptions();
  }

  /// İlaç işaretle / işareti kaldır.
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileCensusReady) return;

    // RFID'li item'lar sadece okuyucu tarafından seçilir/kaldırılır.
    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item?.rfidTag != null) {
      MedLogger.warn(
        unit: 'MobileCensusNotifier',
        swreq: 'SWREQ-CLI-CENSUS-006',
        message: 'RFID etiketli ilaç için manuel seçim engellendi',
        context: {'itemId': itemId},
      );
      return;
    }

    if (item?.status != PrescriptionMovementType.purchasePending) {
      return;
    }

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  Future<void> _reloadPrescriptions() async {
    final current = state;
    if (current is! MobileCensusReady) return;

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
      error: (e) => state = MobileCensusError(message: e.message, previousState: current),
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

    state = MobileCensusLoading(
      slots: slots,
      cabinId: cabinId,
      selectedSlot: selectedSlot,
      mobileSlots: mobileSlots,
      assignments: assignments,
    );

    final result = await _getPrescriptionHistory.call(
      patient!.id!,
      params: PagedQueryParamsBuilder.fromPreset(
        preset: DateRangePreset.today,
        filters: [Filter.eq('lastMovement.detailStatusId', PrescriptionMovementType.purchasePending.id)],
      ),
    );

    result.when(
      ok: (items) {
        state = MobileCensusReady(
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
        state = MobileCensusError(
          message: e.message,
          previousState: MobileCensusNoPatient(
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

  /// Sayıma başla — check YOK, direkt çekmece aç.
  ///
  /// [MobileDrawerOrchestrator.open] çağrılır; RFID session
  /// orchestrator tarafından çekmece açılınca başlatılır.
  ///
  /// SWREQ-CLI-CENSUS-002
  Future<void> startCensus() async {
    final current = state;
    if (current is! MobileCensusReady) return;

    state = MobileCensusDrawerOpening(ready: current.copyWith(baselineCompleted: false));

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmece açıldıktan sonra baseline snapshot alır ve reconciliation yapar.
  ///
  /// Sayımda seçim yoktur — tüm kabin doğrulanır:
  ///   - matched (EXPECTED ∩ OBSERVED) → rfidReadEpcs (kabinde, beklendiği gibi)
  ///   - missing (EXPECTED ∖ OBSERVED) → missingEpcs (olması gereken yok → eksik)
  ///   - excess  (OBSERVED ∖ EXPECTED) → excessEpcs  (olmaması gereken var → fazla)
  ///
  /// Sonrasında baselineCompleted = true ile state güncellenir.
  ///
  /// SWREQ-CLI-CENSUS-009
  Future<void> _scanCabin() async {
    final current = state;
    if (current is MobileCensusError) return;

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
      state = MobileCensusError(message: errorMessage!, previousState: ready);
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
      state = const MobileCensusIdle(slots: [], mobileSlots: [], assignments: [], cabinId: 0);
      return;
    }

    // Sahne KORUNUR — slot/hasta listesi ekranda kalır
    state = MobileCensusIdle(
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
    state = MobileCensusDrawerOpening(ready: reopening);

    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  void addExtraStock({required Medicine medicine, required double quantity}) {
    final current = state;
    if (current is! MobileCensusReady) return;
    if (quantity <= 0) return;

    final existing = current.extraStocks.firstWhereOrNull((e) => e.medicine.id == medicine.id);
    if (existing != null) {
      // aynı ilaç → miktarı güncelle
      state = current.copyWith(
        extraStocks: current.extraStocks
            .map((e) => e.medicine.id == medicine.id ? e.copyWith(quantity: e.quantity + quantity) : e)
            .toList(),
      );
      return;
    }

    final entry = CensusExtraStock(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      medicine: medicine,
      quantity: quantity,
    );

    state = current.copyWith(extraStocks: [...current.extraStocks, entry]);
  }

  void removeExtraStock(String localId) {
    final current = state;
    if (current is! MobileCensusReady) return;
    state = current.copyWith(extraStocks: current.extraStocks.where((e) => e.localId != localId).toList());
  }

  /// RFID'siz bir item'ı "eksik" olarak işaretler / işareti kaldırır.
  /// Servise GİTMEZ — complete anında toplu gönderilir (skill §2).
  ///
  /// SWREQ-CLI-CENSUS-007
  void toggleMissingMark(int prescriptionItemId) {
    final current = state;
    final ready = current.readyContext;
    if (ready == null) return;

    final marked = ready.markedMissingItemIds;
    final next = marked.contains(prescriptionItemId)
        ? (Set<int>.from(marked)..remove(prescriptionItemId))
        : {...marked, prescriptionItemId};

    state = _withReady(current, ready.copyWith(markedMissingItemIds: next));
  }

  /// Sayımı tamamla — çekmece kapalı + [MobileCensusReady.canComplete] true olmalı.
  ///
  /// canComplete koşulu:
  ///   - RFID'li item: EPC'si rfidReadEpcs'te olmalı (şu an okunuyor)
  ///   - RFID'siz item: seçili olması yeterli
  ///
  /// SWREQ-CLI-CENSUS-003
  Future<void> completeCensus() async {
    final current = state;
    if (current is! MobileCensusReady) return;
    if (!current.canComplete) return;

    if (_drawerStage is! MobileDrawerOpened) return;

    state = MobileCensusSaving(ready: current);

    // 1) Asıl sayım kaydı — "alım bekliyor" tüm item'lar.
    //    RFID'li item kabinde okunduysa (rfidReadEpcs) sayıldı → epc + dosePiece,
    //    okunmadıysa (missing) sayılamadı → dosePiece 0.
    final params = current.prescriptionItems
        .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending)
        .map((i) {
          final epc = i.rfidTag;
          final counted = epc != null && current.rfidReadEpcs.contains(epc);
          return MobileCensusParams(
            prescriptionDetailId: i.id!,
            dosePiece: counted ? i.dosePiece?.toDouble() : 0,
            epc: counted ? epc : null,
          );
        })
        .toList();

    final result = await _completeCensus(params);

    await result.when(
      ok: (_) async {
        // WaitingClose → drawer fiziksel kapanınca _onDrawerStageChange Success yapar.
        state = MobileCensusWaitingClose(ready: current);
      },
      error: (e) async {
        // Kayıt FAIL — RFID state KORUNUR, drawer açık, retry edilebilir
        state = MobileCensusError(message: e.message, previousState: current);
      },
    );
  }

  /// Error → "Tekrar Dene". Çekmece açık; kaydı yeniden dener (reopen YOK).
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileCensusError) return;
    final ready = current.previousState.readyContext;
    if (ready == null) return;

    state = ready;
    await completeCensus();
  }

  Future<void> _reportUnplannedMovements(MobileCensusReady ready, Map<String, CabinExpectedEpc> expectedMap) async {
    // a) Otomatik eksik — missingEpcs → prescriptionItemId (EXPECTED_MAP'ten)
    for (final epc in ready.missingEpcs) {
      final itemId = expectedMap[epc]?.prescriptionItem?.id;
      if (itemId == null) continue;
      final r = await _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.census);
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileCensusNotifier',
          swreq: 'SWREQ-CLI-CENSUS-008',
          message: 'otomatik eksik bildirimi başarısız (retry yok)',
          context: {'itemId': itemId, 'epc': epc, 'error': r.error.message},
        );
      }
    }

    // b) Manuel eksik — markedMissingItemIds (RFID'siz item'lar)
    for (final itemId in ready.markedMissingItemIds) {
      final r = await _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.census);
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileCensusNotifier',
          swreq: 'SWREQ-CLI-CENSUS-008',
          message: 'manuel eksik bildirimi başarısız (retry yok)',
          context: {'itemId': itemId, 'error': r.error.message},
        );
      }
    }

    // c) Manuel fazla — extraStocks (hospitalizationId + medicineId + quantity)
    //    Otomatik fazla (excessEpcs) bildirilMEZ: EPC bilinen bir ilaca ait değil,
    //    medicineId çözülemez → yalnızca UI uyarısı.
    final hospitalizationId = _resolveHospitalizationId(ready);
    for (final extra in ready.extraStocks) {
      final r = await _reportExcessStock(
        params: ReportExcessStockParams(
          hospitalizationId: hospitalizationId,
          medicineId: extra.medicine.id,
          quantity: extra.quantity,
        ),
        type: CabinInventoryType.census,
      );
      if (r is Error) {
        MedLogger.error(
          unit: 'MobileCensusNotifier',
          swreq: 'SWREQ-CLI-CENSUS-008',
          message: 'manuel fazla bildirimi başarısız (retry yok)',
          context: {'medicineId': extra.medicine.id, 'qty': extra.quantity, 'error': r.error.message},
        );
      }
    }
  }

  /// EPC okundu — çekmecede tag göründü.
  ///
  /// Sayım semantiği (baseline-derived, bidirectional):
  ///   - Baseline öncesi → ignore (snapshot çalışıyor, okunan her şey kabin malı)
  ///   - Baseline'daki tag geri okundu → baselineLostEpcs'ten çıkar (geri kondu)
  ///   - Baseline'da yok, yeni tag → placedEpcs'e ekle
  ///       (getter'da: expectedMap'te varsa PASSIVE/sessiz, yoksa UNEXPECTED/blokaj)
  ///
  /// SWREQ-CLI-CENSUS-004
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
  /// Sayım semantiği (baseline-derived):
  ///   - Baseline öncesi → ignore
  ///   - Baseline'daki tag çıktı → baselineLostEpcs'e ekle
  ///       (getter'da: seçiliyse missing/taken, seçili değilse unplanned)
  ///   - placedEpcs (sonradan konan yabancı) çıktı → sil (düzeltici, bildirim YOK,
  ///       unexpected blokajı kalkar)
  ///   - Bilinmiyor → ignore
  ///
  /// SWREQ-CLI-CENSUS-005
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
        MobileCensusDrawerOpening(:final ready) => ready,
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
        case MobileCensusWaitingClose(:final ready):
          final expectedSnapshot = Map<String, CabinExpectedEpc>.of(_expectedMap);
          unawaited(_reportUnplannedMovements(ready, expectedSnapshot));
          unawaited(_drawer.stop());
          state = MobileCensusSuccess(ready: ready.clearedRfidState);
          _resetExpectedMap();

        // Kayıt uçuşta kapandı → flag'le; Saving çözülünce değerlendir
        case MobileCensusSaving():
          _closedDuringSaving = true;

        // Tamamla denmeden kapandı → kullanıcıya karar sor
        case MobileCensusReady r:
          state = MobileCensusClosedEarly(ready: r);

        default:
          break;
      }
    }

    // ── Çekmece donanım hatası → kurtarılamaz, FatalError ────────────────
    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileCensusReady r => r.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileCensusDrawerOpening(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileCensusSaving(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileCensusWaitingClose(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileCensusClosedEarly(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        _ => current,
      };
      state = MobileCensusFatalError(message: next.message, previousState: cleaned);
    }
  }

  void dismissError() {
    final current = state;
    final previous = switch (current) {
      MobileCensusError(:final previousState) => previousState,
      MobileCensusFatalError(:final previousState) => previousState,
      _ => null,
    };
    if (previous == null) return;

    unawaited(_drawer.stop());
    _resetExpectedMap();

    // previousState'ten gerçek Ready'yi çıkar — wrapper/NoPatient olabilir.
    final ready = previous.readyContext;
    state = ready ?? previous;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileCensusSuccess) return;
    state = MobileCensusIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. RFID event'i işlenmemesi gereken state'ler değişmeden döner.
  MobileCensusState _withReady(MobileCensusState s, MobileCensusReady ready) => switch (s) {
    MobileCensusReady _ => ready,
    MobileCensusDrawerOpening _ => MobileCensusDrawerOpening(ready: ready),
    MobileCensusSaving _ => MobileCensusSaving(ready: ready),
    MobileCensusWaitingClose _ => MobileCensusWaitingClose(ready: ready),
    MobileCensusClosedEarly _ => MobileCensusClosedEarly(ready: ready),
    MobileCensusSuccess _ => MobileCensusSuccess(ready: ready),
    _ => s,
  };

  /// Seçili gözün (hastanın) hospitalization id'si — manuel fazla stok bildirimi
  /// bu hasta bağlamında gönderilir.
  int? _resolveHospitalizationId(MobileCensusReady ready) {
    final assignment = ready.assignmentByCoord[ready.selectedCell];
    return assignment?.hospitalization?.id;
  }

  void _resetExpectedMap() {
    _expectedMap = const <String, CabinExpectedEpc>{};
  }
}
