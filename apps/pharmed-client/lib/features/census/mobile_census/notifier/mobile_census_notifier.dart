import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
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

  /// Sayıma başla — check YOK, direkt çekmece aç.
  ///
  /// [MobileDrawerOrchestrator.open] çağrılır; RFID session
  /// orchestrator tarafından çekmece açılınca başlatılır.
  ///
  /// SWREQ-CLI-CENSUS-002
  Future<void> startCensus() async {
    final current = state;
    if (current is! MobileCensusReady) return;

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmeceyi tekrar aç — RFID eksikse "Sayıma Devam Et" butonuna bağlanır.
  Future<void> reopenDrawer() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  void onReportExtraStockTap() {
    // Bir sonraki turda implement edeceğiz.
    // İlaç seçim dialog'u açacak.
    MedLogger.info(
      unit: 'MobileCensusNotifier',
      swreq: 'SWREQ-CLI-CENSUS-005',
      message: 'Fazla stok bildirimi başlatıldı',
    );
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

    MedLogger.info(
      unit: 'MobileCensusNotifier',
      swreq: 'SWREQ-CLI-CENSUS-005',
      message: 'Fazla stok eklendi',
      context: {'medicineId': medicine.id, 'quantity': quantity},
    );
  }

  void removeExtraStock(String localId) {
    final current = state;
    if (current is! MobileCensusReady) return;
    state = current.copyWith(extraStocks: current.extraStocks.where((e) => e.localId != localId).toList());
  }

  /// Sayımı iptal et.
  ///
  /// - DrawerIdle + seçim var → seçimleri sıfırla
  /// - DrawerOpening/Opened → snackbar (view handle eder)
  /// - Diğer durumlarda → session durdur, seçimleri sıfırla
  Future<void> cancelCensus() async {
    final current = state;
    final ready = switch (current) {
      MobileCensusReady r => r,
      MobileCensusSaving(:final ready) => ready,
      _ => null,
    };

    final stage = _drawerStage;

    if (stage is MobileDrawerIdle) {
      if (ready == null) return;
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {});
      return;
    }

    await _drawer.stop();

    if (ready != null) {
      state = ready.copyWith(selectedItemIds: {}, rfidReadEpcs: {});
    }
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

    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerClosed) return;

    state = MobileCensusSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    // 1) Asıl sayım kaydı — seçim yok, "alım bekliyor" tüm item'lar.
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
        await _drawer.stop();
        final expectedSnapshot = _expectedMap;
        _resetExpectedMap();

        unawaited(_dispatchCensusNotifications(current, expectedSnapshot));

        state = MobileCensusSuccess(
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
        // Kayıt FAIL — RFID state KORUNUR, drawer açık, retry edilebilir
        state = MobileCensusError(message: e.message, previousState: current);
      },
    );
  }

  Future<void> _dispatchCensusNotifications(MobileCensusReady ready, Map<String, CabinExpectedEpc> expectedMap) async {
    // a) Otomatik eksik — missingEpcs → prescriptionItemId (EXPECTED_MAP'ten)
    for (final epc in ready.missingEpcs) {
      final itemId = expectedMap[epc]?.prescriptionItem?.id;
      if (itemId == null) continue;
      await _safeReport(
        () => _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.census),
        label: 'otomatik eksik',
        ctx: {'itemId': itemId, 'epc': epc},
      );
    }

    // b) Manuel eksik — markedMissingItemIds (RFID'siz item'lar)
    for (final itemId in ready.markedMissingItemIds) {
      await _safeReport(
        () => _reportMissingStock(prescriptionItemId: itemId, type: CabinInventoryType.census),
        label: 'manuel eksik',
        ctx: {'itemId': itemId},
      );
    }

    // c) Manuel fazla — extraStocks (hospitalizationId + medicineId + quantity)
    //    Otomatik fazla (excessEpcs) bildirilMEZ: EPC bilinen bir ilaca ait değil,
    //    medicineId çözülemez → yalnızca UI uyarısı.
    final hospitalizationId = _resolveHospitalizationId(ready);
    for (final extra in ready.extraStocks) {
      await _safeReport(
        () => _reportExcessStock(
          params: ReportExcessStockParams(
            hospitalizationId: hospitalizationId,
            medicineId: extra.medicine.id,
            quantity: extra.quantity,
          ),
          type: CabinInventoryType.census,
        ),
        label: 'manuel fazla',
        ctx: {'medicineId': extra.medicine.id, 'qty': extra.quantity},
      );
    }
  }

  Future<void> _safeReport(
    Future<Result<void>> Function() call, {
    required String label,
    required Map<String, dynamic> ctx,
  }) async {
    final r = await call();
    if (r is Error) {
      MedLogger.error(
        unit: 'MobileCensusNotifier',
        swreq: 'SWREQ-CLI-CENSUS-008',
        message: '$label bildirimi başarısız (retry yok)',
        context: {...ctx, 'error': r.error.message},
      );
    }
  }

  /// EPC okundu — çekmecede tag göründü.
  ///
  /// Sayım semantiği (doğrulama):
  ///   - Baseline öncesi → ignore (snapshot çalışıyor)
  ///   - missingEpcs'te → geç okundu, matched'a dön (rfidReadEpcs'e ekle)
  ///   - excessEpcs'te → zaten fazla, dedup (kalıcı, kabinde duruyor)
  ///   - rfidReadEpcs'te → dedup
  ///   - İlk kez görüldü → EXPECTED'a göre sınıflandır:
  ///       EXPECTED'da var → rfidReadEpcs (matched)
  ///       EXPECTED'da yok → excessEpcs (fazla — kullanıcı yanlışlıkla koymuş olabilir)
  ///
  /// SWREQ-CLI-CENSUS-004
  void _onEpcRead(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // Zaten bilinen aktif kümede mi? dedup
    if (ready.rfidReadEpcs.contains(epc) || ready.excessEpcs.contains(epc)) return;

    Set<String> newRead = ready.rfidReadEpcs;
    Set<String> newMissing = ready.missingEpcs;
    Set<String> newExcess = ready.excessEpcs;

    if (ready.missingEpcs.contains(epc)) {
      // Eksik sanılan tag geç okundu → matched'a dön
      newMissing = Set<String>.from(newMissing)..remove(epc);
      newRead = {...newRead, epc};
    } else if (_expectedMap.containsKey(epc)) {
      // İlk kez, beklenen → matched
      newRead = {...newRead, epc};
    } else {
      // İlk kez, beklenmeyen → fazla
      newExcess = {...newExcess, epc};
    }

    state = _withReady(current, ready.copyWith(rfidReadEpcs: newRead, missingEpcs: newMissing, excessEpcs: newExcess));

    MedLogger.info(
      unit: 'MobileCensusNotifier',
      swreq: 'SWREQ-CLI-CENSUS-004',
      message: 'EPC okundu (baseline sonrası)',
      context: {'epc': epc},
    );
  }

  /// EPC kayboldu — çekmeceden tag çıktı.
  ///
  /// Sayım semantiği (doğrulama):
  ///   - Baseline öncesi → ignore
  ///   - rfidReadEpcs'te (matched) → missingEpcs'e geç (beklenen ilaç kabinden çıktı)
  ///   - excessEpcs'te → sessiz çıkar (kullanıcı fazla ilacı aldı → düzeltici, bildirim YOK)
  ///   - Bilinmiyor → ignore
  ///
  /// SWREQ-CLI-CENSUS-005
  void _onEpcLost(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // MATCHED → MISSING (beklenen ilaç kabinden çıktı → eksik)
    if (ready.rfidReadEpcs.contains(epc)) {
      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);
      final newMissing = {...ready.missingEpcs, epc};
      state = _withReady(current, ready.copyWith(rfidReadEpcs: newRead, missingEpcs: newMissing));

      MedLogger.info(
        unit: 'MobileCensusNotifier',
        swreq: 'SWREQ-CLI-CENSUS-005',
        message: 'Beklenen EPC kabinden çıktı — eksik',
        context: {'epc': epc},
      );
      return;
    }

    // EXCESS → sessiz çıkar (eczacı fazla ilacı aldı, düzeltici)
    if (ready.excessEpcs.contains(epc)) {
      final newExcess = Set<String>.from(ready.excessEpcs)..remove(epc);
      state = _withReady(current, ready.copyWith(excessEpcs: newExcess));

      MedLogger.info(
        unit: 'MobileCensusNotifier',
        swreq: 'SWREQ-CLI-CENSUS-005',
        message: 'Fazla EPC kabinden alındı — düzeltici, yoksayıldı',
        context: {'epc': epc},
      );
      return;
    }

    // Bilinmiyor — ignore
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    // Çekmece açıldı → baseline snapshot al, reconciliation yap
    if (next is MobileDrawerOpened) {
      unawaited(_performBaselineScan());
    }

    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileCensusReady r => r.clearedRfidState,
        MobileCensusSaving(:final ready) => ready.clearedRfidState,
        _ => current,
      };
      state = MobileCensusError(message: next.message, previousState: cleaned);
    }
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
          rfidReadEpcs: const {},
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

  /// RFID'siz bir item'ı "eksik" olarak işaretler / işareti kaldırır.
  /// Servise GİTMEZ — complete anında toplu gönderilir (skill §2).
  ///
  /// SWREQ-CLI-CENSUS-007
  void toggleMissingMark(int prescriptionItemId) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;

    final marked = ready.markedMissingItemIds;
    final next = marked.contains(prescriptionItemId)
        ? (Set<int>.from(marked)..remove(prescriptionItemId))
        : {...marked, prescriptionItemId};

    state = _withReady(current, ready.copyWith(markedMissingItemIds: next));
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
  Future<void> _performBaselineScan() async {
    final current = state;
    if (current is MobileCensusError) return;

    final ready = _readyOf(current);
    if (ready == null) return;

    // 1) Beklenen kabin tag'lerini çek
    final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);

    List<CabinExpectedEpc>? expected;
    String? errorMessage;

    expectedResult.when(ok: (value) => expected = value, error: (e) => errorMessage = e.message);

    if (errorMessage != null) {
      state = MobileCensusError(message: errorMessage!, previousState: ready);
      return;
    }

    _expectedMap = {for (final e in expected!) (e.rfidTag ?? ''): e};
    final expectedSet = _expectedMap.keys.toSet();

    // 2) Snapshot al
    final observed = await _drawer.snapshot();

    // 3) Race condition guard
    final after = state;
    final afterReady = _readyOf(after);
    if (afterReady == null) return;

    // 4) Reconciliation — sayım semantiği (seçim yok, tüm kabin)
    final matched = expectedSet.intersection(observed); // beklenen & kabinde
    final missing = expectedSet.difference(observed); // beklenen ama yok → otomatik eksik
    final excess = observed.difference(expectedSet); // beklenmeyen ama var → otomatik fazla

    final updatedReady = afterReady.copyWith(
      baselineCompleted: true,
      rfidReadEpcs: matched,
      missingEpcs: missing,
      excessEpcs: excess,
    );

    state = _withReady(after, updatedReady);
  }

  /// Error sonrası sayımı yeniden dener — completeCensus'u baştan çalıştırır.
  /// Çekmece kapalı, RFID/baseline state korunmuş durumda; dokunulmaz.
  ///
  /// SWREQ-CLI-CENSUS-003
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileCensusError) return;

    final previous = current.previousState;
    if (previous is! MobileCensusReady) return;

    // previousState'i geri yükle, completeCensus baştan çalışsın
    state = previous;
    await completeCensus();
  }

  void dismissError() {
    final current = state;
    if (current is! MobileCensusError) return;
    state = current.previousState;
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

  MobileCensusReady? _readyOf(MobileCensusState s) => switch (s) {
    MobileCensusReady r => r,
    MobileCensusSaving(:final ready) => ready,
    MobileCensusSuccess(:final ready) => ready,
    MobileCensusError(:final previousState) => _readyOf(previousState),
    _ => null,
  };

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  MobileCensusState _withReady(MobileCensusState s, MobileCensusReady ready) => switch (s) {
    MobileCensusReady _ => ready,
    MobileCensusSaving w => MobileCensusSaving(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
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
