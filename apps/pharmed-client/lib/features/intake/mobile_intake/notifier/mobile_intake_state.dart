import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';

sealed class MobileIntakeState {
  const MobileIntakeState();
}

/// init() çağrılana kadar geçici state.
final class MobileIntakeUninitialized extends MobileIntakeState {
  const MobileIntakeUninitialized();
}

/// İlk yükleme devam ediyor.
final class MobileIntakeLoading extends MobileIntakeState {
  const MobileIntakeLoading({
    required this.slots,
    required this.cabinId,
    this.mobileSlots,
    this.selectedSlot,
    this.assignments,
  });

  final List<MobileSlotVisual> slots;
  final int cabinId;
  final List<MobileDrawerSlot>? mobileSlots;
  final MobileSlotVisual? selectedSlot;
  final List<BedAssignment>? assignments;
}

/// Kabin verisi yüklendi, slot/göz seçilmedi.
final class MobileIntakeIdle extends MobileIntakeState {
  const MobileIntakeIdle({
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

/// Slot seçildi, göz seçilmedi.
final class MobileIntakeSlotSelected extends MobileIntakeState {
  const MobileIntakeSlotSelected({
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

/// Göz seçildi, hasta yok.
final class MobileIntakeNoPatient extends MobileIntakeState {
  const MobileIntakeNoPatient({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.selectedCell,
    required this.assignments,
    required this.cabinId,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final List<BedAssignment> assignments;
  final int cabinId;

  int get selectedSlotId => selectedSlot.slotId;
}

/// Göz seçildi, hasta var, reçeteler yüklendi — ana çalışma state'i.
final class MobileIntakeReady extends MobileIntakeState {
  const MobileIntakeReady({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.selectedCell,
    required this.assignments,
    required this.cabinId,
    required this.patient,
    required this.bed,
    required this.room,
    required this.prescriptionItems,
    required this.rfidReadEpcs,
    required this.takenEpcs,
    required this.selectedItemIds,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final List<BedAssignment> assignments;
  final int cabinId;
  final Patient patient;
  final Bed? bed;
  final Room? room;
  final List<PrescriptionItem> prescriptionItems;
  final Set<String> rfidReadEpcs;

  /// Kabinden çıkarılmış (alındı sayılan) EPC'ler.
  ///
  /// Dolumun tersine: [rfidReadEpcs] artık okunabilenler,
  /// [takenEpcs] ise artık okunmayanlar (kabinden çıkarılanlar).
  /// EPC geri gelirse [takenEpcs]'ten çıkarılır.
  final Set<String> takenEpcs;
  final Set<int> selectedItemIds;

  int get selectedSlotId => selectedSlot.slotId;

  /// Tamamla butonu için: seçili RFID'li item'ların EPC'si takenEpcs'te mi?
  ///
  /// RFID'li item yoksa (hepsi RFID'siz) direkt true döner.
  bool get canComplete {
    final rfidItems = _selectedRfidItems;
    if (rfidItems.isEmpty) return true;
    return rfidItems.every((i) => takenEpcs.contains(i.rfidTag!));
  }

  /// Banner sayacı için: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => _selectedRfidItems.length;

  /// Bunlardan kaç tanesinin EPC'si takenEpcs'te (alındı sayıldı).
  int get rfidTakenCount => _selectedRfidItems.where((i) => takenEpcs.contains(i.rfidTag!)).length;

  List<PrescriptionItem> get _selectedRfidItems => prescriptionItems
      .where(
        (i) =>
            i.id != null &&
            selectedItemIds.contains(i.id) &&
            i.medicine != null &&
            i.medicine!.isDrug &&
            (i.medicine as Drug).isRfidEnable &&
            i.rfidTag != null,
      )
      .toList();

  MobileIntakeReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<String>? rfidReadEpcs,
    Set<String>? takenEpcs,
    Set<int>? selectedItemIds,
  }) {
    return MobileIntakeReady(
      slots: slots,
      mobileSlots: mobileSlots,
      selectedSlot: selectedSlot,
      selectedCell: selectedCell,
      assignments: assignments,
      cabinId: cabinId,
      patient: patient,
      bed: bed,
      room: room,
      prescriptionItems: prescriptionItems ?? this.prescriptionItems,
      rfidReadEpcs: rfidReadEpcs ?? this.rfidReadEpcs,
      takenEpcs: takenEpcs ?? this.takenEpcs,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

/// Backend check devam ediyor — [CheckMobileIntakeUseCase] sonucu bekleniyor.
///
/// Check başarılı olursa çekmece açılır, başarısız olursa
/// [MobileIntakeError] ile [ready]'e dönülür.
final class MobileIntakeCheckInProgress extends MobileIntakeState {
  const MobileIntakeCheckInProgress({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
    required this.ready,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;

  /// Check başarısız olursa bu state'e dönülür.
  final MobileIntakeReady ready;
}

/// Alım tamamlama işlemi devam ediyor.
final class MobileIntakeSaving extends MobileIntakeState {
  const MobileIntakeSaving({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
    required this.ready,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;
  final MobileIntakeReady ready;
}

/// Alım başarıyla tamamlandı.
final class MobileIntakeSuccess extends MobileIntakeState {
  const MobileIntakeSuccess({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
    required this.message,
    required this.ready,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;
  final String message;
  final MobileIntakeReady ready;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileIntakeError extends MobileIntakeState {
  const MobileIntakeError({required this.message, required this.previousState});

  final String message;
  final MobileIntakeState previousState;
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

extension MobileIntakeStateX on MobileIntakeState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileIntakeLoading(:final slots) => slots,
    MobileIntakeIdle(:final slots) => slots,
    MobileIntakeSlotSelected(:final slots) => slots,
    MobileIntakeNoPatient(:final slots) => slots,
    MobileIntakeReady(:final slots) => slots,
    MobileIntakeCheckInProgress(:final slots) => slots,
    MobileIntakeSaving(:final slots) => slots,
    MobileIntakeSuccess(:final slots) => slots,
    MobileIntakeError(:final previousState) => previousState.slots,
    MobileIntakeUninitialized() => const [],
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileIntakeIdle(:final mobileSlots) => mobileSlots,
    MobileIntakeLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileIntakeSlotSelected(:final mobileSlots) => mobileSlots,
    MobileIntakeNoPatient(:final mobileSlots) => mobileSlots,
    MobileIntakeReady(:final mobileSlots) => mobileSlots,
    MobileIntakeCheckInProgress(:final mobileSlots) => mobileSlots,
    MobileIntakeSaving(:final mobileSlots) => mobileSlots,
    MobileIntakeSuccess(:final mobileSlots) => mobileSlots,
    MobileIntakeError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileIntakeIdle(:final assignments) => assignments,
    MobileIntakeSlotSelected(:final assignments) => assignments,
    MobileIntakeLoading(:final assignments) => assignments ?? const [],
    MobileIntakeNoPatient(:final assignments) => assignments,
    MobileIntakeReady(:final assignments) => assignments,
    MobileIntakeCheckInProgress(:final assignments) => assignments,
    MobileIntakeSaving(:final assignments) => assignments,
    MobileIntakeSuccess(:final assignments) => assignments,
    MobileIntakeError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileIntakeSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileIntakeNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileIntakeReady(:final selectedSlotId) => selectedSlotId,
    MobileIntakeCheckInProgress(:final selectedSlot) => selectedSlot.slotId,
    MobileIntakeSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileIntakeSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileIntakeError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileIntakeSlotSelected(:final selectedSlot) => selectedSlot,
    MobileIntakeLoading(:final selectedSlot) => selectedSlot,
    MobileIntakeNoPatient(:final selectedSlot) => selectedSlot,
    MobileIntakeReady(:final selectedSlot) => selectedSlot,
    MobileIntakeCheckInProgress(:final selectedSlot) => selectedSlot,
    MobileIntakeSaving(:final selectedSlot) => selectedSlot,
    MobileIntakeSuccess(:final selectedSlot) => selectedSlot,
    MobileIntakeError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileIntakeNoPatient(:final selectedCell) => selectedCell,
    MobileIntakeReady(:final selectedCell) => selectedCell,
    MobileIntakeError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileIntakeLoading(:final cabinId) => cabinId,
    MobileIntakeIdle(:final cabinId) => cabinId,
    MobileIntakeSlotSelected(:final cabinId) => cabinId,
    MobileIntakeNoPatient(:final cabinId) => cabinId,
    MobileIntakeReady(:final cabinId) => cabinId,
    MobileIntakeCheckInProgress(:final cabinId) => cabinId,
    MobileIntakeSaving(:final cabinId) => cabinId,
    MobileIntakeSuccess(:final cabinId) => cabinId,
    MobileIntakeError(:final previousState) => previousState.cabinId,
    MobileIntakeUninitialized() => 0,
  };

  Map<MobileCellCoord, BedAssignment> get assignmentByCoord {
    final map = <MobileCellCoord, BedAssignment>{};
    final ms = mobileSlots;
    for (final a in assignments) {
      if (a.cellId == null) continue;
      final coord = _resolveCoord(mobileSlots: ms, cellId: a.cellId!);
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
            return (slot.id, uIdx, cIdx);
          }
        }
      }
    }
    return null;
  }

  /// Panel listesinde gösterilebilecek atamalar.
  /// Sadece bir göze (cell) bağlı olanlar listelenir.
  List<BedAssignment> get availableAssignments =>
      assignments.where((a) => a.cellId != null && a.hospitalization != null).toList();
}
