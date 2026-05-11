import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';

final mobileIntakeNotifierProvider = NotifierProvider<MobileIntakeNotifier, MobileIntakeState>(
  MobileIntakeNotifier.new,
);

class MobileIntakeNotifier extends Notifier<MobileIntakeState> {
  late final MobileDrawerOrchestrator _drawer;
  MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);
  CheckMobileIntakeUseCase get _checkIntake => ref.read(checkMobileIntakeUseCaseProvider);
  CompleteMobileIntakeUseCase get _completeIntake => ref.read(completeMobileIntakeUseCaseProvider);

  @override
  MobileIntakeState build() {
    // Drawer stage geçişlerini dinle — Opened/Closed/Failed'a tepki ver.
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

    state = MobileIntakeSlotSelected(
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
    state = MobileIntakeLoading(
      slots: slots,
      cabinId: cabinId,
      selectedSlot: selectedSlot,
      mobileSlots: mobileSlots,
      assignments: assignments,
    );

    final result = await _getPrescriptionHistory(patient!.id!);

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

  void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
    if (next is MobileDrawerFailed) {
      final current = state;
      final cleaned = switch (current) {
        MobileIntakeReady r => r.copyWith(rfidReadEpcs: {}, selectedItemIds: {}),
        _ => current,
      };
      state = MobileIntakeError(message: next.message, previousState: cleaned);
    }
  }

  void _onEpcRead(String epc) {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (current.rfidReadEpcs.contains(epc)) return;
    state = current.copyWith(rfidReadEpcs: {...current.rfidReadEpcs, epc});
  }

  void _onEpcLost(String epc) {
    final current = state;
    if (current is! MobileIntakeReady) return;
    if (!current.rfidReadEpcs.contains(epc)) return;
    final updated = Set<String>.from(current.rfidReadEpcs)..remove(epc);
    state = current.copyWith(rfidReadEpcs: updated);
    MedLogger.info(
      unit: 'MobileIntakeNotifier',
      swreq: 'SWREQ-CLI-Intake-003',
      message: 'RFID tag kapsama dışına çıktı',
      context: {'epc': epc},
    );
  }

  /// Çekmeceyi tekrar aç — RFID eksikse "Doluma Devam Et" butonuna bağlanır.
  Future<void> reopenDrawer() async {
    await ref.read(mobileDrawerSessionProvider.notifier).reopen();
  }

  /// İlaç işaretle/işareti kaldır.
  void toggleItemSelection(int itemId) {
    final current = state;
    if (current is! MobileIntakeReady) return;

    final next = {...current.selectedItemIds};
    if (!next.add(itemId)) next.remove(itemId);
    state = current.copyWith(selectedItemIds: next);
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
      state = MobileIntakeSlotSelected(
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
}
