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

import '../../../../widgets/widgets.dart';
import '../../assignment.dart';

final patientAssignmentNotifierProvider = NotifierProvider<PatientAssignmentNotifier, PatientAssignmentUiState>(
  PatientAssignmentNotifier.new,
);

class PatientAssignmentNotifier extends Notifier<PatientAssignmentUiState> {
  @override
  PatientAssignmentUiState build() => const PatientAssignmentUninitialized();

  CreatePatientAssignmentUseCase get _createAssignment => ref.read(createPatientAssignmentUseCaseProvider);

  // Init
  void init(CabinVisualizerData data) {
    state = PatientAssignmentIdle(
      slots: data.slots.whereType<MobileSlotVisual>().toList(),
      mobileSlots: data.mobileSlots,
    );
  }

  // Slot seçimi
  void onSlotTap(MobileSlotVisual slot) {
    final slots = _slots;
    final mobileSlots = _mobileSlots;

    final currentSlotId = switch (state) {
      PatientAssignmentSlotSelected s => s.selectedSlotId,
      PatientAssignmentCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == slot.slotId) {
      state = PatientAssignmentIdle(slots: slots, mobileSlots: mobileSlots);
      return;
    }

    state = PatientAssignmentSlotSelected(slots: slots, mobileSlots: mobileSlots, selectedSlot: slot);
  }

  // Hücre seçimi
  void onCellTap(MobileCellCoord coord) {
    final current = state;
    final selectedSlot = _selectedSlot;
    if (selectedSlot == null) return;

    if (current is PatientAssignmentCellSelected && current.selectedCell == coord) {
      state = PatientAssignmentSlotSelected(slots: _slots, mobileSlots: _mobileSlots, selectedSlot: selectedSlot);
      return;
    }

    state = PatientAssignmentCellSelected(
      slots: _slots,
      mobileSlots: _mobileSlots,
      selectedSlot: selectedSlot,
      selectedCell: coord,
    );
  }

  // Yatış seçimi
  void onHospitalizationSelected(Hospitalization hospitalization) {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;
    state = current.copyWith(selectedHospitalization: hospitalization);
  }

  // Kaydet
  Future<void> saveAssignment() async {
    final current = state;
    if (current is! PatientAssignmentCellSelected) return;
    if (!current.canSave) return;

    // Seçili coord'dan MobileDrawerCell.id bul
    final cellId = _resolveCellId(mobileSlots: current.mobileSlots, coord: current.selectedCell);

    if (cellId == null) {
      state = PatientAssignmentError(message: 'Seçili göz bulunamadı', previousState: current);
      return;
    }

    state = PatientAssignmentSaving(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
    );

    final result = await _createAssignment.call(cellId: cellId, bedId: current.selectedHospitalization!.bedId!);

    result.when(
      ok: (_) {
        state = PatientAssignmentSuccess(
          slots: current.slots,
          mobileSlots: current.mobileSlots,
          selectedSlot: current.selectedSlot,
          message: 'Hasta ataması başarıyla kaydedildi',
        );
      },
      error: (e) {
        state = PatientAssignmentError(message: e.message, previousState: current);
      },
    );
  }

  /// PatientCabinAssignment modeli ve servisi netleşince implemente edilecek.
  Future<void> deleteAssignment() async {
    // TODO: implement
  }

  void dismissError() {
    if (state is PatientAssignmentError) {
      state = (state as PatientAssignmentError).previousState;
    }
  }

  void dismissSuccess() {
    final current = state;
    if (current is! PatientAssignmentSuccess) return;
    state = PatientAssignmentSlotSelected(
      slots: current.slots,
      mobileSlots: current.mobileSlots,
      selectedSlot: current.selectedSlot,
    );
  }

  // MobileCellCoord → MobileDrawerCell.id çözümleyici
  //
  // coord.slotId → MobileDrawerSlot.id
  // coord.rowIndex → MobileDrawerUnit sırası (orderNo - 1)
  // coord.colIndex → MobileDrawerCell sırası (stepNo - 1)

  int? _resolveCellId({required List<MobileDrawerSlot> mobileSlots, required MobileCellCoord coord}) {
    final slot = mobileSlots.where((s) => s.id == coord.$1).firstOrNull;
    if (slot == null) return null;

    final unit = slot.units.where((u) => u.orderNo - 1 == coord.$2).firstOrNull;
    if (unit == null) return null;

    final cell = unit.cells.where((c) => c.stepNo - 1 == coord.$3).firstOrNull;
    return cell?.id;
  }

  // Extract yardımcıları

  List<MobileSlotVisual> get _slots => switch (state) {
    PatientAssignmentIdle(:final slots) => slots,
    PatientAssignmentSlotSelected(:final slots) => slots,
    PatientAssignmentCellSelected(:final slots) => slots,
    PatientAssignmentSaving(:final slots) => slots,
    PatientAssignmentSuccess(:final slots) => slots,
    _ => const [],
  };

  List<MobileDrawerSlot> get _mobileSlots => switch (state) {
    PatientAssignmentIdle(:final mobileSlots) => mobileSlots,
    PatientAssignmentSlotSelected(:final mobileSlots) => mobileSlots,
    PatientAssignmentCellSelected(:final mobileSlots) => mobileSlots,
    PatientAssignmentSaving(:final mobileSlots) => mobileSlots,
    PatientAssignmentSuccess(:final mobileSlots) => mobileSlots,

    _ => const [],
  };

  MobileSlotVisual? get _selectedSlot => switch (state) {
    PatientAssignmentSlotSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentCellSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentSaving(:final selectedSlot) => selectedSlot,
    PatientAssignmentSuccess(:final selectedSlot) => selectedSlot,
    _ => null,
  };
}
