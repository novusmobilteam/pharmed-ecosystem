// [SWREQ-UI-CAB-006]
// PatientAssignmentView için sealed UI state.
// Sadece mobil kabinde kullanılır — DrawerGroup değil
// MobileSlotVisual + MobileCellCoord bazlıdır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';

sealed class PatientAssignmentState {
  const PatientAssignmentState();
}

/// init() çağrılana kadar geçici state.
final class PatientAssignmentUninitialized extends PatientAssignmentState {
  const PatientAssignmentUninitialized();
}

/// Atamalar yükleniyor.
final class PatientAssignmentLoading extends PatientAssignmentState {
  const PatientAssignmentLoading({required this.slots, required this.cabinId});

  final List<MobileSlotVisual> slots;
  final int cabinId;
}

/// Kabin verisi yüklendi, slot seçilmedi.

final class PatientAssignmentIdle extends PatientAssignmentState {
  const PatientAssignmentIdle({
    required this.slots,
    required this.mobileSlots,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final List<PatientAssignment> assignments;
  final int cabinId;
}

/// Slot (çekmece) seçildi, hücre seçilmedi.
final class PatientAssignmentSlotSelected extends PatientAssignmentState {
  const PatientAssignmentSlotSelected({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<PatientAssignment> assignments;
  final int cabinId;

  int get selectedSlotId => selectedSlot.slotId;
}

/// Hücre seçildi — sağ panel aktif.
///
/// [selectedHospitalization] null → yatış henüz seçilmedi.
/// [isAssigned] true → bu hücrede daha önce atama yapılmış.
final class PatientAssignmentCellSelected extends PatientAssignmentState {
  const PatientAssignmentCellSelected({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.selectedCell,
    required this.assignments,
    required this.cabinId,
    this.existingAssignment,
    this.selectedHospitalization,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final List<PatientAssignment> assignments;
  final int cabinId;
  final PatientAssignment? existingAssignment;
  final Hospitalization? selectedHospitalization;

  bool get canSave => selectedHospitalization != null;
  bool get isAssigned => existingAssignment != null;
  int get selectedSlotId => selectedSlot.slotId;

  PatientAssignmentCellSelected copyWith({
    Hospitalization? selectedHospitalization,
    PatientAssignment? existingAssignment,
  }) {
    return PatientAssignmentCellSelected(
      slots: slots,
      mobileSlots: mobileSlots,
      selectedSlot: selectedSlot,
      selectedCell: selectedCell,
      assignments: assignments,
      cabinId: cabinId,
      existingAssignment: existingAssignment ?? this.existingAssignment,
      selectedHospitalization: selectedHospitalization ?? this.selectedHospitalization,
    );
  }
}

/// Kayıt / silme işlemi devam ediyor.
final class PatientAssignmentSaving extends PatientAssignmentState {
  const PatientAssignmentSaving({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<PatientAssignment> assignments;
  final int cabinId;
}

final class PatientAssignmentSuccess extends PatientAssignmentState {
  const PatientAssignmentSuccess({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
    required this.message,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<PatientAssignment> assignments;
  final int cabinId;
  final String message;
}

/// İşlem hatası — previousState'e dönülür.
final class PatientAssignmentError extends PatientAssignmentState {
  const PatientAssignmentError({required this.message, required this.previousState});

  final String message;
  final PatientAssignmentState previousState;
}

extension PatientAssignmentStateX on PatientAssignmentState {
  List<MobileSlotVisual> get slots => switch (this) {
    PatientAssignmentLoading(:final slots) => slots,
    PatientAssignmentIdle(:final slots) => slots,
    PatientAssignmentSlotSelected(:final slots) => slots,
    PatientAssignmentCellSelected(:final slots) => slots,
    PatientAssignmentSaving(:final slots) => slots,
    PatientAssignmentSuccess(:final slots) => slots,
    PatientAssignmentError(:final previousState) => previousState.slots,
    PatientAssignmentUninitialized() => const [],
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    PatientAssignmentIdle(:final mobileSlots) => mobileSlots,
    PatientAssignmentSlotSelected(:final mobileSlots) => mobileSlots,
    PatientAssignmentCellSelected(:final mobileSlots) => mobileSlots,
    PatientAssignmentSaving(:final mobileSlots) => mobileSlots,
    PatientAssignmentSuccess(:final mobileSlots) => mobileSlots,
    PatientAssignmentError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<PatientAssignment> get assignments => switch (this) {
    PatientAssignmentIdle(:final assignments) => assignments,
    PatientAssignmentSlotSelected(:final assignments) => assignments,
    PatientAssignmentCellSelected(:final assignments) => assignments,
    PatientAssignmentSaving(:final assignments) => assignments,
    PatientAssignmentSuccess(:final assignments) => assignments,
    PatientAssignmentError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    PatientAssignmentSlotSelected(:final selectedSlotId) => selectedSlotId,
    PatientAssignmentCellSelected(:final selectedSlotId) => selectedSlotId,
    PatientAssignmentSaving(:final selectedSlot) => selectedSlot.slotId,
    PatientAssignmentSuccess(:final selectedSlot) => selectedSlot.slotId,
    PatientAssignmentError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    PatientAssignmentSlotSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentCellSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentSaving(:final selectedSlot) => selectedSlot,
    PatientAssignmentSuccess(:final selectedSlot) => selectedSlot,
    PatientAssignmentError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    PatientAssignmentCellSelected(:final selectedCell) => selectedCell,
    PatientAssignmentError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    PatientAssignmentLoading(:final cabinId) => cabinId,
    PatientAssignmentIdle(:final cabinId) => cabinId,
    PatientAssignmentSlotSelected(:final cabinId) => cabinId,
    PatientAssignmentCellSelected(:final cabinId) => cabinId,
    PatientAssignmentSaving(:final cabinId) => cabinId,
    PatientAssignmentSuccess(:final cabinId) => cabinId,
    PatientAssignmentError(:final previousState) => previousState.cabinId,
    PatientAssignmentUninitialized() => 0,
  };

  Map<MobileCellCoord, PatientAssignment> get assignmentByCoord {
    final map = <MobileCellCoord, PatientAssignment>{};
    for (final a in assignments) {
      if (a.cellId == null) continue;
      final coord = _resolveCoord(mobileSlots: mobileSlots, cellId: a.cellId!);
      if (coord != null) map[coord] = a;
    }
    return map;
  }

  MobileCellCoord? _resolveCoord({required List<MobileDrawerSlot> mobileSlots, required int cellId}) {
    for (final slot in mobileSlots) {
      for (int uIdx = 0; uIdx < slot.units.length; uIdx++) {
        final unit = slot.units[uIdx];
        for (int cIdx = 0; cIdx < unit.cells.length; cIdx++) {
          if (unit.cells[cIdx].id == cellId) {
            return (slot.id, uIdx, cIdx); // orderNo - 1 değil, index
          }
        }
      }
    }
    return null;
  }
}
