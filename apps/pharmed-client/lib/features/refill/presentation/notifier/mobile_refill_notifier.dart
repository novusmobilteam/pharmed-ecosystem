import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';
import '../../../assignment/assignment.dart';
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
  @override
  MobileRefillState build() => const MobileRefillUninitialized();

  GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);

  GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
      ref.read(getPatientPrescriptionHistoryUseCaseProvider);

  RefillMobileCabinUseCase get _refillMobileCabin => ref.read(refillMobileCabinUseCaseProvider);

  // ── Init ─────────────────────────────────────────────────────────────────

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
  // ── Slot seçimi ───────────────────────────────────────────────────────────

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

  // ── Göz seçimi ────────────────────────────────────────────────────────────

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

  // ── Reçete yükleme ────────────────────────────────────────────────────────

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
          rfidReadIds: const {},
          isRefilling: false,
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

  // ── Dolum başlatma ────────────────────────────────────────────────────────

  void startRefill() {
    final current = state;
    if (current is! MobileRefillReady) return;
    state = current.copyWith(isRefilling: true);
  }

  // ── RFID okuma güncellemesi ───────────────────────────────────────────────

  /// RFID servisi bir etiket okuduğunda çağrılır.
  /// [itemId] → PrescriptionItem.id
  void onRfidRead(int itemId) {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (!current.isRefilling) return;
    state = current.copyWith(rfidReadIds: {...current.rfidReadIds, itemId});
  }

  // ── Dolum tamamlama ───────────────────────────────────────────────────────

  Future<void> completeRefill() async {
    final current = state;
    if (current is! MobileRefillReady) return;
    if (!current.allRfidRead) return;

    state = MobileRefillSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
      assignments: current.assignments,
      cabinId: current.cabinId,
    );

    // Her PrescriptionItem için ayrı params oluştur.
    // RFID'li ilaçlarda epc tag'i gönderilir, RFID'siz ilaçlarda boş string.
    final params = current.prescriptionItems
        .where((i) => i.id != null)
        .map((i) => RefillMobileCabinParams(prescriptionDetailId: i.id!, epc: i.rfidTag ?? ''))
        .toList();

    final result = await _refillMobileCabin(params);

    result.when(
      ok: (_) {
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

  // ── Dismiss ───────────────────────────────────────────────────────────────

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
