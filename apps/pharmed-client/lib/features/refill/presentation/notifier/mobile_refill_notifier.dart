import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../refill.dart';

// [SWREQ-CLI-REFILL-004] [IEC 62304 §5.5]
// Mobil kabin dolum ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan slot + atama verilerini alır
//   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
//   - Dolum başlatma → isRefilling flag'ini set eder
//   - RFID okuma → rfidReadIds günceller
//   - Dolum tamamlama → RefillMobileCabinUseCase çağırır
//
// Sınıf: Class B

final mobileRefillNotifierProvider = NotifierProvider<MobileRefillNotifier, MobileRefillState>(
  MobileRefillNotifier.new,
);

class MobileRefillNotifier extends Notifier<MobileRefillState> {
  late final MobileDrawerOrchestrator _drawer;
  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  RefillMobileCabinUseCase get _refillMobileCabin => ref.read(refillMobileCabinUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  @override
  MobileRefillState build() {
    // Drawer stage geçişlerini dinle — Opened/Closed/Failed'a tepki ver.
    _drawer = MobileDrawerOrchestrator(ref: ref)..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead);

    ref.onDispose(() => _drawer.dispose());

    return const MobileRefillUninitialized();
  }

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

  /// Panel'deki hasta listesinden bir hasta seçildiğinde çağrılır.
  /// İlgili göze otomatik gider — mevcut [onCellTap] akışını kullanır.
  Future<void> selectAssignment(BedAssignment assignment) async {
    if (assignment.cellId == null) return;

    final coord = state.assignmentByCoord.entries
        .where((e) => e.value.id == assignment.id)
        .map((e) => e.key)
        .firstOrNull;
    if (coord == null) return;

    // Slot henüz seçili değilse önce seç (onCellTap selectedSlot null ise döner)
    final slot = state.slots.where((s) => s.slotId == coord.$1).firstOrNull;
    if (slot == null) return;
    if (state.selectedSlotId != slot.slotId) {
      onSlotTap(slot);
    }

    await onCellTap(coord);
  }

  /// Ready/NoPatient state'inden hasta listesine geri döner.
  /// Slot seçimi korunur (kullanıcı aynı çekmecedeyse devam edebilir).
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

  // Reçete yükleme
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

    // Loading sırasında sol/orta panel kaybolmasın
    state = MobileRefillLoading(slots: slots, cabinId: cabinId);

    final result = await _getPrescriptionHistory(patient!.id!);

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
          rfidReadEpcs: const {},
          selectedItemIds: {},
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

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    // Refill için stage'e özel bir state müdahalesi şu an yok.
    // RFID start/stop otomasyonu orchestrator'da hallediliyor.
    // İleride: Failed durumunda kullanıcıya snackbar göstermek için
    // bir sinyal yayınlanabilir, view'da ref.listen ile yakalanır.
  }

  void _onEpcRead(String epc) {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (current.rfidReadEpcs.contains(epc)) return;
    state = current.copyWith(rfidReadEpcs: {...current.rfidReadEpcs, epc});
  }

  /// Doluma başla — drawer oturumunu açar.
  Future<void> startRefill() async {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (current.selectedItemIds.isEmpty) return;

    await _drawer.open(slots: current.slots, slot: current.selectedSlot);
  }

  /// Çekmeceyi tekrar aç — RFID eksikse "Doluma Devam Et" butonuna bağlanır.
  Future<void> reopenDrawer() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// İlaç işaretle/işareti kaldır.
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileRefillReady) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
  }

  /// Dolumu tamamla — drawer Closed + tüm seçili RFID etiketler okundu olmalı.
  Future<void> completeRefill() async {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (current.selectedItemIds.isEmpty) return;
    if (!current.allSelectedRfidRead) return;

    // Çekmece kapanmış olmalı
    final drawerStage = ref.read(mobileDrawerSessionProvider).stage;
    if (drawerStage is! MobileDrawerClosed) return;

    state = MobileRefillSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );

    final params = current.prescriptionItems
        .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
        .map((i) => RefillMobileCabinParams(prescriptionDetailId: i.id!, epc: i.rfidTag ?? ''))
        .toList();

    final result = await _refillMobileCabin(params);

    result.when(
      ok: (_) async {
        // Drawer + RFID oturumlarını sıfırla, banner kaybolur
        await _drawer.stop();

        state = MobileRefillSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          assignments: current.assignments,
          cabinId: current.cabinId,
          message: 'Dolum başarıyla tamamlandı.',
        );
      },
      error: (e) {
        state = MobileRefillError(message: e.message, previousState: current);
      },
    );
  }

  // Slot seçimi
  void onSlotTap(MobileSlotVisual slot) {
    final current = state;
    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    // Aynı slot tekrar tıklandıysa — Idle'a dön
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

  // Göz seçimi
  Future<void> onCellTap(MobileCellCoord coord) async {
    final current = state;
    final selectedSlot = current.selectedSlot;
    if (selectedSlot == null) return;

    final slots = current.slots;
    final ms = current.mobileSlots;
    final assignments = current.assignments;
    final cabinId = current.cabinId;

    // Aynı göz tekrar tıklandıysa — SlotSelected'a dön
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

    // Gözdeki atamayı bul
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

    // Hasta var — reçeteleri çek
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

  // Dismiss
  void dismissError() {
    final current = state;
    if (current is! MobileRefillError) return;
    state = current.previousState;
  }

  void dismissSuccess() {
    final current = state;
    if (current is! MobileRefillSuccess) return;
    state = MobileRefillIdle(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );
  }
}
