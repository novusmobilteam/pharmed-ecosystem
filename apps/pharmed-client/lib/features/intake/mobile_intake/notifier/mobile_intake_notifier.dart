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

    // Check sırasında UI kilitlenir — isStarting: state is MobileIntakeCheckInProgress
    state = MobileIntakeCheckInProgress(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    // Check için EPC gönderilmez
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

  /// Çekmeceyi tekrar aç — RFID eksikse "Alıma Devam Et" butonuna bağlanır.
  Future<void> reopenDrawer() async {
    // Yeni baseline alınacak — eski RFID state'ini sıfırla
    final current = state;
    if (current is MobileIntakeReady) {
      state = current.copyWith(
        rfidReadEpcs: {},
        takenEpcs: {},
        baselineCompleted: false,
        notFoundEpcs: {},
        unexpectedEpcs: {},
        unplannedMovements: {},
        // selectedItemIds KORUNUR — kullanıcı yeniden seçmek zorunda kalmasın
      );
    }
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// Alımı iptal et.
  ///
  /// - DrawerIdle + seçim var → seçimleri sıfırla
  /// - DrawerOpening/Opened + takenEpcs dolu → view handle eder, dönülür
  /// - Diğer durumlarda → session durdur, seçimleri sıfırla
  Future<void> cancelIntake() async {
    final current = state;
    final ready = switch (current) {
      MobileIntakeReady r => r,
      MobileIntakeCheckInProgress(:final ready) => ready,
      MobileIntakeSaving(:final ready) => ready,
      _ => null,
    };

    final stage = _drawerStage;

    if (stage is MobileDrawerIdle) {
      if (ready == null) return;
      state = ready.copyWith(
        selectedItemIds: {},
        rfidReadEpcs: {},
        takenEpcs: {},
        baselineCompleted: false,
        notFoundEpcs: {},
        unexpectedEpcs: {},
        unplannedMovements: {},
      );
      return;
    }

    if ((stage is MobileDrawerOpening || stage is MobileDrawerOpened) && (ready?.takenEpcs.isNotEmpty ?? false)) {
      return;
    }

    await _drawer.stop();

    if (ready != null) {
      state = ready.copyWith(
        selectedItemIds: {},
        rfidReadEpcs: {},
        takenEpcs: {},
        baselineCompleted: false,
        notFoundEpcs: {},
        unexpectedEpcs: {},
        unplannedMovements: {},
      );
    }
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

    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerClosed) return;

    state = MobileIntakeSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
      ready: current,
    );

    final params = current.prescriptionItems
        .where(
          (i) =>
              i.id != null && current.selectedItemIds.contains(i.id) && !current.reportedMissingItemIds.contains(i.id),
        ) // ← manuel bildirilen dışlanır
        .map(
          (i) => MobileIntakeParams(
            prescriptionDetailId: i.id!,
            dosePiece: i.dosePiece?.toDouble(),
            epc: current.takenEpcs.contains(i.rfidTag) ? i.rfidTag : null,
          ),
        )
        .toList();

    if (params.isEmpty) {
      // Tüm seçili item'lar manuel bildirildi, collect edilecek bir şey yok.
      await _drawer.stop();
      _resetExpectedMap();
      state = MobileIntakeSuccess(
        slots: current.slots,
        mobileSlots: current.mobileSlots,
        selectedSlot: current.selectedSlot,
        assignments: current.assignments,
        cabinId: current.cabinId,
        message: '',
        ready: current.clearedRfidState.copyWith(selectedItemIds: const {}),
      );
      return;
    }

    final result = await _completeIntake(params);

    result.when(
      ok: (_) async {
        // Çekmece zaten kapalı (complete kapalıyken yapıldı) → doğrudan Success.
        // WaitingForClose'a gerek yok; beklenecek bir kapanma olayı yok.
        await _drawer.stop();

        if (current.unplannedMovements.isNotEmpty) {
          final expectedSnapshot = _expectedMap;
          unawaited(_reportUnplannedMovements(current, expectedSnapshot));
        }

        _resetExpectedMap();

        state = MobileIntakeSuccess(
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
        // BAŞARISIZ → ROLLBACK: ilaçlar fiziksel çıktı ama kayıt geçmedi.
        // Kullanıcı çıkardığı ilaçları kabine geri koymalı.
        // Geri konması beklenen tag'ler = bu işlemde alınan (taken) tag'ler.
        MedLogger.warn(
          unit: 'MobileIntakeNotifier',
          swreq: 'SWREQ-CLI-INTAKE-003',
          message: 'Complete başarısız — rollback başlatılıyor',
          context: {'error': e.message, 'takenCount': current.takenEpcs.length},
        );

        final rollbackReady = current.copyWith(
          previouslyTakenEpcs: current.takenEpcs,
          // rfidReadEpcs sıfırlanır: geri kondukça _onEpcRead yeniden dolduracak.
          // baseline KORUNUR — yeni snapshot alınmayacak.
          rfidReadEpcs: const {},
        );

        state = MobileIntakeRollbackInProgress(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          ready: rollbackReady,
        );

        // Çekmeceyi otomatik aç — kullanıcı ilaçları geri koyacak
        await _drawer.open(slots: current.slots, slot: current.selectedSlot);
      },
    );
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

    // ── Rollback: geri konan tag'i izle ──────────────────────────────────
    if (current is MobileIntakeRollbackInProgress) {
      final ready = current.ready;
      // Sadece daha önce alınmış bir tag geri konuyorsa anlamlı
      if (!ready.previouslyTakenEpcs.contains(epc)) return;
      if (ready.rfidReadEpcs.contains(epc)) return; // dedup

      final newRead = {...ready.rfidReadEpcs, epc};
      final updatedReady = ready.copyWith(rfidReadEpcs: newRead);

      MedLogger.info(
        unit: 'MobileIntakeNotifier',
        swreq: 'SWREQ-CLI-INTAKE-004',
        message: 'Rollback — alınan tag kabine geri kondu',
        context: {'epc': epc, 'pending': updatedReady.pendingRollbackEpcs.length},
      );

      if (updatedReady.isRollbackComplete) {
        // Drawer hâlâ açık; kullanıcı kapatınca _onDrawerStageChange finalize eder.
        // Yine de state'i güncel tut ki UI "tümü geri kondu" gösterebilsin.
        state = current.copyWith(ready: updatedReady);
      } else {
        state = current.copyWith(ready: updatedReady);
      }
      return;
    }

    if (current is! MobileIntakeReady) return;
    if (!current.baselineCompleted) return;

    final isSelected = current.prescriptionItems.any(
      (i) => i.id != null && current.selectedItemIds.contains(i.id) && i.rfidTag == epc,
    );

    final newTaken = Set<String>.from(current.takenEpcs)..remove(epc);
    final newRead = {...current.rfidReadEpcs};
    final newNotFound = Set<String>.from(current.notFoundEpcs)..remove(epc);
    final newUnexpected = {...current.unexpectedEpcs};
    final newUnplanned = Set<String>.from(current.unplannedMovements)..remove(epc);

    if (isSelected) {
      newRead.add(epc);
    } else {
      newUnexpected.add(epc);
    }

    state = current.copyWith(
      rfidReadEpcs: newRead,
      takenEpcs: newTaken,
      notFoundEpcs: newNotFound,
      unexpectedEpcs: newUnexpected,
      unplannedMovements: newUnplanned,
    );

    MedLogger.info(
      unit: 'MobileIntakeNotifier',
      swreq: 'SWREQ-CLI-INTAKE-004',
      message: 'EPC okundu (baseline sonrası)',
      context: {'epc': epc, 'isSelected': isSelected},
    );
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

    // ── Rollback: geri konmuş bir tag tekrar çıktıysa geri al ────────────
    if (current is MobileIntakeRollbackInProgress) {
      final ready = current.ready;
      if (!ready.rfidReadEpcs.contains(epc)) return;

      final newRead = Set<String>.from(ready.rfidReadEpcs)..remove(epc);
      state = current.copyWith(ready: ready.copyWith(rfidReadEpcs: newRead));

      MedLogger.info(
        unit: 'MobileIntakeNotifier',
        swreq: 'SWREQ-CLI-INTAKE-005',
        message: 'Rollback — geri konan tag tekrar çıkarıldı',
        context: {'epc': epc},
      );
      return;
    }

    if (current is! MobileIntakeReady) return;
    if (!current.baselineCompleted) return;

    if (current.takenEpcs.contains(epc)) return;

    if (current.rfidReadEpcs.contains(epc)) {
      final newRead = Set<String>.from(current.rfidReadEpcs)..remove(epc);
      final newTaken = {...current.takenEpcs, epc};
      state = current.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken);

      MedLogger.info(
        unit: 'MobileIntakeNotifier',
        swreq: 'SWREQ-CLI-INTAKE-005',
        message: 'Seçili EPC çekmeceden çıktı — alındı',
        context: {'epc': epc},
      );
      return;
    }

    if (current.unexpectedEpcs.contains(epc)) {
      final newUnexpected = Set<String>.from(current.unexpectedEpcs)..remove(epc);
      final newUnplanned = {...current.unplannedMovements, epc};
      state = current.copyWith(unexpectedEpcs: newUnexpected, unplannedMovements: newUnplanned);

      MedLogger.warn(
        unit: 'MobileIntakeNotifier',
        swreq: 'SWREQ-CLI-INTAKE-008',
        message: 'Plan dışı hareket algılandı — seçili olmayan EPC kabinden çıkarıldı',
        context: {'epc': epc},
      );
      return;
    }

    MedLogger.info(
      unit: 'MobileIntakeNotifier',
      swreq: 'SWREQ-CLI-INTAKE-005',
      message: 'EPC kayboldu ama bilinen bir kümede değil',
      context: {'epc': epc},
    );
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerOpened) {
      final current = state;
      // Normal akış: CheckInProgress → Ready, ardından baseline scan
      if (current is MobileIntakeCheckInProgress) {
        state = current.ready;
        unawaited(_performBaselineScan());
      }
      // RollbackInProgress'te baseline scan YAPILMAZ — RFID state korunur,
      // kullanıcı geri koydukça _onEpcRead rfidReadEpcs'i artırır.
    }

    if (next is MobileDrawerClosed) {
      final current = state;

      // Rollback: tüm previouslyTakenEpcs kabine geri kondu mu?
      if (current is MobileIntakeRollbackInProgress) {
        if (current.ready.isRollbackComplete) {
          // Tüm alınan tag'ler yerine kondu → rollback tamam
          unawaited(_finalizeRollback(current));
        }
        // else: hâlâ eksik tag var, state aynı kalır.
        // Dialog footer'ı "Çekmeceyi Aç" / "Tekrar Dene" butonlarını gösterir.
      }
    }

    if (next is MobileDrawerFailed) {
      _resetExpectedMap();
      final current = state;
      final cleaned = switch (current) {
        MobileIntakeReady r => r.copyWith(
          rfidReadEpcs: {},
          takenEpcs: {},
          selectedItemIds: {},
          baselineCompleted: false,
          notFoundEpcs: {},
          unexpectedEpcs: {},
          unplannedMovements: {},
        ),
        MobileIntakeCheckInProgress(:final ready) => ready.copyWith(
          rfidReadEpcs: {},
          takenEpcs: {},
          selectedItemIds: {},
          baselineCompleted: false,
          notFoundEpcs: {},
          unexpectedEpcs: {},
          unplannedMovements: {},
        ),
        MobileIntakeRollbackInProgress(:final ready) => ready.copyWith(
          rfidReadEpcs: {},
          takenEpcs: {},
          selectedItemIds: {},
          baselineCompleted: false,
          notFoundEpcs: {},
          unexpectedEpcs: {},
          unplannedMovements: {},
        ),
        _ => current,
      };
      // Çekmece donanım hatası → kurtarılamaz
      state = MobileIntakeFatalError(message: next.message, previousState: cleaned);
    }
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
          rfidReadEpcs: const {},
          takenEpcs: const {},
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

  void dismissError() {
    final current = state;
    if (current is! MobileIntakeError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileIntakeSuccess) return;
    state = MobileIntakeIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
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
  Future<void> _performBaselineScan() async {
    final current = state;

    if (current is MobileIntakeError || current is MobileIntakeRollbackInProgress) {
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
      state = MobileIntakeError(message: errorMessage!, previousState: ready);
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

    // 4) Reconciliation kümeleri — alım semantiği
    //    SELECTED = seçili RFID'li item'ların beklenen EPC'leri
    final selected = afterReady.selectedRfidEpcs;

    final matched = selected.intersection(observed); // seçili & kabinde
    final notFound = selected.difference(observed); // seçili & kabinde yok → otomatik eksik
    final unexpected = observed.difference(expectedSet); // kabinde ama kabin stoğuna ait değil

    final updatedReady = afterReady.copyWith(
      baselineCompleted: true,
      rfidReadEpcs: matched,
      notFoundEpcs: notFound,
      unexpectedEpcs: unexpected,
    );

    state = _withReady(after, updatedReady);
  }

  /// Plan dışı hareketleri eczaneye bildirir.
  ///
  /// TODO: Backend endpoint'i hazır olduğunda gerçek API çağrısı eklenecek.
  /// Şu an sadece log atılır.
  ///
  /// SWREQ-CLI-INTAKE-008
  Future<void> _reportUnplannedMovements(
    MobileIntakeReady completedReady,
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

  Future<void> retryComplete() async {
    final current = state;
    if (current is! MobileIntakeError) return;
    final ready = current.previousState;
    if (ready is! MobileIntakeReady) return;

    // previousState'i geri yükle, completeIntake baştan çalışsın
    state = ready;
    await completeIntake();
  }

  /// Baseline'ın yan ürünü olan EXPECTED_MAP'i boşaltır.
  /// Cancel, success, reopen, drawer failed akışlarında çağrılır.
  void _resetExpectedMap() {
    _expectedMap = const <String, CabinExpectedEpc>{};
  }

  /// Rollback başarıyla tamamlandı — drawer + RFID temizliği yapar ve
  /// state'i [MobileIntakeRollbackCompleted]'e geçirir.
  ///
  /// Dialog `readyContext` null gördüğü için kendiliğinden kapanır.
  /// Sonrasında state Idle'a çekilir ki kullanıcı yeni bir alım
  /// başlatabilsin (dialog dispose olduktan sonra).
  ///
  /// SWREQ-CLI-INTAKE-014
  Future<void> _finalizeRollback(MobileIntakeRollbackInProgress current) async {
    MedLogger.info(
      unit: 'MobileIntakeNotifier',
      swreq: 'SWREQ-CLI-INTAKE-014',
      message: 'Rollback tamamlandı — tüm tag\'ler kabine geri kondu',
      context: {
        'previouslyTakenCount': current.ready.previouslyTakenEpcs.length,
        'unplannedCount': current.ready.unplannedMovements.length,
      },
    );

    await _drawer.stop();
    _resetExpectedMap();

    state = MobileIntakeRollbackCompleted(
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
        if (s is MobileIntakeRollbackCompleted) {
          state = MobileIntakeIdle(
            slots: s.slots,
            mobileSlots: s.mobileSlots,
            assignments: s.assignments,
            cabinId: s.cabinId,
          );
        }
      }),
    );
  }

  /// State içinden Ready'i çıkarır. Tüm sarmalayıcı state'leri
  /// (DrawerStarting, Saving) ve Ready'nin kendisini kapsar.
  MobileIntakeReady? _readyOf(MobileIntakeState s) => switch (s) {
    MobileIntakeReady r => r,
    MobileIntakeCheckInProgress(:final ready) => ready,
    MobileIntakeDrawerOpening(:final ready) => ready,
    MobileIntakeSaving(:final ready) => ready,
    MobileIntakeError(:final previousState) => _readyOf(previousState),
    MobileIntakeRollbackInProgress(:final ready) => ready, // ← YENİ
    _ => null,
  };

  /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
  /// doğrudan döner. Tanımsız state'ler değişmeden döner.
  MobileIntakeState _withReady(MobileIntakeState s, MobileIntakeReady ready) => switch (s) {
    MobileIntakeReady _ => ready,
    MobileIntakeCheckInProgress w => MobileIntakeCheckInProgress(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileIntakeDrawerOpening w => MobileIntakeDrawerOpening(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileIntakeSaving w => MobileIntakeSaving(
      slots: w.slots,
      mobileSlots: w.mobileSlots,
      selectedSlot: w.selectedSlot,
      assignments: w.assignments,
      cabinId: w.cabinId,
      ready: ready,
    ),
    MobileIntakeRollbackInProgress w => MobileIntakeRollbackInProgress(
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
}
