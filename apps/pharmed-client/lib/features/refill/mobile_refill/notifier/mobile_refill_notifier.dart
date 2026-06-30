import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../refill.dart';

// [SWREQ-CLI-REFILL-004] [IEC 62304 §5.5]
// Mobil kabin ilaç dolum ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Dolum başlatma → çekmece açar → baseline RFID snapshot alır
//   - Baseline sonrası reconciliation kümelerini kurar (rfid-stock-notifications §3)
//   - Canlı RFID read/lost event'leriyle kümeleri güncel tutar (bidirectional)
//   - Dolum tamamlama → KAYIT ÖNCE, ardından fire-and-forget bildirim akışı (§7)
//
// İlişkili dosyalar:
//   - mobile_refill_state.dart   → state hiyerarşisi
//   - mobile_refill_panel.dart   → sağ panel (action bar, prescription listesi)
//   - mobile_refill_view.dart    → root view (scaffold + snackbar handling)
//
// Skill referansları:
//   - rfid-stock-notifications   → bildirim akışı, reconciliation matematiği
//   - pharmed-rfid-entegrasyonu  → orchestrator + RfidScanSession API'leri
//
// Sınıf: Class B

final mobileRefillNotifierProvider = NotifierProvider<MobileRefillNotifier, MobileRefillState>(
  MobileRefillNotifier.new,
);

