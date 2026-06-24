import 'dart:async';

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
  CompleteMobileCensusUseCase get _completeCensus => ref.read(completeMobileCensusUseCaseProvider);

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

    final params = current.prescriptionItems
        .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending)
        .map((i) {
          final isSelected = current.selectedItemIds.contains(i.id);
          return MobileCensusParams(
            prescriptionDetailId: i.id!,
            dosePiece: isSelected ? i.dosePiece?.toDouble() : 0,
            epc: isSelected ? i.rfidTag : null,
          );
        })
        .toList();

    final result = await _completeCensus(params);

    result.when(
      ok: (_) async {
        await _drawer.stop();

        state = MobileCensusSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: '',
          ready: current.copyWith(rfidReadEpcs: {}, selectedItemIds: {}),
        );
      },
      error: (e) {
        state = MobileCensusError(
          message: e.message,
          previousState: current.copyWith(rfidReadEpcs: {}, selectedItemIds: {}),
        );
      },
    );
  }

  /// EPC okundu → ilaç kabinde mevcut: rfidReadEpcs'e ekle.
  ///
  /// SWREQ-CLI-CENSUS-004
  void _onEpcRead(String epc) {
    final current = state;
    if (current is! MobileCensusReady) return;
    if (current.rfidReadEpcs.contains(epc)) return;

    state = current.copyWith(rfidReadEpcs: {...current.rfidReadEpcs, epc});

    MedLogger.info(
      unit: 'MobileCensusNotifier',
      swreq: 'SWREQ-CLI-CENSUS-004',
      message: 'RFID tag okundu — ilaç kabinde mevcut',
      context: {'epc': epc},
    );
  }

  /// EPC kayboldu → ilaç kabinden çıkarıldı: rfidReadEpcs'ten çıkar.
  ///
  /// SWREQ-CLI-CENSUS-005
  void _onEpcLost(String epc) {
    final current = state;
    if (current is! MobileCensusReady) return;
    if (!current.rfidReadEpcs.contains(epc)) return;

    final updated = Set<String>.from(current.rfidReadEpcs)..remove(epc);
    state = current.copyWith(rfidReadEpcs: updated);

    MedLogger.info(
      unit: 'MobileCensusNotifier',
      swreq: 'SWREQ-CLI-CENSUS-005',
      message: 'RFID tag kapsama dışına çıktı — ilaç kabinde yok',
      context: {'epc': epc},
    );
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerFailed) {
      final current = state;
      final cleaned = switch (current) {
        MobileCensusReady r => r.copyWith(rfidReadEpcs: {}, selectedItemIds: {}),
        MobileCensusSaving(:final ready) => ready.copyWith(rfidReadEpcs: {}, selectedItemIds: {}),
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
      params: PagedQueryParamsBuilder.fromPreset(preset: DateRangePreset.today),
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
}
