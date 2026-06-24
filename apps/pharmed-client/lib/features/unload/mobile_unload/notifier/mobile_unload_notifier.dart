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
  CompleteMobileUnloadUseCase get _completeUnload => ref.read(completeMobileUnloadUseCaseProvider);

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
    if (current.selectedItemIds.isEmpty) return;

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

  /// Boşaltmayı tamamla — çekmece kapalı + [MobileUnloadReady.canComplete] true olmalı.
  ///
  /// Use case'e sadece prescriptionDetailId listesi gönderilir.
  ///
  /// SWREQ-CLI-UNLOAD-003
  Future<void> completeUnload() async {
    final current = state;
    if (current is! MobileUnloadReady) return;
    if (current.selectedItemIds.isEmpty) return;
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

    final ids = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map((i) => MobileUnloadParams(prescriptionDetailId: i.id))
        .toList();

    final result = await _completeUnload(ids);

    result.when(
      ok: (_) async {
        await _drawer.stop();

        state = MobileUnloadSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: '',
          ready: current.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        );
      },
      error: (e) {
        state = MobileUnloadError(
          message: e.message,
          previousState: current.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        );
      },
    );
  }

  /// EPC okundu → ilaç geri konuldu: takenEpcs'ten çıkar.
  ///
  /// SWREQ-CLI-UNLOAD-004
  void _onEpcRead(String epc) {
    final current = state;
    if (current is! MobileUnloadReady) return;

    final wasTaken = current.takenEpcs.contains(epc);
    final alreadyRead = current.rfidReadEpcs.contains(epc);
    if (!wasTaken && alreadyRead) return;

    final newTaken = Set<String>.from(current.takenEpcs)..remove(epc);
    final newRead = {...current.rfidReadEpcs, epc};

    state = current.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken);

    if (wasTaken) {
      MedLogger.info(
        unit: 'MobileUnloadNotifier',
        swreq: 'SWREQ-CLI-UNLOAD-004',
        message: 'RFID tag tekrar kapsama alanına girdi — boşaltıldı sayımından çıkarıldı',
        context: {'epc': epc},
      );
    }
  }

  /// EPC kayboldu → ilaç kabinden çıkarıldı: takenEpcs'e ekle.
  ///
  /// SWREQ-CLI-UNLOAD-005
  void _onEpcLost(String epc) {
    final current = state;
    if (current is! MobileUnloadReady) return;
    if (current.takenEpcs.contains(epc)) return;

    final newRead = Set<String>.from(current.rfidReadEpcs)..remove(epc);
    final newTaken = {...current.takenEpcs, epc};

    state = current.copyWith(rfidReadEpcs: newRead, takenEpcs: newTaken);

    MedLogger.info(
      unit: 'MobileUnloadNotifier',
      swreq: 'SWREQ-CLI-UNLOAD-005',
      message: 'RFID tag kapsama dışına çıktı — boşaltıldı olarak işaretlendi',
      context: {'epc': epc},
    );
  }

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerFailed) {
      final current = state;
      final cleaned = switch (current) {
        MobileUnloadReady r => r.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        MobileUnloadSaving(:final ready) => ready.copyWith(rfidReadEpcs: {}, takenEpcs: {}, selectedItemIds: {}),
        _ => current,
      };
      state = MobileUnloadError(message: next.message, previousState: cleaned);
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
      params: PagedQueryParamsBuilder.fromPreset(preset: DateRangePreset.today),
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
}
