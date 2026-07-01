import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/widgets.dart';

sealed class MobileUnloadState {
  const MobileUnloadState();
}

/// init() çağrılana kadar geçici state.
final class MobileUnloadUninitialized extends MobileUnloadState {
  const MobileUnloadUninitialized();
}

/// İlk yükleme devam ediyor.
final class MobileUnloadLoading extends MobileUnloadState {
  const MobileUnloadLoading({
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
final class MobileUnloadIdle extends MobileUnloadState {
  const MobileUnloadIdle({
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
final class MobileUnloadSlotSelected extends MobileUnloadState {
  const MobileUnloadSlotSelected({
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
final class MobileUnloadNoPatient extends MobileUnloadState {
  const MobileUnloadNoPatient({
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
/// RFID semantiği alımla aynı:
/// - [takenEpcs]: kabinden çıkarılmış (boşaltıldı sayılan) EPC'ler
/// - EPC kaybolunca [takenEpcs]'e eklenir, geri gelirse çıkarılır
/// - [canComplete]: seçili RFID'li item'ların EPC'si [takenEpcs]'te mi?
final class MobileUnloadReady extends MobileUnloadState {
  const MobileUnloadReady({
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
    this.reportingItemIds = const {}, // "eksik stok bildiriliyor" loading
    required this.takenEpcs,
    required this.selectedItemIds,
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.purchasePending,
    this.baselineCompleted = false,
    this.notFoundEpcs = const {},
    this.unexpectedEpcs = const {},
    this.unplannedMovements = const {},
    this.previouslyTakenEpcs = const {},
    this.excludedItemIds = const {},
    this.reportedMissingItemIds = const {},
    this.passiveEpcs = const {},
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
  final Set<int> reportingItemIds;
  final Set<String> rfidReadEpcs;

  /// Kabinden çıkarılmış (boşaltıldı sayılan) EPC'ler.
  /// EPC kaybolunca eklenir, geri gelirse çıkarılır.
  final Set<String> takenEpcs;
  final Set<int> selectedItemIds;
  final DateRangePreset datePreset;
  final PrescriptionMovementType? statusFilter;
  final bool baselineCompleted;
  final Set<String> notFoundEpcs;
  final Set<String> unexpectedEpcs;
  final Set<String> unplannedMovements;
  final Set<String> previouslyTakenEpcs;
  final Set<int> excludedItemIds;
  final Set<int> reportedMissingItemIds;
  final Set<String> passiveEpcs;

  int get selectedSlotId => selectedSlot.slotId;

  /// Tamamla butonu için: seçili RFID'li item'ların EPC'si takenEpcs'te mi?
  /// RFID'li item yoksa direkt true döner.
  ///
  /// SWREQ-CLI-UNLOAD-003
  bool get canComplete {
    if (!baselineCompleted) return false;
    final hasUnload =
        takenEpcs.isNotEmpty ||
        prescriptionItems.any(
          (i) =>
              i.rfidTag == null &&
              i.status == PrescriptionMovementType.purchasePending &&
              !excludedItemIds.contains(i.id),
        );
    return hasUnload;
  }

  Set<String> get pendingRollbackEpcs => previouslyTakenEpcs.difference(rfidReadEpcs);
  bool get isRollbackComplete => pendingRollbackEpcs.isEmpty;

  MobileUnloadReady get clearedRfidState => copyWith(
    baselineCompleted: false,
    rfidReadEpcs: const {},
    takenEpcs: const {},
    notFoundEpcs: const {},
    unexpectedEpcs: const {},
    unplannedMovements: const {},
    previouslyTakenEpcs: const {},
    excludedItemIds: const {},
  );

  MobileUnloadReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<String>? rfidReadEpcs,
    Set<String>? takenEpcs,
    Set<int>? selectedItemIds,
    Set<int>? reportingItemIds,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? notFoundEpcs,
    Set<String>? unexpectedEpcs,
    Set<String>? unplannedMovements,
    Set<String>? previouslyTakenEpcs,
    Set<int>? excludedItemIds,
    Set<int>? reportedMissingItemIds,
    Set<String>? passiveEpcs,
  }) {
    return MobileUnloadReady(
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
      reportingItemIds: reportingItemIds ?? this.reportingItemIds,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      notFoundEpcs: notFoundEpcs ?? this.notFoundEpcs,
      unexpectedEpcs: unexpectedEpcs ?? this.unexpectedEpcs,
      unplannedMovements: unplannedMovements ?? this.unplannedMovements,
      previouslyTakenEpcs: previouslyTakenEpcs ?? this.previouslyTakenEpcs,
      excludedItemIds: excludedItemIds ?? this.excludedItemIds,
      reportedMissingItemIds: reportedMissingItemIds ?? this.reportedMissingItemIds,
      passiveEpcs: passiveEpcs ?? this.passiveEpcs,
    );
  }
}

/// Boşaltma tamamlama işlemi devam ediyor.
final class MobileUnloadSaving extends MobileUnloadState {
  const MobileUnloadSaving({
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
  final MobileUnloadReady ready;
}

/// Boşaltma başarıyla tamamlandı.
final class MobileUnloadSuccess extends MobileUnloadState {
  const MobileUnloadSuccess({
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
  final MobileUnloadReady ready;
}

/// Boşaltma kaydı başarısız oldu — kullanıcı çıkardığı ilaçları kabine geri
/// koymalı. [ready.previouslyTakenEpcs] geri konması beklenen tag'leri tutar;
/// kullanıcı geri koydukça [ready.rfidReadEpcs] dolar, hepsi tamamlanınca
/// çekmece kapanışında finalize edilir.
final class MobileUnloadRollbackInProgress extends MobileUnloadState {
  const MobileUnloadRollbackInProgress({
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
  final MobileUnloadReady ready;

  MobileUnloadRollbackInProgress copyWith({MobileUnloadReady? ready}) {
    return MobileUnloadRollbackInProgress(
      slots: slots,
      mobileSlots: mobileSlots,
      selectedSlot: selectedSlot,
      assignments: assignments,
      cabinId: cabinId,
      ready: ready ?? this.ready,
    );
  }
}

/// Rollback başarıyla tamamlandı — tüm tag'ler kabine geri kondu.
/// readyContext null olacak şekilde tasarlı → dialog kendiliğinden kapanır.
final class MobileUnloadRollbackCompleted extends MobileUnloadState {
  const MobileUnloadRollbackCompleted({
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

/// Çekmece donanım hatası — kurtarılamaz. Kullanıcı yalnızca dismiss edebilir.
final class MobileUnloadFatalError extends MobileUnloadState {
  const MobileUnloadFatalError({required this.message, required this.previousState});

  final String message;
  final MobileUnloadState previousState;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileUnloadError extends MobileUnloadState {
  const MobileUnloadError({required this.message, required this.previousState});

  final String message;
  final MobileUnloadState previousState;
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

extension MobileUnloadStateX on MobileUnloadState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileUnloadLoading(:final slots) => slots,
    MobileUnloadIdle(:final slots) => slots,
    MobileUnloadSlotSelected(:final slots) => slots,
    MobileUnloadNoPatient(:final slots) => slots,
    MobileUnloadReady(:final slots) => slots,
    MobileUnloadSaving(:final slots) => slots,
    MobileUnloadSuccess(:final slots) => slots,
    MobileUnloadError(:final previousState) => previousState.slots,
    MobileUnloadUninitialized() => const [],
    MobileUnloadRollbackInProgress(:final slots) => slots,
    MobileUnloadRollbackCompleted(:final slots) => slots,
    MobileUnloadFatalError(:final previousState) => previousState.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileUnloadIdle(:final mobileSlots) => mobileSlots,
    MobileUnloadLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileUnloadSlotSelected(:final mobileSlots) => mobileSlots,
    MobileUnloadNoPatient(:final mobileSlots) => mobileSlots,
    MobileUnloadReady(:final mobileSlots) => mobileSlots,
    MobileUnloadSaving(:final mobileSlots) => mobileSlots,
    MobileUnloadSuccess(:final mobileSlots) => mobileSlots,
    MobileUnloadError(:final previousState) => previousState.mobileSlots,
    MobileUnloadRollbackInProgress(:final mobileSlots) => mobileSlots,
    MobileUnloadRollbackCompleted(:final mobileSlots) => mobileSlots,
    MobileUnloadFatalError(:final previousState) => previousState.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileUnloadIdle(:final assignments) => assignments,
    MobileUnloadSlotSelected(:final assignments) => assignments,
    MobileUnloadLoading(:final assignments) => assignments ?? const [],
    MobileUnloadNoPatient(:final assignments) => assignments,
    MobileUnloadReady(:final assignments) => assignments,
    MobileUnloadSaving(:final assignments) => assignments,
    MobileUnloadSuccess(:final assignments) => assignments,
    MobileUnloadError(:final previousState) => previousState.assignments,
    MobileUnloadRollbackInProgress(:final assignments) => assignments,
    MobileUnloadRollbackCompleted(:final assignments) => assignments,
    MobileUnloadFatalError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileUnloadSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileUnloadNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileUnloadReady(:final selectedSlotId) => selectedSlotId,
    MobileUnloadSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileUnloadSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileUnloadError(:final previousState) => previousState.selectedSlotId,
    MobileUnloadRollbackInProgress(:final selectedSlot) => selectedSlot.slotId,
    MobileUnloadRollbackCompleted(:final selectedSlot) => selectedSlot.slotId,
    MobileUnloadFatalError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileUnloadSlotSelected(:final selectedSlot) => selectedSlot,
    MobileUnloadLoading(:final selectedSlot) => selectedSlot,
    MobileUnloadNoPatient(:final selectedSlot) => selectedSlot,
    MobileUnloadReady(:final selectedSlot) => selectedSlot,
    MobileUnloadSaving(:final selectedSlot) => selectedSlot,
    MobileUnloadSuccess(:final selectedSlot) => selectedSlot,
    MobileUnloadError(:final previousState) => previousState.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileUnloadNoPatient(:final selectedCell) => selectedCell,
    MobileUnloadReady(:final selectedCell) => selectedCell,
    MobileUnloadError(:final previousState) => previousState.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileUnloadLoading(:final cabinId) => cabinId,
    MobileUnloadIdle(:final cabinId) => cabinId,
    MobileUnloadSlotSelected(:final cabinId) => cabinId,
    MobileUnloadNoPatient(:final cabinId) => cabinId,
    MobileUnloadReady(:final cabinId) => cabinId,
    MobileUnloadSaving(:final cabinId) => cabinId,
    MobileUnloadSuccess(:final cabinId) => cabinId,
    MobileUnloadError(:final previousState) => previousState.cabinId,
    MobileUnloadUninitialized() => 0,
    MobileUnloadRollbackInProgress(:final cabinId) => cabinId,
    MobileUnloadRollbackCompleted(:final cabinId) => cabinId,
    MobileUnloadFatalError(:final previousState) => previousState.cabinId,
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

  List<BedAssignment> get availableAssignments =>
      assignments.where((a) => a.cellId != null && a.hospitalization != null).toList();

  MobileUnloadReady? get readyContext => switch (this) {
    MobileUnloadReady r => r,
    MobileUnloadSaving(:final ready) => ready,
    MobileUnloadSuccess(:final ready) => ready,
    MobileUnloadError(:final previousState) => previousState.readyContext,
    MobileUnloadRollbackInProgress(:final ready) => ready,
    _ => null,
  };

  bool shouldKeepDialog(MobileDrawerStage stage) {
    // Terminal → kapanır
    if (this is MobileUnloadSuccess) return false;
    if (this is MobileUnloadRollbackCompleted) return false;
    if (this is MobileUnloadFatalError) return false;

    // Açık kalmalı
    if (this is MobileUnloadRollbackInProgress) return true;
    if (this is MobileUnloadSaving) return true;
    if (this is MobileUnloadError) return true;

    final hasReady = readyContext != null;
    final drawerActive = stage is MobileDrawerOpening || stage is MobileDrawerOpened || stage is MobileDrawerClosed;
    return hasReady && drawerActive;
  }
}
