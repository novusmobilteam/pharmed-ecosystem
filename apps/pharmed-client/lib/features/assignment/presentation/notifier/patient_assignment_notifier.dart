// lib/features/assignment/presentation/notifier/patient_assignment_notifier.dart
//
// [SWREQ-UI-CAB-006]
// Hasta bazlı atama ekranı state yönetimi.
// Sadece mobil kabinde çalışır.
//
// Şu an desteklenen işlemler:
//   - Slot (çekmece) seç / toggle
//   - Hücre seç (MobileCellCoord)
//   - Yatış seç (dialogdan)
//
// NOT: saveAssignment / deleteAssignment PatientCabinAssignment modeli
// ve servisi netleşince eklenecek — şimdilik stub olarak bırakıldı.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../shared/widgets.dart';
import '../state/patient_assignment_ui_state.dart';

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

final patientAssignmentNotifierProvider = NotifierProvider<PatientAssignmentNotifier, PatientAssignmentUiState>(
  PatientAssignmentNotifier.new,
);

// ─────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────

class PatientAssignmentNotifier extends Notifier<PatientAssignmentUiState> {
  @override
  PatientAssignmentUiState build() => const PatientAssignmentUninitialized();

  // ── Init ──────────────────────────────────────────────────────

  void init(CabinVisualizerData data) {
    final slots = data.slots.whereType<MobileSlotVisual>().toList();
    state = PatientAssignmentIdle(slots: slots);
  }

  // ── Slot seçimi ───────────────────────────────────────────────

  void onSlotTap(MobileSlotVisual slot) {
    final slots = _extractSlots(state);

    // Toggle — aynı slota tekrar basılırsa Idle'a dön
    final currentSlotId = switch (state) {
      PatientAssignmentSlotSelected s => s.selectedSlotId,
      PatientAssignmentCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId != null && currentSlotId == slot.slotId) {
      state = PatientAssignmentIdle(slots: slots);
      return;
    }

    state = PatientAssignmentSlotSelected(slots: slots, selectedSlot: slot);
  }

  // ── Hücre seçimi ──────────────────────────────────────────────

  void onCellTap(MobileCellCoord coord) {
    final current = state;
    final slots = _extractSlots(current);
    final selectedSlot = _extractSelectedSlot(current);
    if (selectedSlot == null) return;

    // Aynı hücreye tekrar basılırsa slot seçili duruma dön
    if (current is PatientAssignmentCellSelected && current.selectedCell == coord) {
      state = PatientAssignmentSlotSelected(slots: slots, selectedSlot: selectedSlot);
      return;
    }

    // TODO: PatientCabinAssignment gelince mevcut atamayı
    // coord üzerinden lookup yapıp isAssigned / selectedHospitalization
    // alanlarını doldur.
    state = PatientAssignmentCellSelected(
      slots: slots,
      selectedSlot: selectedSlot,
      selectedCell: coord,
      selectedHospitalization: null,
      isAssigned: false,
    );
  }

  // ── Yatış seçimi (dialogdan) ──────────────────────────────────

  void onHospitalizationSelected(Hospitalization hospitalization) {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;

    state = current.copyWith(selectedHospitalization: hospitalization);
  }

  // ── Kaydet (stub) ─────────────────────────────────────────────

  /// PatientCabinAssignment modeli ve servisi netleşince implemente edilecek.
  Future<void> saveAssignment() async {
    // TODO: implement
  }

  // ── Sil (stub) ────────────────────────────────────────────────

  /// PatientCabinAssignment modeli ve servisi netleşince implemente edilecek.
  Future<void> deleteAssignment() async {
    // TODO: implement
  }

  // ── Hata dismiss ──────────────────────────────────────────────

  void dismissError() {
    if (state is PatientAssignmentError) {
      state = (state as PatientAssignmentError).previousState;
    }
  }

  // ── Extract yardımcıları ──────────────────────────────────────

  List<MobileSlotVisual> _extractSlots(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentIdle(:final slots) => slots,
    PatientAssignmentLoading(:final slots) => slots,
    PatientAssignmentSlotSelected(:final slots) => slots,
    PatientAssignmentCellSelected(:final slots) => slots,
    PatientAssignmentSaving(:final slots) => slots,
    _ => const [],
  };

  MobileSlotVisual? _extractSelectedSlot(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentSlotSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentCellSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentSaving(:final selectedSlot) => selectedSlot,
    _ => null,
  };
}