class MobileRefillNotifier extends Notifier<MobileRefillState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  GetCabinExpectedEpcsUseCase get _getCabinExpectedEpcs => ref.read(getCabinExpectedEpcsUseCaseProvider);
  RefillMobileCabinUseCase get _refillMobileCabin => ref.read(refillMobileCabinUseCaseProvider);

  /// Eksik Stok Bildirimi — UNPLANNED EPC'leri için backend'e bildirir.
  /// Dolum'da `CabinInventoryType.refill` ile çağrılır.
  ReportMissingStockUseCase get _reportMissingStock => ref.read(reportMissingStockUseCaseProvider);

  // ── EXPECTED_MAP (§3) ───────────────────────────────────────────────────
  // Baseline scan'in yan ürünü; reconciliation kümeleri kurulurken ve
  // bildirim üretirken (EPC → itemId/materialId çözümü) kullanılır.
  // State class'larında tutulmaz çünkü boyutu büyüyebilir ve reactive UI'a
  // ihtiyaç duyulmaz. cancel/error/success akışlarında temizlenir.
  Map<String, CabinExpectedEpc> _expectedMap = const <String, CabinExpectedEpc>{};

  @override
  MobileRefillState build() {
    // Drawer + RFID composition. Callback'ler operasyon semantiğine göre
    // küme geçişlerini yönetir.
    _drawer = MobileDrawerOrchestrator(ref: ref)
      ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);
    ref.onDispose(() => _drawer.dispose());

    return const MobileRefillUninitialized();
  }

  /// Ekran açıldıktan sonra view tarafından bir kez çağrılır.
  /// Cabin verisinden slot/mobileSlot listesini çıkarır ve atamaları yükler.
  ///
  /// SWREQ-CLI-REFILL-001
  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    final mobileSlots = data.mobileSlots;

    state = MobileRefillLoading(slots: slots, cabinId: data.cabinId);

    final assignmentResult = await _getAssignments.call(data.cabinId);

    state = assignmentResult.when(
      ok: (assignments) =>
          MobileRefillIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
      error: (e) => MobileRefillError(
        message: e.message,
        previousState: MobileRefillIdle(
          slots: slots,
          mobileSlots: mobileSlots,
          assignments: const [],
          cabinId: data.cabinId,
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Hasta / göz seçimi
  // ═════════════════════════════════════════════════════════════════════════

  /// Sol panel'deki hasta listesinden bir hasta seçildiğinde çağrılır.
  /// İlgili göze otomatik gider — mevcut [onCellTap] akışını kullanır.
  ///
  /// SWREQ-CLI-REFILL-001
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

  /// Slot tıklandığında çağrılır. Aynı slot ikinci kez tıklanırsa seçim
  /// iptal edilir (toggle).
  ///
  /// SWREQ-CLI-REFILL-001
  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedSlotId == slot.slotId) {
      state = MobileRefillIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = MobileRefillSlotSelected(
      slots: slots,
      mobileSlots: ms,
      selectedSlot: slot,
      assignments: assignments,
      cabinId: cabinId,
    );
  }

  /// Göz tıklandığında çağrılır. Hasta varsa reçeteleri yükler, yoksa
  /// NoPatient'a geçer. Aynı göz ikinci kez tıklanırsa seçim iptal edilir.
  ///
  /// SWREQ-CLI-REFILL-001
  Future<void> onCellTap(MobileCellCoord coord) async {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    if (current.selectedCell == coord) {
      state = MobileRefillSlotSelected(
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
      state = MobileRefillNoPatient(
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

  /// Ready/NoPatient state'inden hasta listesine geri döner.
  /// Slot seçimi korunur (kullanıcı aynı çekmecedeyse devam edebilir).
  ///
  /// SWREQ-CLI-REFILL-001
  void clearPatientSelection() {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    state = MobileRefillSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Reçete yükleme / filtreleme
  // ═════════════════════════════════════════════════════════════════════════

  /// SWREQ-CLI-REFILL-001
  void onDatePresetChanged(DateRangePreset preset) {
    final current = state;
    if (current is! MobileRefillReady) return;
    state = current.copyWith(datePreset: preset);
    _reloadPrescriptions();
  }

  /// SWREQ-CLI-REFILL-001
  void onStatusFilterChanged(PrescriptionMovementType? type) {
    final current = state;
    if (current is! MobileRefillReady) return;
    state = current.copyWith(statusFilter: type, clearStatusFilter: type == null);
    _reloadPrescriptions();
  }

  /// İlaç işaretle/işareti kaldır.
  ///
  /// SWREQ-CLI-REFILL-001
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileRefillReady) return;

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || !(item.status?.canFill ?? false)) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  /// Filtre değişikliklerinde reçete listesini yeniden çeker.
  /// Seçimi sıfırlar — eski seçim yeni listede olmayabilir.
  ///
  /// SWREQ-CLI-REFILL-001
  Future<void> _reloadPrescriptions() async {
    final current = state;
    if (current is! MobileRefillReady) return;

    final result = await _getPrescriptionHistory.call(
      current.patient.id!,
      params: PagedQueryParamsBuilder.fromPreset(
        preset: current.datePreset,
        filters: [if (current.statusFilter != null) Filter.eq('lastMovement.detailStatusId', current.statusFilter!.id)],
      ),
    );

    result.when(
      ok: (items) => state = current.copyWith(prescriptionItems: items, selectedItemIds: {}),
      error: (e) => state = MobileRefillError(message: e.message, previousState: current),
    );
  }

  /// Yeni bir göz seçildiğinde o hastanın reçetelerini yükler.
  /// Loading sırasında sol/orta panel kaybolmasın diye [MobileRefillLoading]'e
  /// slot/mobileSlots/assignments dolu olarak geçilir.
  ///
  /// SWREQ-CLI-REFILL-001
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

    state = MobileRefillLoading(
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
        filters: [Filter.eq('lastMovement.detailStatusId', PrescriptionMovementType.filledWaiting.id)],
      ),
    );

    result.when(
      ok: (items) {
        state = MobileRefillReady(
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
        state = MobileRefillError(
          message: e.message,
          previousState: MobileRefillNoPatient(
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

  // ═════════════════════════════════════════════════════════════════════════
  // Dolum süreci — start / reopen / cancel
  // ═════════════════════════════════════════════════════════════════════════

  /// Doluma başla → orchestrator'a çekmece açma komutu gönderir.
  ///
  /// Akış:
  ///   1. state = DrawerStarting (ready ile sarmalanır)
  ///   2. _drawer.open() çağrılır
  ///   3. Stage Opening → Opened geçişinde [_onDrawerStageChange] ready'e döner
  ///   4. Opened anında [_performBaselineScan] tetiklenir
  ///
  /// SWREQ-CLI-REFILL-001
  Future<void> startRefill() async {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (current.selectedItemIds.isEmpty) return;

    state = MobileRefillDrawerOpening(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmeceyi tekrar aç — "Doluma Devam Et" butonuna bağlanır.
  ///
  /// İki durumda gerekli (rfid-stock-notifications §4 reopen akışı):
  ///   - RFID eksik (allSelectedRfidRead false): kullanıcı yerleştirmeye devam edecek
  ///   - UNEXPECTED blokajı: kullanıcı kabin stoğuna ait olmayan tag'i çıkaracak
  ///
  /// Davranış:
  ///   - RFID state TAMAMEN sıfırlanır (yeni baseline alınacak)
  ///   - selectedItemIds KORUNUR — kullanıcı yeniden seçmek zorunda kalmasın
  ///   - EXPECTED_MAP temizlenir (baseline tekrar çekecek)
  ///
  /// SWREQ-CLI-REFILL-012
  Future<void> reopenDrawer() async {
    final current = state;
    if (current is MobileRefillReady) {
      state = current.clearedRfidState;
    }
    _resetExpectedMap();
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Dolum iptali — drawer durumuna göre farklı davranır:
  ///
  ///   - DrawerIdle (henüz başlamadı) → seçimleri sıfırla, drawer'a dokunma
  ///   - DrawerOpening/Opened (yerleştirme var) → view handle eder (confirm dialog)
  ///   - Error state'inde → RFID state'ini KORUYARAK iptal et (kullanıcı ilaçlarını alabilir)
  ///   - Diğer (Closed/Failed veya hareket yok) → drawer.stop() + tüm state sıfırla
  ///
  /// SWREQ-CLI-REFILL-001
  Future<void> cancelRefill() async {
    final current = state;
    final ready = _readyOf(current);
    final stage = _drawerStage;

    // Drawer hiç açılmadı: sadece seçimleri ve RFID kümelerini sıfırla
    if (stage is MobileDrawerIdle) {
      if (ready == null) return;
      state = ready.clearedRfidState.copyWith(selectedItemIds: const {});
      return;
    }

    // Drawer açık/açılıyor + en az bir tag yerleştirilmiş → view confirm dialog
    // gösterir, biz cancel yapmayız (return)
    if ((stage is MobileDrawerOpening || stage is MobileDrawerOpened) && (ready?.rfidReadCount ?? 0) > 0) {
      return;
    }

    // Drawer durumu fail veya hiç hareket yok → tam temizlik
    await _drawer.stop();
    _resetExpectedMap();

    if (ready != null) {
      state = ready.clearedRfidState.copyWith(selectedItemIds: const {});
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Drawer stage callback
  // ═════════════════════════════════════════════════════════════════════════

  /// Orchestrator'ın drawer stage callback'i.
  ///
  /// Olaylar (rfid-stock-notifications §4):
  ///   - Opened ilk geçiş      → DrawerStarting ise Ready'e dön + baseline başlat
  ///   - Closed/Failed         → orchestrator zaten RFID'yi durdurur
  ///   - Failed                → tüm RFID + seçim state'i sıfırla, Error state
  ///
  /// SWREQ-CLI-REFILL-001
  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerOpened) {
      final current = state;
      // Normal akış: DrawerStarting → Ready, ardından baseline scan
      if (current is MobileRefillDrawerOpening) {
        state = current.ready;
        unawaited(_performBaselineScan());
      }
      // RollbackInProgress'te baseline scan YAPILMAZ — RFID state korunur,
      // kullanıcı çıkardıkça _onEpcLost rfidReadEpcs'i azaltır.
    }

    if (next is MobileDrawerClosed) {
      final current = state;
      if (current is MobileRefillRollbackInProgress) {
        if (current.ready.rfidReadEpcs.isEmpty) {
          // Tüm yerleştirilen tag'ler kabinden çıkartıldı → rollback tamam
          unawaited(_finalizeRollback(current));
        }
        // else: kabinde tag var, state aynı kalır. Dialog footer'ı
        // "Çekmeceyi Aç" / "Tekrar Dene" butonlarını gösterir.
      }
    }

    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileRefillReady r => r.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileRefillDrawerOpening(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        _ => current,
      };
      // Çekmece donanım hatası → kurtarılamaz, FatalError
      state = MobileRefillFatalError(message: next.message, previousState: cleaned);
    }
  }

  /// Rollback başarıyla tamamlandı — drawer + RFID temizliği yapar ve
  /// state'i [MobileRefillRollbackCompleted]'e geçirir.
  ///
  /// Dialog `readyContext` null gördüğü için kendiliğinden kapanır.
  /// Sonrasında state Idle'a çekilir ki kullanıcı yeni bir dolum
  /// başlatabilsin (dialog dispose olduktan sonra).
  ///
  /// SWREQ-CLI-REFILL-014
  Future<void> _finalizeRollback(MobileRefillRollbackInProgress current) async {
    MedLogger.info(
      unit: 'MobileRefillNotifier',
      swreq: 'SWREQ-CLI-REFILL-014',
      message: 'Rollback tamamlandı — tüm tag\'ler kabinden çıkartıldı',
      context: {
        'previouslyPlacedCount': current.ready.previouslyPlacedEpcs.length,
        'unplannedCount': current.ready.unplannedMovements.length,
      },
    );

    await _drawer.stop();
    _resetExpectedMap();

    state = MobileRefillRollbackCompleted(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );

    // Dialog kendi kendine kapanır (readyContext null). Bir sonraki frame'de
    // state Idle'a çekilir → kullanıcı kaldığı yerden devam edebilir.
    unawaited(
      Future.microtask(() {
        final s = state;
        if (s is MobileRefillRollbackCompleted) {
          state = MobileRefillIdle(
            slots: s.slots,
            mobileSlots: s.mobileSlots,
            assignments: s.assignments,
            cabinId: s.cabinId,
          );
        }
      }),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Baseline scan + reconciliation
  // ═════════════════════════════════════════════════════════════════════════

  /// Çekmece açıldıktan sonra baseline snapshot alır ve reconciliation yapar.
  ///
  /// Akış (rfid-stock-notifications §3 + §5.1 Dolum):
  ///   1. GetCabinExpectedEpcsUseCase → EXPECTED listesi + EXPECTED_MAP
  ///   2. _drawer.snapshot(1.5s) → OBSERVED (anlık kabin tag'leri)
  ///   3. Reconciliation:
  ///        passive    = OBSERVED ∩ EXPECTED   (kabin stoğu, dolum hedefi değil)
  ///        unexpected = OBSERVED ∖ EXPECTED   (kabine ait olmayan tag → blokaj)
  ///      Dolum'da MATCHED/NOT_FOUND kümeleri YOKTUR çünkü dolum hedefi
  ///      ilaçların EPC'si henüz kabine yerleştirilmedi (yeni yerleştirme).
  ///      Baseline sonrası yerleştirilen yeni tag'ler [_onEpcRead] tarafından
  ///      rfidReadEpcs'e eklenecek.
  ///   4. baselineCompleted = true ile state güncellenir
  ///
  /// Race condition: snapshot async (1.5s); tamamlandığında state hâlâ Ready
  /// (veya sarmalayıcısı) olup olmadığı kontrol edilir — değilse atlanır.
  ///
  /// SWREQ-CLI-REFILL-006
  Future<void> _performBaselineScan() async {
    final current = state;

    if (current is MobileRefillError || current is MobileRefillRollbackInProgress) {
      return;
    }

    final ready = _readyOf(current);
    if (ready == null) return;

    // 1) Beklenen kabin tag'lerini çek
    final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);

    List<CabinExpectedEpc>? expected;
    String? errorMessage;

    expectedResult.when(ok: (value) => expected = value, error: (e) => errorMessage = e.message);

    if (errorMessage != null) {
      state = MobileRefillError(message: errorMessage!, previousState: ready);
      return;
    }

    _expectedMap = {for (final e in expected!) (e.rfidTag ?? ''): e};
    final expectedSet = _expectedMap.keys.toSet();

    // 2) Snapshot al (RFID inventory aktif, orchestrator opened sonrası başlattı)
    final observed = await _drawer.snapshot();

    // 3) Race condition guard
    final after = state;
    final afterReady = _readyOf(after);
    if (afterReady == null) {
      return;
    }

    // 4) Reconciliation kümeleri
    final passive = observed.intersection(expectedSet);
    final unexpected = observed.difference(expectedSet);

    final updatedReady = afterReady.copyWith(baselineCompleted: true, passiveEpcs: passive, unexpectedEpcs: unexpected);

    state = _withReady(after, updatedReady);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // RFID event handler'ları
  // ═════════════════════════════════════════════════════════════════════════

  /// EPC okundu — çekmecede bir tag göründü.
  ///
  /// Davranış (rfid-stock-notifications §3 bidirectional geçişler):
  ///
  ///   1. Baseline öncesi → ignore (snapshot zaten çalışıyor)
  ///   2. Hata kümesinden geri dönüş varsa → orijinal kategorisini restore et:
  ///        UNPLANNED      → PASSIVE        (kullanıcı geri koydu)
  ///        UNEXPECTED_LOST→ UNEXPECTED     (kullanıcı tekrar koydu → tekrar blokaj)
  ///   3. Hiç bilinmiyorsa (ilk kez):
  ///        EXPECTED'da var → PASSIVE       (geç gelen kabin stoğu)
  ///        EXPECTED'da yok → rfidReadEpcs  (yerleştirilen yeni dolum tag'i)
  ///   4. Zaten bilinen bir kümede → dedup, hiçbir şey yapma
  ///
  /// SWREQ-CLI-REFILL-007
  void _onEpcRead(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // 1) Hata kümelerinden çıkarmayı dene
    final wasUnplanned = ready.unplannedMovements.contains(epc);
    final wasUnexpectedLost = ready.unexpectedLostEpcs.contains(epc);

    // 2) Zaten aktif bir kümede mi? Öyleyse dedup
    final alreadyKnown =
        ready.rfidReadEpcs.contains(epc) || ready.passiveEpcs.contains(epc) || ready.unexpectedEpcs.contains(epc);

    if (!wasUnplanned && !wasUnexpectedLost && alreadyKnown) {
      return; // dedup
    }

    // 3) Sınıflandır
    Set<String> newRead = ready.rfidReadEpcs;
    Set<String> newPassive = ready.passiveEpcs;
    Set<String> newUnexpected = ready.unexpectedEpcs;
    Set<String> newUnplanned = ready.unplannedMovements;
    Set<String> newUnexpectedLost = ready.unexpectedLostEpcs;
    Set<String> newPreviouslyPlaced = ready.previouslyPlacedEpcs;

    if (wasUnplanned) {
      // PASSIVE'e geri yükle
      newUnplanned = Set<String>.from(newUnplanned)..remove(epc);
      newPassive = {...newPassive, epc};
    } else if (wasUnexpectedLost) {
      // UNEXPECTED'a geri yükle (blokaj tekrar aktif)
      newUnexpectedLost = Set<String>.from(newUnexpectedLost)..remove(epc);
      newUnexpected = {...newUnexpected, epc};
    } else {
      // İlk kez görüldü → EXPECTED'a göre sınıflandır
      if (_expectedMap.containsKey(epc)) {
        newPassive = {...newPassive, epc};
      } else {
        newRead = {...newRead, epc};
        newPreviouslyPlaced = {...newPreviouslyPlaced, epc};
      }
    }

    state = _withReady(
      current,
      ready.copyWith(
        rfidReadEpcs: newRead,
        passiveEpcs: newPassive,
        unexpectedEpcs: newUnexpected,
        unplannedMovements: newUnplanned,
        unexpectedLostEpcs: newUnexpectedLost,
        previouslyPlacedEpcs: newPreviouslyPlaced,
      ),
    );
  }

  /// EPC kayboldu — çekmeceden tag çıktı (presence timeout).
  ///
  /// Davranış (rfid-stock-notifications §5.1 Dolum):
  ///
  ///   - rfidReadEpcs'te → sessiz çıkar (kullanıcı yerleştirdiğini geri aldı)
  ///   - passiveEpcs'te  → UNPLANNED'a yaz (izinsiz çıkış → bildirim)
  ///   - unexpectedEpcs'te → UNEXPECTED_LOST'a yaz (düzeltici → bildirim YOK)
  ///   - Bilinmiyor → ignore
  ///
  /// SWREQ-CLI-REFILL-008
  void _onEpcLost(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    if (current is MobileRefillRollbackInProgress) {
      final ready = current.ready;

      // Çıkan tag'i, o anki RFID listemizden siliyoruz
      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);

      // Güncellenmiş "Ready" state'ini oluşturuyoruz
      final updatedReady = ready.copyWith(rfidReadEpcs: newRead);

      if (newRead.isEmpty) {
        state = MobileRefillRollbackCompleted(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
        );
      } else {
        // Hâlâ içeride ilaç var, RollbackInProgress state'ini güncellemeye devam et
        state = current.copyWith(ready: updatedReady);
      }
    }

    // Yerleştirilen dolum tag'i geri alındı (sessiz)
    if (ready.rfidReadEpcs.contains(epc)) {
      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);
      state = _withReady(current, ready.copyWith(rfidReadEpcs: newRead));
      return;
    }

    // PASSIVE → UNPLANNED (izinsiz çıkış)
    if (ready.passiveEpcs.contains(epc)) {
      final newPassive = Set<String>.from(ready.passiveEpcs)..remove(epc);
      final newUnplanned = {...ready.unplannedMovements, epc};
      state = _withReady(current, ready.copyWith(passiveEpcs: newPassive, unplannedMovements: newUnplanned));
      return;
    }

    // UNEXPECTED → UNEXPECTED_LOST (düzeltici, yoksay)
    if (ready.unexpectedEpcs.contains(epc)) {
      final newUnexpected = Set<String>.from(ready.unexpectedEpcs)..remove(epc);
      final newUnexpectedLost = {...ready.unexpectedLostEpcs, epc};
      state = _withReady(current, ready.copyWith(unexpectedEpcs: newUnexpected, unexpectedLostEpcs: newUnexpectedLost));
      return;
    }

    // Bilinmiyor — ignore
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Complete akışı
  // ═════════════════════════════════════════════════════════════════════════

  /// Dolumu tamamla — drawer Closed durumunda çağrılır.
  ///
  /// Sıralama (rfid-stock-notifications §7 — KAYIT ÖNCE, BİLDİRİM SONRA):
  ///
  ///   1. state = Saving
  ///   2. refillMobileCabin API → kayıt çağrısı
  ///   3a. Kayıt FAIL → Error state, RFID state KORUNUR (retry için),
  ///                    drawer state değiştirilmez
  ///   3b. Kayıt OK → drawer.stop() + state = Success
  ///   4. Arka planda fire-and-forget bildirim akışı (sıralı):
  ///        - UNPLANNED EPC'leri → Eksik Stok Bildirimi (her biri tek tek)
  ///        - RFID'siz manuel bildirimler
  ///      UNEXPECTED_LOST için bildirim üretilmez (§5.1 Dolum matris)
  ///   5. Bildirim hatası kullanıcıyı durdurmaz, log + snackbar
  ///
  /// canComplete (state'te tanımlı) zaten UI'da butonu disabled tutar:
  ///   - baselineCompleted true
  ///   - unexpectedEpcs.isEmpty (Dolum blokajı)
  ///   - allSelectedRfidRead
  ///
  /// SWREQ-CLI-REFILL-010
  Future<void> completeRefill() async {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (current.selectedItemIds.isEmpty) return;
    if (!current.canComplete) return;

    // Drawer kapalı olmalı (Dolum semantiği)
    if (_drawerStage is! MobileDrawerClosed) return;

    state = MobileRefillSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    final params = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map((i) => RefillMobileCabinParams(prescriptionDetailId: i.id!, epc: i.rfidTag))
        .toList();

    final result = await _refillMobileCabin(params);

    result.when(
      ok: (_) async {
        // Kayıt başarılı — drawer + RFID kapama
        await _drawer.stop();
        // _expectedMap'i snapshot al, sonra reset et. Bu sıralama kritik:
        // _dispatchNotifications async (unawaited) başlatılıyor; eğer önce
        // _resetExpectedMap çağrılırsa dispatch boş map görür ve EPC'lerden
        // prescriptionItemId çözülemez.
        final expectedSnapshot = _expectedMap;
        _resetExpectedMap();

        // Arka planda fire-and-forget bildirim akışı
        unawaited(_reportUnplannedMovements(current, expectedSnapshot));

        state = MobileRefillSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: '',
          ready: current.clearedRfidState.copyWith(selectedItemIds: const {}),
        );
      },
      error: (e) async {
        // Kayıt başarısız — RFID state KORUNUR, drawer'a dokunma
        state = MobileRefillRollbackInProgress(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          ready: current,
        );

        await _drawer.open(slots: current.slots, slot: current.selectedSlot);
      },
    );
  }

  /// Error state'inden completeRefill'i yeniden çağırır.
  ///
  /// Dialog'daki "Tekrar Dene" butonuna bağlanır. Önce dismissError ile state
  /// Ready'e döndürülür, ardından completeRefill başlatılır. Drawer hâlâ Closed
  /// olduğu için sıradan completeRefill akışı aynen tekrar çalışır.
  ///
  /// SWREQ-CLI-REFILL-010
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileRefillError) return;
    state = current.previousState;
    await completeRefill();
  }

  /// Hiçbir bildirim hatası kullanıcıyı durdurmaz; sadece log atılır.
  ///
  /// Bildirim türleri (rfid-stock-notifications §6 — Dolum matris):
  ///   - UNPLANNED       → ReportMissingStockUseCase (Eksik Stok bildirimi)
  ///   - UNEXPECTED_LOST → bildirim YOK (düzeltici hareket)
  ///   - NOT_FOUND       → N/A (Dolum'da SELECTED EPC'leri yok)
  ///   - Manuel buton    → Yok (Dolum'da kullanıcı dolduran taraf, bildirmesine gerek yok)
  ///
  /// UNPLANNED EPC'lerini prescriptionItemId'ye çevirmek için
  /// [expectedSnapshot] parametresi kullanılır. Notifier-level `_expectedMap`
  /// complete sırasında reset edildiği için snapshot parametre olarak alınır
  /// (race condition guard).
  ///
  /// SWREQ-CLI-REFILL-011
  Future<void> _reportUnplannedMovements(
    MobileRefillReady completedReady,
    Map<String, CabinExpectedEpc> expectedSnapshot,
  ) async {
    if (completedReady.unplannedMovements.isEmpty) return;
    // Her UNPLANNED EPC için ayrı çağrı — log düzeni için sıralı
    for (final epc in completedReady.unplannedMovements) {
      final expected = expectedSnapshot[epc];
      final prescriptionItemId = expected?.prescriptionItemId;

      if (prescriptionItemId == null) {
        continue;
      }

      final result = await _reportMissingStock.call(
        prescriptionItemId: prescriptionItemId,
        type: CabinInventoryType.refill,
      );

      result.when(
        ok: (_) => MedLogger.info(
          unit: 'MobileRefillNotifier',
          swreq: 'SWREQ-CLI-REFILL-011',
          message: 'UNPLANNED bildirimi gönderildi',
          context: {'epc': epc, 'prescriptionItemId': prescriptionItemId},
        ),
        error: (e) => MedLogger.error(
          unit: 'MobileRefillNotifier',
          swreq: 'SWREQ-CLI-REFILL-011',
          message: 'UNPLANNED bildirimi başarısız (kullanıcı durdurulmaz)',
          context: {'epc': epc, 'prescriptionItemId': prescriptionItemId, 'error': e.message},
        ),
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Dismiss
  // ═════════════════════════════════════════════════════════════════════════

  /// Error snackbar kapatıldığında previousState'e geri döner.
  /// Complete fail durumunda previousState RFID state'li Ready'dir → kullanıcı
  /// retry edebilir.
  ///
  /// SWREQ-CLI-REFILL-001
  void dismissError() {
    final current = state;
    if (current is! MobileRefillError) return;
    state = current.previousState;
  }

  /// Success snackbar kapatıldığında seçili gözde reçeteleri yenileyerek
  /// Ready'e döner. Atama bulunamazsa Idle'a gider.
  ///
  /// SWREQ-CLI-REFILL-001
  void dismissSuccess() {
    final current = state;
    if (current is! MobileRefillSuccess) return;

    final ready = current.ready;
    final assignment = current.assignmentByCoord[ready.selectedCell];
    if (assignment == null) {
      state = MobileRefillIdle(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        assignments: current.assignments,
        cabinId: current.cabinId,
      );
      return;
    }

    unawaited(
      _loadPrescriptions(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: ready.selectedSlot,
        selectedCell: ready.selectedCell,
        assignments: current.assignments,
        cabinId: current.cabinId,
        assignment: assignment,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Internal helpers — state sarmalayıcı yönetimi
  // ═════════════════════════════════════════════════════════════════════════

  /// State içinden Ready'i çıkarır. Tüm sarmalayıcı state'leri
  /// (DrawerStarting, Saving) ve Ready'nin kendisini kapsar.
  MobileRefillReady? _readyOf(MobileRefillState s) => switch (s) {
    MobileRefillReady r => r,
    MobileRefillDrawerOpening(:final ready) => ready,
    MobileRefillSaving(:final ready) => ready,
    MobileRefillError(:final previousState) => _readyOf(previousState),
    MobileRefillRollbackInProgress(:final ready) => ready, // ← YENİ
    _ => null,
  };

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  MobileRefillState _withReady(MobileRefillState s, MobileRefillReady ready) => switch (s) {
    MobileRefillReady _ => ready,
    MobileRefillDrawerOpening w => MobileRefillDrawerOpening(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileRefillSaving w => MobileRefillSaving(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileRefillRollbackInProgress w => MobileRefillRollbackInProgress(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
      cancelledAt: w.cancelledAt,
    ),
    _ => s,
  };

  /// Baseline'ın yan ürünü olan EXPECTED_MAP'i boşaltır.
  /// Cancel, success, reopen, drawer failed akışlarında çağrılır.
  void _resetExpectedMap() {
    _expectedMap = const <String, CabinExpectedEpc>{};
  }
}
