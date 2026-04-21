// [SWREQ-UI-CAB-006]
// PatientAssignmentView için sealed UI state.
// Sadece mobil kabinde kullanılır — DrawerGroup değil
// MobileSlotVisual + MobileCellCoord bazlıdır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';

sealed class BedAssignmentState {
  const BedAssignmentState();
}

/// init() çağrılana kadar geçici state.
final class BedAssignmentUninitialized extends BedAssignmentState {
  const BedAssignmentUninitialized();
}

/// Atamalar yükleniyor.
final class BedAssignmentLoading extends BedAssignmentState {
  const BedAssignmentLoading({required this.slots, required this.cabinId});

  final List<MobileSlotVisual> slots;
  final int cabinId;
}

/// Kabin verisi yüklendi, slot seçilmedi.

final class BedAssignmentIdle extends BedAssignmentState {
  const BedAssignmentIdle({
    required this.slots,
    required this.mobileSlots,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final List<BedAssignment> assignments;
  final int cabinId;
}

/// Slot (çekmece) seçildi, hücre seçilmedi.
final class BedAssignmentSlotSelected extends BedAssignmentState {
  const BedAssignmentSlotSelected({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;

  int get selectedSlotId => selectedSlot.slotId;
}

/// Hücre seçildi — sağ panel aktif.
///
/// [isAssigned] true → bu hücrede daha önce atama yapılmış.
final class BedAssignmentCellSelected extends BedAssignmentState {
  const BedAssignmentCellSelected({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.selectedCell,
    required this.assignments,
    required this.cabinId,
    required this.services,
    this.existingAssignment,
    this.selectedService,
    this.rooms = const [],
    this.selectedRoom,
    this.beds = const [],
    this.selectedBed,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final List<BedAssignment> assignments;
  final int cabinId;
  final BedAssignment? existingAssignment;

  // Yatak seçim zinciri
  final List<HospitalService> services;
  final HospitalService? selectedService;
  final List<Room> rooms;
  final Room? selectedRoom;
  final List<Bed> beds;
  final Bed? selectedBed;

  bool get canSave => selectedBed != null;
  bool get isAssigned => existingAssignment != null;
  int get selectedSlotId => selectedSlot.slotId;

  static const _sentinel = Object();

  BedAssignmentCellSelected copyWith({
    Object? selectedService = _sentinel,
    Object? rooms = _sentinel,
    Object? selectedRoom = _sentinel,
    Object? beds = _sentinel,
    Object? selectedBed = _sentinel,
    BedAssignment? existingAssignment,
  }) {
    return BedAssignmentCellSelected(
      slots: slots,
      mobileSlots: mobileSlots,
      selectedSlot: selectedSlot,
      selectedCell: selectedCell,
      assignments: assignments,
      cabinId: cabinId,
      services: services,
      existingAssignment: existingAssignment ?? this.existingAssignment,
      selectedService: selectedService == _sentinel ? this.selectedService : selectedService as HospitalService?,
      rooms: rooms == _sentinel ? this.rooms : (rooms as List<Room>?) ?? const [],
      selectedRoom: selectedRoom == _sentinel ? this.selectedRoom : selectedRoom as Room?,
      beds: beds == _sentinel ? this.beds : (beds as List<Bed>?) ?? const [],
      selectedBed: selectedBed == _sentinel ? this.selectedBed : selectedBed as Bed?,
    );
  }
}

/// Kayıt / silme işlemi devam ediyor.
final class BedAssignmentSaving extends BedAssignmentState {
  const BedAssignmentSaving({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;
}

final class BedAssignmentSuccess extends BedAssignmentState {
  const BedAssignmentSuccess({
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
  final List<BedAssignment> assignments;
  final int cabinId;
  final String message;
}

/// İşlem hatası — previousState'e dönülür.
final class BedAssignmentError extends BedAssignmentState {
  const BedAssignmentError({required this.message, required this.previousState});

  final String message;
  final BedAssignmentState previousState;
}

extension BedAssignmentStateX on BedAssignmentState {
  List<MobileSlotVisual> get slots => switch (this) {
    BedAssignmentLoading(:final slots) => slots,
    BedAssignmentIdle(:final slots) => slots,
    BedAssignmentSlotSelected(:final slots) => slots,
    BedAssignmentCellSelected(:final slots) => slots,
    BedAssignmentSaving(:final slots) => slots,
    BedAssignmentSuccess(:final slots) => slots,
    BedAssignmentError(:final previousState) => previousState.slots,
    BedAssignmentUninitialized() => const [],
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    BedAssignmentIdle(:final mobileSlots) => mobileSlots,
    BedAssignmentSlotSelected(:final mobileSlots) => mobileSlots,
    BedAssignmentCellSelected(:final mobileSlots) => mobileSlots,
    BedAssignmentSaving(:final mobileSlots) => mobileSlots,
    BedAssignmentSuccess(:final mobileSlots) => mobileSlots,
    BedAssignmentError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    BedAssignmentIdle(:final assignments) => assignments,
    BedAssignmentSlotSelected(:final assignments) => assignments,
    BedAssignmentCellSelected(:final assignments) => assignments,
    BedAssignmentSaving(:final assignments) => assignments,
    BedAssignmentSuccess(:final assignments) => assignments,
    BedAssignmentError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    BedAssignmentSlotSelected(:final selectedSlotId) => selectedSlotId,
    BedAssignmentCellSelected(:final selectedSlotId) => selectedSlotId,
    BedAssignmentSaving(:final selectedSlot) => selectedSlot.slotId,
    BedAssignmentSuccess(:final selectedSlot) => selectedSlot.slotId,
    BedAssignmentError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    BedAssignmentSlotSelected(:final selectedSlot) => selectedSlot,
    BedAssignmentCellSelected(:final selectedSlot) => selectedSlot,
    BedAssignmentSaving(:final selectedSlot) => selectedSlot,
    BedAssignmentSuccess(:final selectedSlot) => selectedSlot,
    BedAssignmentError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    BedAssignmentCellSelected(:final selectedCell) => selectedCell,
    BedAssignmentError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    BedAssignmentLoading(:final cabinId) => cabinId,
    BedAssignmentIdle(:final cabinId) => cabinId,
    BedAssignmentSlotSelected(:final cabinId) => cabinId,
    BedAssignmentCellSelected(:final cabinId) => cabinId,
    BedAssignmentSaving(:final cabinId) => cabinId,
    BedAssignmentSuccess(:final cabinId) => cabinId,
    BedAssignmentError(:final previousState) => previousState.cabinId,
    BedAssignmentUninitialized() => 0,
  };

  List<HospitalService> get services => switch (this) {
    BedAssignmentCellSelected(:final services) => services,
    _ => const [],
  };

  HospitalService? get selectedService => switch (this) {
    BedAssignmentCellSelected(:final selectedService) => selectedService,
    _ => null,
  };

  List<Room> get rooms => switch (this) {
    BedAssignmentCellSelected(:final rooms) => rooms,
    _ => const [],
  };

  Room? get selectedRoom => switch (this) {
    BedAssignmentCellSelected(:final selectedRoom) => selectedRoom,
    _ => null,
  };

  List<Bed> get beds => switch (this) {
    BedAssignmentCellSelected(:final beds) => beds,
    _ => const [],
  };

  Bed? get selectedBed => switch (this) {
    BedAssignmentCellSelected(:final selectedBed) => selectedBed,
    _ => null,
  };

  Map<MobileCellCoord, BedAssignment> get assignmentByCoord {
    final map = <MobileCellCoord, BedAssignment>{};
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
