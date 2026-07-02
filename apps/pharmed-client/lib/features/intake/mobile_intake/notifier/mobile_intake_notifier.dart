import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';

// [SWREQ-CLI-INTAKE-001] [IEC 62304 §5.5]
// Mobil kabin ilaç alım ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Alım başlatma → CheckMobileIntakeUseCase ile backend validasyon → çekmece açar
//   - RFID kaybı → takenEpcs günceller (dolumun tersi: kayıp = alındı)
//   - Alım tamamlama → çekmece kapalıyken CompleteMobileIntakeUseCase çağırır
//
// Dolumdan farkı:
//   - startIntake öncesi CheckMobileIntakeUseCase çalışır
//   - rfidReadEpcs yerine takenEpcs takip edilir (EPC kaybolunca alındı sayılır)
//   - EPC geri gelirse takenEpcs'ten çıkarılır (ilaç geri konuldu)
//   - canComplete: seçili RFID'li item'ların EPC'si takenEpcs'te olmalı
//
// Sınıf: Class B

final mobileIntakeNotifierProvider = NotifierProvider<MobileIntakeNotifier, MobileIntakeState>(
  MobileIntakeNotifier.new,
);

class MobileIntakeNotifier extends Notifier<MobileIntakeState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  GetCabinExpectedEpcsUseCase get _getCabinExpectedEpcs => ref.read(getCabinExpectedEpcsUseCaseProvider);
  CheckMobileIntakeUseCase get _checkIntake => ref.read(checkMobileIntakeUseCaseProvider);
  CompleteMobileIntakeUseCase get _completeIntake => ref.read(completeMobileIntakeUseCaseProvider);
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
  MobileIntakeState build() {
    _drawer = MobileDrawerOrchestrator(ref: ref)
      ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);

    ref.onDispose(() => _drawer.dispose());

    return const MobileIntakeUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    final mobileSlots = data.mobileSlots;

    state = MobileIntakeLoading(slots: slots, cabinId: data.cabinId);

    final assignmentResult = await _getAssignments.call(data.cabinId);

    state = assignmentResult.when(
      ok: (assignments) =>
          MobileIntakeIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
      error: (e) => MobileIntakeError(
        message: e.message,
        previousState: MobileIntakeIdle(
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
      state = MobileIntakeIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = MobileIntakeSlotSelected(
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
      state = MobileIntakeSlotSelected(
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
      state = MobileIntakeNoPatient(
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
  /// Slot seçimi korunur.
  void clearPatientSelection() {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    state = MobileIntakeSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  void onDatePresetChanged(DateRangePreset preset) {
    final current = state;
    if (current is! MobileIntakeReady) return;
    state = current.copyWith(datePreset: preset);
    _reloadPrescriptions();
  }

  void onStatusFilterChanged(PrescriptionMovementType? type) {
    final current = state;
    if (current is! MobileIntakeReady) return;
    state = current.copyWith(statusFilter: type, clearStatusFilter: type == null);
    _reloadPrescriptions();
  }

  /// İlaç işaretle / işareti kaldır.
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileIntakeReady) return;

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || !(item.status?.canPurchase ?? false)) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  Future<void> _reloadPrescriptions() async {
    final current = state;
    if (current is! MobileIntakeReady) return;

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
      error: (e) => state = MobileIntakeError(message: e.message, previousState: current),
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

    state = MobileIntakeLoading(
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
        state = MobileIntakeReady(
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
          selectedItemIds: {},
        );
      },
      error: (e) {
        state = MobileIntakeError(
          message: e.message,
          previousState: MobileIntakeNoPatient(
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

  /// Alıma başla — önce backend check, sonra çekmece aç.
  ///
  /// [CheckMobileIntakeUseCase] hata dönerse çekmece açılmaz.
  /// Check geçerse [_drawer.open] çağrılır; RFID session orchestrator tarafından başlatılır.
  ///
  /// SWREQ-CLI-INTAKE-002
  Future<void> startIntake() async {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.selectedItemIds.isEmpty) return;

    // Check sırasında UI kilitlenir (isStarting: state is MobileIntakeCheckInProgress)
    state = MobileIntakeCheckInProgress(ready: current);

    // Check için EPC gönderilmez (yalnızca işlem yapılabilir mi kontrolü)
    final params = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map((i) => MobileIntakeParams(prescriptionDetailId: i.id!, dosePiece: i.dosePiece?.toDouble(), epc: i.rfidTag))
        .toList();

    final checkResult = await _checkIntake(params);

    if (checkResult is Error) {
      state = MobileIntakeError(message: checkResult.error.message, previousState: current);
      return;
    }

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmece açıldıktan sonra baseline snapshot alır ve reconciliation yapar.
  ///
  /// Snapshot, seçili item'ların beklenen EPC'leri ile karşılaştırılır:
  ///   - matched    → rfidReadEpcs (seçili & kabinde, beklendiği gibi)
  ///   - notFound   → notFoundEpcs (seçili ama kabinde yok → otomatik eksik)
  ///   - unexpected → unexpectedEpcs (kabinde ama seçili değil → normal)
  ///
  /// Sonrasında baselineCompleted = true ile state güncellenir.
  ///
  /// SWREQ-CLI-INTAKE-009
  Future<void> _scanCabin() async {
    final current = state;
    if (current is MobileIntakeError) return;

    final ready = _readyOf(current);
    if (ready == null) return;

    // İlk açılış mı, reopen mı? (baseline + _expectedMap korunur)
    final isFirstScan = ready.baselineEpcs.isEmpty && _expectedMap.isEmpty;

    if (isFirstScan) {
      // Beklenen kabin tag'lerini çek — reconciliation için DEĞİL,
      // yalnızca kapanışta EPC → prescriptionItemId çözümü için lookup.
      final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);
      String? errorMessage;
      expectedResult.when(
        ok: (value) => _expectedMap = {for (final e in value) (e.rfidTag ?? ''): e},
        error: (e) => errorMessage = e.message,
      );
      if (errorMessage != null) {
        state = MobileIntakeError(message: errorMessage!, previousState: ready);
        return;
      }

      // Snapshot → baseline (bölünmez, hepsi eşit)
      final observed = await _drawer.snapshot();
      final after = state;
      final afterReady = _readyOf(after);
      if (afterReady == null) return;

      state = _withReady(after, afterReady.copyWith(baselineCompleted: true, baselineEpcs: observed));
    } else {
      // Reopen: baseline KORUNUR, sadece scan tamamlandı işaretle.
      state = _withReady(current, ready.copyWith(baselineCompleted: true));
    }
  }

  /// ClosedEarly / Error → "İptal". Kayıt YOK. İşlemi bitirir, Idle'a döner.
  Future<void> cancelEarlyClose() async {
    final current = state;
    final ready = _readyOf(current);

    await _drawer.stop();
    _resetExpectedMap();
    _closedDuringSaving = false;

    if (ready == null) {
      state = const MobileIntakeIdle(slots: [], mobileSlots: [], assignments: [], cabinId: 0);
      return;
    }

    // Sahne KORUNUR — slot/hasta listesi ekranda kalır
    state = MobileIntakeIdle(
      slots: ready.slots,
      mobileSlots: ready.mobileSlots,
      assignments: ready.assignments,
      cabinId: ready.cabinId,
    );
  }

  /// ClosedEarly → "Tekrar Dene". Çekmece yeniden açılır (check YOK — zaten geçildi).
  /// Baseline + _expectedMap + runtime kümeleri KORUNUR.
  Future<void> retryEarlyClose() async {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;

    _closedDuringSaving = false;

    // ready olduğu gibi taşınır (baseline + placedEpcs + baselineLostEpcs dahil).
    // Sadece baselineCompleted false → UI "Tarama yapılıyor" gösterir,
    // complete butonu reopen tamamlanana kadar disabled.
    final reopening = ready.copyWith(baselineCompleted: false);
    state = MobileIntakeDrawerOpening(ready: reopening);

    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Alımı tamamla — çekmece açıkken çağrılır.
  ///
  /// API başarılıysa MobileIntakeWaitingForClose'a geçer, kullanıcı çekmeceyi
  /// kapatınca otomatik Success'e döner.
  ///
  /// Asıl kayıt (completeIntake) başarısızsa ROLLBACK başlar: çekmece otomatik
  /// açılır, kullanıcı çıkardığı ilaçları geri koyar (previouslyTakenEpcs).
  ///
  /// canComplete koşulu:
  ///   - RFID'li item: EPC takenEpcs'te VEYA notFoundEpcs'te olmalı
  ///   - RFID'siz item: seçili olması yeterli
  ///
  /// SWREQ-CLI-INTAKE-003
  Future<void> completeIntake() async {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.selectedItemIds.isEmpty) return;
    if (!current.canComplete) return;

    // Alım da dolum gibi: çekmece AÇIKKEN tamamlanır
    if (_drawerStage is! MobileDrawerOpened) return;

    _closedDuringSaving = false;
    state = MobileIntakeSaving(ready: current);

    // Kayıt payload'ı: yalnızca fiziksel olarak ALINAN item'lar.
    //   - RFID'li + taken  → kayda girer
    //   - RFID'li + notFound → GİRMEZ (kabinde yoktu, kapanışta eksik bildirilir)
    //   - RFID'siz          → girer (eksikse kullanıcı manuel bildirir)
    final params = current.prescriptionItems
        .where((i) {
          if (i.id == null || !current.selectedItemIds.contains(i.id)) return false;
          final isRfid = i.medicine is Drug && (i.medicine as Drug).isRfidEnable && i.rfidTag != null;
          if (isRfid) return current.takenEpcs.contains(i.rfidTag);
          return true;
        })
        .map((i) => MobileIntakeParams(prescriptionDetailId: i.id!, dosePiece: i.dosePiece?.toDouble(), epc: i.rfidTag))
        .toList();

    // Alınan hiçbir şey yoksa (hepsi notFound, RFID'siz de yok) → kayıt atlanır,
    // doğrudan kapanış akışına geç. Eksik bildirimler kapanışta yine gider.
    if (params.isEmpty) {
      if (_closedDuringSaving) {
        _closedDuringSaving = false;
        unawaited(_reportUnplannedMovements(current));
        state = MobileIntakeSuccess(ready: current);
      } else {
        state = MobileIntakeWaitingClose(ready: current);
      }
      return;
    }

    final result = await _completeIntake.call(params);

    result.when(
      ok: (_) {
        // Kayıt başarılı. Çekmece HÂLÂ AÇIK — kapanış beklenir.
        // _expectedMap + runtime kümeleri KORUNUR (kapanışta rapor için).
        if (_closedDuringSaving) {
          _closedDuringSaving = false;
          unawaited(_reportUnplannedMovements(current));
          state = MobileIntakeSuccess(ready: current);
        } else {
          state = MobileIntakeWaitingClose(ready: current);
        }
      },
      error: (e) {
        // Kayıt başarısız → Error (kurtarılabilir, "Tekrar Dene").
        // Çekmece açık; drawer'a dokunma.
        _closedDuringSaving = false;
        state = MobileIntakeError(message: e.message, previousState: current);
      },
    );
  }

  /// Error → "Tekrar Dene". Çekmece açık; kaydı yeniden dener (reopen YOK).
  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileIntakeError) return;
    final ready = current.previousState.readyContext;
    if (ready == null) return;

    state = ready;
    await completeIntake();
  }

  /// Plan dışı hareketleri eczaneye bildirir.
  /// SWREQ-CLI-INTAKE-008
  Future<void> _reportUnplannedMovements(MobileIntakeReady ready) async {
    // Kapanışta otomatik bildirilecek eksikler:
    //   1) unplannedMovements — almaması gereken ilaç alındı (baseline'dan izinsiz çıkış)
    //   2) notFoundEpcs        — alacağı ilaç kabinde hiç yoktu (okunmadı)
    final toReport = <String>{...ready.unplannedMovements, ...ready.notFoundEpcs};
    if (toReport.isEmpty) return;

    for (final epc in toReport) {
      final prescriptionItemId = _expectedMap[epc]?.prescriptionItemId;
      if (prescriptionItemId == null) {
        continue;
      }

      await _reportMissingStock.call(prescriptionItemId: prescriptionItemId, type: CabinInventoryType.intake);
    }
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
    if (current is! MobileIntakeReady) return;
    if (current.reportingItemIds.contains(itemId)) return; // bu item zaten işlemde
    if (current.reportedMissingItemIds.contains(itemId)) return;

    final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;
    if (!(item.status?.canReportShortage ?? false)) return; // sadece "Alım Bekliyor"

    // Bu item için buton loading
    state = current.copyWith(reportingItemIds: {...current.reportingItemIds, itemId});

    final result = await _reportMissingStock(prescriptionItemId: item.id!, type: CabinInventoryType.intake);

    final after = state;
    if (after is! MobileIntakeReady) return;

    result.when(
      ok: (_) async {
        state = after.copyWith(
          reportingItemIds: {...after.reportingItemIds}..remove(itemId),
          reportedMissingItemIds: {...after.reportedMissingItemIds, itemId},
        );

        MedLogger.info(
          unit: 'MobileIntakeNotifier',
          swreq: 'SWREQ-CLI-INTAKE-007',
          message: 'Manuel eksik stok bildirildi',
          context: {'itemId': itemId},
        );
      },
      error: (e) => state = after.copyWith(reportingItemIds: {...after.reportingItemIds}..remove(itemId)),
    );
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    // ── Çekmece açıldı → sahneye geç, baseline tara ──────────────────────
    if (next is MobileDrawerOpened) {
      final current = state;
      // İlk açılış: CheckInProgress → Ready | Reopen: DrawerOpening → Ready
      final ready = switch (current) {
        MobileIntakeCheckInProgress(:final ready) => ready,
        MobileIntakeDrawerOpening(:final ready) => ready,
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
        case MobileIntakeWaitingClose(:final ready):
          unawaited(_reportUnplannedMovements(ready));
          state = MobileIntakeSuccess(ready: ready);

        // Kayıt uçuşta kapandı → flag'le; Saving çözülünce değerlendir
        case MobileIntakeSaving():
          _closedDuringSaving = true;

        // Tamamla denmeden kapandı → kullanıcıya karar sor
        case MobileIntakeReady r:
          state = MobileIntakeClosedEarly(ready: r);

        default:
          break;
      }
    }

    // ── Çekmece donanım hatası → kurtarılamaz, FatalError ────────────────
    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileIntakeReady r => r.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileIntakeCheckInProgress(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileIntakeSaving(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileIntakeWaitingClose(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        MobileIntakeClosedEarly(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
        _ => current,
      };
      state = MobileIntakeFatalError(message: next.message, previousState: cleaned);
    }
  }

  /// EPC okundu — çekmecede tag göründü.
  ///
  /// Anlamı duruma göre değişir:
  ///   - Rollback sırasında: kullanıcı alınan ilacı kabine geri koyuyor →
  ///     rfidReadEpcs'e ekle; previouslyTakenEpcs hepsi geri konduysa finalize.
  ///   - Baseline öncesi: snapshot bekliyor, hiçbir şey yapılmaz
  ///   - Baseline sonrası:
  ///     · takenEpcs içindeyse → ilaç geri konuldu, takenEpcs'ten çıkar
  ///     · notFoundEpcs içindeyse → eksikti, geç okundu, notFoundEpcs'ten çıkar
  ///     · expectedSelected içindeyse → matched, rfidReadEpcs'e ekle
  ///     · değilse → plan-dışı yeni tag, unexpectedEpcs'e ekle
  ///
  /// SWREQ-CLI-INTAKE-004
  void _onEpcRead(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;

    // KORUMA 1: Eğer baseline taraması henüz bitmediyse, okunan her etiket
    // kabinin kendi malıdır. Bunları unexpected yapamayız.
    if (!ready.baselineCompleted) return;

    // Baseline'daki tag geri okundu → lost'tan kurtar (geri kondu)
    if (ready.baselineEpcs.contains(epc)) {
      if (ready.baselineLostEpcs.contains(epc)) {
        state = _withReady(
          current,
          ready.copyWith(baselineLostEpcs: Set<String>.from(ready.baselineLostEpcs)..remove(epc)),
        );
      }
      return;
    }

    // Baseline'da yok → yabancı tag kabine girdi
    if (ready.placedEpcs.contains(epc)) return; // dedup
    state = _withReady(current, ready.copyWith(placedEpcs: {...ready.placedEpcs, epc}));
  }

  /// EPC kayboldu — çekmeceden tag çıktı.
  ///
  /// Anlamı duruma göre değişir:
  ///   - Rollback sırasında: kullanıcı geri koyduğu bir tag'i tekrar çıkardı →
  ///     rfidReadEpcs'ten düş (rollback geriye gider).
  ///   - Baseline öncesi: snapshot bekliyor, hiçbir şey yapılmaz
  ///   - Baseline sonrası:
  ///     · rfidReadEpcs içindeyse (seçili) → takenEpcs'e ekle (normal alım)
  ///     · unexpectedEpcs içindeyse (seçili değil) → unplannedMovements'a ekle
  ///     · notFoundEpcs içindeyse → zaten yoktu, ignore
  ///
  /// SWREQ-CLI-INTAKE-005
  void _onEpcLost(String epc) {
    final current = state;
    final ready = _readyOf(current);
    if (ready == null) return;
    if (!ready.baselineCompleted) return;

    // Baseline'daki bir tag çıktı → kabinden alındı (taken/unplanned, baselineLostEpcs).
    if (ready.baselineEpcs.contains(epc)) {
      if (ready.baselineLostEpcs.contains(epc)) return; // zaten lost, dedup
      state = _withReady(current, ready.copyWith(baselineLostEpcs: {...ready.baselineLostEpcs, epc}));
      return;
    }

    // Baseline'da olmayan yabancı tag (placedEpcs) çıktı → kullanıcı geri aldı.
    // placedEpcs'ten çıkar, "beklenmeyen" uyarısı kalkar.
    if (ready.placedEpcs.contains(epc)) {
      state = _withReady(current, ready.copyWith(placedEpcs: Set<String>.from(ready.placedEpcs)..remove(epc)));
      return;
    }

    // Ne baseline ne placed — bilinmiyor, ignore
  }

  void dismissError() {
    final current = state;
    if (current is! MobileIntakeError) return;
    state = current.previousState;
  }

  Future<void> dismissSuccess() async {
    final current = state;
    if (current is! MobileIntakeSuccess) return;

    await _drawer.stop();

    state = MobileIntakeIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }

  /// Baseline'ın yan ürünü olan EXPECTED_MAP'i boşaltır.
  /// Cancel, success, reopen, drawer failed akışlarında çağrılır.
  void _resetExpectedMap() {
    _expectedMap = const <String, CabinExpectedEpc>{};
  }

  /// State içinden Ready'i çıkarır. Tüm sarmalayıcı state'leri
  /// (DrawerStarting, Saving) ve Ready'nin kendisini kapsar.
  MobileIntakeReady? _readyOf(MobileIntakeState s) => switch (s) {
    MobileIntakeReady r => r,
    MobileIntakeCheckInProgress(:final ready) => ready,
    MobileIntakeDrawerOpening(:final ready) => ready,
    MobileIntakeSaving(:final ready) => ready,
    MobileIntakeWaitingClose(:final ready) => ready,
    MobileIntakeClosedEarly(:final ready) => ready,
    MobileIntakeError(:final previousState) => _readyOf(previousState),
    MobileIntakeFatalError(:final previousState) => previousState.readyContext,
    _ => null,
  };

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  MobileIntakeState _withReady(MobileIntakeState s, MobileIntakeReady ready) => switch (s) {
    MobileIntakeReady _ => ready,
    MobileIntakeCheckInProgress _ => MobileIntakeCheckInProgress(ready: ready),
    MobileIntakeDrawerOpening _ => MobileIntakeDrawerOpening(ready: ready),
    MobileIntakeSaving _ => MobileIntakeSaving(ready: ready),
    _ => s,
  };
}
