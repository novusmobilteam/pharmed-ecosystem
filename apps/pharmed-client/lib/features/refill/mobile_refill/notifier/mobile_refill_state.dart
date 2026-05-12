import 'package:pharmed_core/pharmed_core.dart';
import '../../../../widgets/widgets.dart';

// [SWREQ-CLI-REFILL-003] [IEC 62304 §5.5]
// Mobil kabin dolum ekranı state tanımları.
// BedAssignmentState pattern'i referans alınmıştır.
// Sınıf: Class B

sealed class MobileRefillState {
  const MobileRefillState();
}

/// init() çağrılana kadar geçici state.
final class MobileRefillUninitialized extends MobileRefillState {
  const MobileRefillUninitialized();
}

/// İlk yükleme devam ediyor.
final class MobileRefillLoading extends MobileRefillState {
  const MobileRefillLoading({
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
final class MobileRefillIdle extends MobileRefillState {
  const MobileRefillIdle({
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
final class MobileRefillSlotSelected extends MobileRefillState {
  const MobileRefillSlotSelected({
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
final class MobileRefillNoPatient extends MobileRefillState {
  const MobileRefillNoPatient({
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
final class MobileRefillReady extends MobileRefillState {
  const MobileRefillReady({
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
  final Set<String> rfidReadEpcs;
  final Set<int> selectedItemIds;

  int get selectedSlotId => selectedSlot.slotId;

  /// Banner sayacı için: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => _selectedRfidItems.length;

  /// Bunlardan kaç tanesinin EPC'si okundu.
  int get rfidReadCount => _selectedRfidItems.where((i) => rfidReadEpcs.contains(i.rfidTag)).length;

  /// Tamamla butonu için: tüm seçili RFID'li ilaçların etiketleri okundu mu?
  bool get allSelectedRfidRead => rfidExpectedCount == 0 || rfidReadCount >= rfidExpectedCount;

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

  MobileRefillReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<String>? rfidReadEpcs,
    Set<int>? selectedItemIds,
  }) {
    return MobileRefillReady(
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

/// Çekmece açılış komutu gönderildi, ilk stage event bekleniyor.
///
/// [startRefill] çağrıldıktan sonra [MobileDrawerOpening] stream'den
/// gelene kadar geçen kısa süreyi kapsar. UI bu state'de "Doluma başla"
/// butonunu loading olarak gösterir.
final class MobileRefillDrawerStarting extends MobileRefillState {
  const MobileRefillDrawerStarting({
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

  /// Hata durumunda bu state'e dönülür.
  final MobileRefillReady ready;
}

/// Dolum tamamlama işlemi devam ediyor.
final class MobileRefillSaving extends MobileRefillState {
  const MobileRefillSaving({
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
  final MobileRefillReady ready;
}

/// Dolum başarıyla tamamlandı.
final class MobileRefillSuccess extends MobileRefillState {
  const MobileRefillSuccess({
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
  final MobileRefillReady ready;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileRefillError extends MobileRefillState {
  const MobileRefillError({required this.message, required this.previousState});

  final String message;
  final MobileRefillState previousState;
}

// ── Extension ────────────────────────────────────────────────────────────────

extension MobileRefillStateX on MobileRefillState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileRefillLoading(:final slots) => slots,
    MobileRefillIdle(:final slots) => slots,
    MobileRefillSlotSelected(:final slots) => slots,
    MobileRefillNoPatient(:final slots) => slots,
    MobileRefillReady(:final slots) => slots,
    MobileRefillDrawerStarting(:final slots) => slots,
    MobileRefillSaving(:final slots) => slots,
    MobileRefillSuccess(:final slots) => slots,
    MobileRefillError(:final previousState) => previousState.slots,
    MobileRefillUninitialized() => const [],
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileRefillIdle(:final mobileSlots) => mobileSlots,
    MobileRefillLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileRefillSlotSelected(:final mobileSlots) => mobileSlots,
    MobileRefillNoPatient(:final mobileSlots) => mobileSlots,
    MobileRefillReady(:final mobileSlots) => mobileSlots,
    MobileRefillDrawerStarting(:final mobileSlots) => mobileSlots,
    MobileRefillSaving(:final mobileSlots) => mobileSlots,
    MobileRefillSuccess(:final mobileSlots) => mobileSlots,
    MobileRefillError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileRefillIdle(:final assignments) => assignments,
    MobileRefillSlotSelected(:final assignments) => assignments,
    MobileRefillLoading(:final assignments) => assignments ?? const [],
    MobileRefillNoPatient(:final assignments) => assignments,
    MobileRefillReady(:final assignments) => assignments,
    MobileRefillDrawerStarting(:final assignments) => assignments,
    MobileRefillSaving(:final assignments) => assignments,
    MobileRefillSuccess(:final assignments) => assignments,
    MobileRefillError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileRefillSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileRefillNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileRefillReady(:final selectedSlotId) => selectedSlotId,
    MobileRefillDrawerStarting(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileRefillSlotSelected(:final selectedSlot) => selectedSlot,
    MobileRefillLoading(:final selectedSlot) => selectedSlot,
    MobileRefillNoPatient(:final selectedSlot) => selectedSlot,
    MobileRefillReady(:final selectedSlot) => selectedSlot,
    MobileRefillDrawerStarting(:final selectedSlot) => selectedSlot,
    MobileRefillSaving(:final selectedSlot) => selectedSlot,
    MobileRefillSuccess(:final selectedSlot) => selectedSlot,
    MobileRefillError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileRefillNoPatient(:final selectedCell) => selectedCell,
    MobileRefillReady(:final selectedCell) => selectedCell,
    MobileRefillError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileRefillLoading(:final cabinId) => cabinId,
    MobileRefillIdle(:final cabinId) => cabinId,
    MobileRefillSlotSelected(:final cabinId) => cabinId,
    MobileRefillNoPatient(:final cabinId) => cabinId,
    MobileRefillReady(:final cabinId) => cabinId,
    MobileRefillDrawerStarting(:final cabinId) => cabinId,
    MobileRefillSaving(:final cabinId) => cabinId,
    MobileRefillSuccess(:final cabinId) => cabinId,
    MobileRefillError(:final previousState) => previousState.cabinId,
    MobileRefillUninitialized() => 0,
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
  /// Sadece bir göze (cell) bağlı olanlar listelenir; göz ataması olmayan
  /// kabaca-atanmış kayıtlar kullanıcıya gösterilmez.
  List<BedAssignment> get availableAssignments =>
      assignments.where((a) => a.cellId != null && a.hospitalization != null).toList();
}
