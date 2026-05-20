import 'package:pharmed_core/pharmed_core.dart';

import '../../../../widgets/widgets.dart';

sealed class MobileCensusState {
  const MobileCensusState();
}

/// init() çağrılana kadar geçici state.
final class MobileCensusUninitialized extends MobileCensusState {
  const MobileCensusUninitialized();
}

/// İlk yükleme devam ediyor.
final class MobileCensusLoading extends MobileCensusState {
  const MobileCensusLoading({
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
final class MobileCensusIdle extends MobileCensusState {
  const MobileCensusIdle({
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
final class MobileCensusSlotSelected extends MobileCensusState {
  const MobileCensusSlotSelected({
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
final class MobileCensusNoPatient extends MobileCensusState {
  const MobileCensusNoPatient({
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
///
/// RFID semantiği alımın tersidir — dolumla aynı mantık:
/// - [rfidReadEpcs]: şu an okuyucu tarafından görülen EPC'ler (kabinde mevcut)
/// - EPC görülürse eklenir, kaybolursa çıkarılır
/// - [canComplete]: seçili RFID'li item'ların EPC'si [rfidReadEpcs]'te mi?
final class MobileCensusReady extends MobileCensusState {
  const MobileCensusReady({
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

  /// Şu an okuyucu tarafından görülen EPC'ler — kabinde fiziksel olarak mevcut.
  ///
  /// Sayım semantiği: EPC okunuyorsa ilaç kabinde var.
  /// EPC kaybolursa ilaç kabinden çıkarılmış → [rfidReadEpcs]'ten düşer.
  /// [canComplete] bu set üzerinden hesaplanır.
  final Set<String> rfidReadEpcs;
  final Set<int> selectedItemIds;

  int get selectedSlotId => selectedSlot.slotId;

  /// Tamamla butonu için: seçili RFID'li item'ların EPC'si şu an okunuyor mu?
  ///
  /// RFID'li item yoksa (hepsi RFID'siz) direkt true döner.
  ///
  /// SWREQ-CLI-CENSUS-003
  bool get canComplete {
    final rfidItems = _selectedRfidItems;
    if (rfidItems.isEmpty) return true;
    return rfidItems.every((i) => rfidReadEpcs.contains(i.rfidTag!));
  }

  /// Banner sayacı için: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => _selectedRfidItems.length;

  /// Bunlardan kaç tanesinin EPC'si şu an okunuyor (kabinde mevcut).
  int get rfidPresentCount => _selectedRfidItems.where((i) => rfidReadEpcs.contains(i.rfidTag!)).length;

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

  MobileCensusReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<String>? rfidReadEpcs,
    Set<int>? selectedItemIds,
  }) {
    return MobileCensusReady(
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
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

/// Sayım tamamlama işlemi devam ediyor.
final class MobileCensusSaving extends MobileCensusState {
  const MobileCensusSaving({
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
  final MobileCensusReady ready;
}

/// Sayım başarıyla tamamlandı.
final class MobileCensusSuccess extends MobileCensusState {
  const MobileCensusSuccess({
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
  final MobileCensusReady ready;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileCensusError extends MobileCensusState {
  const MobileCensusError({required this.message, required this.previousState});

  final String message;
  final MobileCensusState previousState;
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

extension MobileCensusStateX on MobileCensusState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileCensusLoading(:final slots) => slots,
    MobileCensusIdle(:final slots) => slots,
    MobileCensusSlotSelected(:final slots) => slots,
    MobileCensusNoPatient(:final slots) => slots,
    MobileCensusReady(:final slots) => slots,
    MobileCensusSaving(:final slots) => slots,
    MobileCensusSuccess(:final slots) => slots,
    MobileCensusError(:final previousState) => previousState.slots,
    MobileCensusUninitialized() => const [],
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileCensusIdle(:final mobileSlots) => mobileSlots,
    MobileCensusLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileCensusSlotSelected(:final mobileSlots) => mobileSlots,
    MobileCensusNoPatient(:final mobileSlots) => mobileSlots,
    MobileCensusReady(:final mobileSlots) => mobileSlots,
    MobileCensusSaving(:final mobileSlots) => mobileSlots,
    MobileCensusSuccess(:final mobileSlots) => mobileSlots,
    MobileCensusError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileCensusIdle(:final assignments) => assignments,
    MobileCensusSlotSelected(:final assignments) => assignments,
    MobileCensusLoading(:final assignments) => assignments ?? const [],
    MobileCensusNoPatient(:final assignments) => assignments,
    MobileCensusReady(:final assignments) => assignments,
    MobileCensusSaving(:final assignments) => assignments,
    MobileCensusSuccess(:final assignments) => assignments,
    MobileCensusError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileCensusSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileCensusNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileCensusReady(:final selectedSlotId) => selectedSlotId,
    MobileCensusSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileCensusSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileCensusError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileCensusSlotSelected(:final selectedSlot) => selectedSlot,
    MobileCensusLoading(:final selectedSlot) => selectedSlot,
    MobileCensusNoPatient(:final selectedSlot) => selectedSlot,
    MobileCensusReady(:final selectedSlot) => selectedSlot,
    MobileCensusSaving(:final selectedSlot) => selectedSlot,
    MobileCensusSuccess(:final selectedSlot) => selectedSlot,
    MobileCensusError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileCensusNoPatient(:final selectedCell) => selectedCell,
    MobileCensusReady(:final selectedCell) => selectedCell,
    MobileCensusError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileCensusLoading(:final cabinId) => cabinId,
    MobileCensusIdle(:final cabinId) => cabinId,
    MobileCensusSlotSelected(:final cabinId) => cabinId,
    MobileCensusNoPatient(:final cabinId) => cabinId,
    MobileCensusReady(:final cabinId) => cabinId,
    MobileCensusSaving(:final cabinId) => cabinId,
    MobileCensusSuccess(:final cabinId) => cabinId,
    MobileCensusError(:final previousState) => previousState.cabinId,
    MobileCensusUninitialized() => 0,
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
