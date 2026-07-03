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

final class MobileUnloadDrawerOpening extends MobileUnloadState {
  const MobileUnloadDrawerOpening({required this.ready});

  final MobileUnloadReady ready;
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
    this.reportingItemIds = const {}, // "eksik stok bildiriliyor" loading
    required this.selectedItemIds,
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.purchasePending,
    this.baselineCompleted = false,
    this.baselineEpcs = const {},
    this.baselineLostEpcs = const {},
    this.placedEpcs = const {},
    this.unloadExcludedItemIds = const {},
    this.markedMissingItemIds = const {},
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

  /// Kabinden çıkarılmış (boşaltıldı sayılan) EPC'ler.
  /// EPC kaybolunca eklenir, geri gelirse çıkarılır.
  final Set<int> selectedItemIds;
  final DateRangePreset datePreset;
  final PrescriptionMovementType? statusFilter;

  /// Baseline snapshot tamamlandı mı? false iken complete disabled.
  final bool baselineCompleted;

  /// İşlem öncesi kabinde bulunan TÜM etiketler (snapshot). SABİT.
  final Set<String> baselineEpcs;

  /// Baseline'dan çıkan (lost) etiketler. Bidirectional.
  final Set<String> baselineLostEpcs;

  /// Baseline'da yokken sonradan okunan etiketler.
  /// expectedMap'te varsa PASSIVE (sessiz), yoksa UNEXPECTED (yabancı → blokaj).
  final Set<String> placedEpcs;

  /// RFID'siz, boşaltmaya dahil edilen item'lar (checkbox açık).
  final Set<int> unloadExcludedItemIds;

  /// RFID'siz, eksik işaretlenen item'lar (toggle açık).
  final Set<int> markedMissingItemIds;

  int get selectedSlotId => selectedSlot.slotId;

  /// Sayımda TÜM "alım bekleyen" RFID'li ilaçlar otomatik dahildir — seçim yok.
  List<PrescriptionItem> get _unloadRfidItems => prescriptionItems
      .where(
        (i) =>
            i.id != null &&
            i.status == PrescriptionMovementType.purchasePending &&
            i.medicine != null &&
            i.medicine!.isDrug &&
            (i.medicine as Drug).isRfidEnable &&
            i.rfidTag != null,
      )
      .toList();

  /// Kabinde olması beklenen tüm RFID'li ilaç etiketleri (sayım kapsamı).
  Set<String> get expectedEpcs => _unloadRfidItems.map((i) => i.rfidTag!).toSet();

  /// Baseline'da present olup şu an hâlâ okunan.
  Set<String> get rfidReadEpcs => baselineEpcs.difference(baselineLostEpcs);

  /// NOT_FOUND — seçili ama baseline'da hiç okunmadı → EKSİK (statik, Alım gibi).
  Set<String> get notFoundEpcs => expectedEpcs.difference(baselineEpcs);

  /// UNPLANNED — baseline'dan çıktı ama seçili değil → izinsiz çıkış, EKSİK.
  Set<String> get unplannedMovements => baselineLostEpcs.difference(expectedEpcs);

  /// Baseline'dan çıkan VE seçili → ilaç fiziksel çıkmış.
  Set<String> get takenEpcs => baselineLostEpcs.intersection(expectedEpcs);

  /// Sayımda "eksik" — seçili etiketli ilaç complete anında kabinde okunmuyor.
  /// Hem baseline'da hiç olmayanı (notFound) hem sonradan çıkanı kapsar.
  /// = expectedEpcs ∖ rfidReadEpcs
  /// Sayımda "eksik" — seçili etiketli ilaç complete anında kabinde okunmuyor.
  /// Baseline tamamlanmadan anlamsızdır (henüz taranıyor) → boş döner.
  Set<String> get missingEpcs => baselineCompleted ? expectedEpcs.difference(rfidReadEpcs) : const {};

  /// Seçili RFID'li ilaçlardan kabinde okunanların sayısı (sayıldı).
  int get rfidCountedCount => expectedEpcs.intersection(rfidReadEpcs).length;

  /// Sayım kapsamındaki RFID'siz "alım bekleyen" ilaçlar (manuel doğrulanır).
  List<PrescriptionItem> get _unloadNonRfidItems => prescriptionItems
      .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending && i.rfidTag == null)
      .toList();

  /// Sayılacak toplam ilaç sayısı = RFID'li + RFID'siz.
  int get unloadTotalCount => _unloadRfidItems.length + _unloadNonRfidItems.length;

  /// Toplam eksik bildirim sayısı = otomatik RFID eksikleri + manuel işaretlenen RFID'siz eksikler.
  int get totalMissingCount => missingEpcs.length + markedMissingItemIds.length;

  /// Sayılmış kabul edilen = kabinde okunan RFID'li + eksik İŞARETLENMEYEN RFID'siz.
  /// (Kullanıcı bir RFID'siz item'ı eksik işaretlerse "sayılmadı" demektir.)
  int get unloadCountedTotal {
    final rfidCounted = rfidCountedCount; // expected ∩ read
    final nonRfidCounted = _unloadNonRfidItems.where((i) => !markedMissingItemIds.contains(i.id)).length;
    return rfidCounted + nonRfidCounted;
  }

  int get unplannedCount => unplannedMovements.length;
  int get notFoundCount => notFoundEpcs.length;
  int get rfidExpectedCount => expectedEpcs.length;

  bool get hasUnplannedMovement => unplannedMovements.isNotEmpty;
  bool get hasUnexpectedTag => placedEpcs.isNotEmpty;

  /// Bir RFID'siz item boşaltmaya dahil mi? (hariç değilse dahil)
  bool isUnloadIncluded(int itemId) => !unloadExcludedItemIds.contains(itemId);

  /// Tamamla: baseline bitti VE yabancı etiket yok.
  /// Eksik/fazla engellemez (bildirim gider); yabancı etiket BLOKE eder.
  ///
  /// SWREQ-CLI-Unload-003
  bool get canComplete {
    if (!baselineCompleted) return false;
    if (placedEpcs.isNotEmpty) return false; // yabancı etiket → blokaj
    return true;
  }

  MobileUnloadReady get clearedRfidState =>
      copyWith(baselineCompleted: false, baselineEpcs: const {}, baselineLostEpcs: const {}, placedEpcs: const {});

  MobileUnloadReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<int>? selectedItemIds,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? baselineEpcs,
    Set<String>? baselineLostEpcs,
    Set<String>? placedEpcs,
    Set<int>? unloadExcludedItemIds,
    Set<int>? markedMissingItemIds,
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
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      baselineEpcs: baselineEpcs ?? this.baselineEpcs,
      baselineLostEpcs: baselineLostEpcs ?? this.baselineLostEpcs,
      placedEpcs: placedEpcs ?? this.placedEpcs,
      unloadExcludedItemIds: unloadExcludedItemIds ?? this.unloadExcludedItemIds,
      markedMissingItemIds: markedMissingItemIds ?? this.markedMissingItemIds,
    );
  }
}

/// Kayıt başarıyla gitti; çekmece hâlâ açık, kullanıcının kapatması bekleniyor.
/// Butonlar kalkar. RFID canlı dinlenir — kullanıcı bu sırada tag alır/geri
/// koyarsa ready.baselineLostEpcs güncellenir, banner anlık gösterilir.
/// Çekmece kapandığı an _reportUnplannedMovements bu kümeleri okuyup bildirir.
final class MobileUnloadWaitingClose extends MobileUnloadState {
  const MobileUnloadWaitingClose({required this.ready});

  final MobileUnloadReady ready;
}

/// Kullanıcı "Tamamla" demeden çekmeceyi kapattı. Kayıt YOK.
/// İptal (çık) veya Tekrar Dene (çekmece yeniden açılır) seçenekleri sunulur.
final class MobileUnloadClosedEarly extends MobileUnloadState {
  const MobileUnloadClosedEarly({required this.ready});

  final MobileUnloadReady ready;
}

/// Boşaltma tamamlama işlemi devam ediyor.
final class MobileUnloadSaving extends MobileUnloadState {
  const MobileUnloadSaving({required this.ready});

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
    MobileUnloadSaving(:final ready) => ready.slots,
    MobileUnloadWaitingClose(:final ready) => ready.slots,
    MobileUnloadClosedEarly(:final ready) => ready.slots,
    MobileUnloadSuccess(:final slots) => slots,
    MobileUnloadError(:final previousState) => previousState.slots,
    MobileUnloadFatalError(:final previousState) => previousState.slots,
    MobileUnloadUninitialized() => const [],
    MobileUnloadDrawerOpening(:final ready) => ready.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileUnloadIdle(:final mobileSlots) => mobileSlots,
    MobileUnloadLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileUnloadSlotSelected(:final mobileSlots) => mobileSlots,
    MobileUnloadNoPatient(:final mobileSlots) => mobileSlots,
    MobileUnloadReady(:final mobileSlots) => mobileSlots,
    MobileUnloadSaving(:final ready) => ready.mobileSlots,
    MobileUnloadWaitingClose(:final ready) => ready.mobileSlots,
    MobileUnloadClosedEarly(:final ready) => ready.mobileSlots,
    MobileUnloadSuccess(:final mobileSlots) => mobileSlots,
    MobileUnloadError(:final previousState) => previousState.mobileSlots,
    MobileUnloadFatalError(:final previousState) => previousState.mobileSlots,
    MobileUnloadDrawerOpening(:final ready) => ready.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileUnloadIdle(:final assignments) => assignments,
    MobileUnloadSlotSelected(:final assignments) => assignments,
    MobileUnloadLoading(:final assignments) => assignments ?? const [],
    MobileUnloadNoPatient(:final assignments) => assignments,
    MobileUnloadReady(:final assignments) => assignments,
    MobileUnloadSaving(:final ready) => ready.assignments,
    MobileUnloadWaitingClose(:final ready) => ready.assignments,
    MobileUnloadClosedEarly(:final ready) => ready.assignments,
    MobileUnloadSuccess(:final assignments) => assignments,
    MobileUnloadError(:final previousState) => previousState.assignments,
    MobileUnloadFatalError(:final previousState) => previousState.assignments,
    MobileUnloadDrawerOpening(:final ready) => ready.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileUnloadSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileUnloadNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileUnloadReady(:final selectedSlotId) => selectedSlotId,
    MobileUnloadSaving(:final ready) => ready.selectedSlotId,
    MobileUnloadWaitingClose(:final ready) => ready.selectedSlotId,
    MobileUnloadClosedEarly(:final ready) => ready.selectedSlotId,
    MobileUnloadSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileUnloadError(:final previousState) => previousState.selectedSlotId,
    MobileUnloadFatalError(:final previousState) => previousState.selectedSlotId,
    MobileUnloadDrawerOpening(:final ready) => ready.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileUnloadSlotSelected(:final selectedSlot) => selectedSlot,
    MobileUnloadLoading(:final selectedSlot) => selectedSlot,
    MobileUnloadNoPatient(:final selectedSlot) => selectedSlot,
    MobileUnloadReady(:final selectedSlot) => selectedSlot,
    MobileUnloadSaving(:final ready) => ready.selectedSlot,
    MobileUnloadWaitingClose(:final ready) => ready.selectedSlot,
    MobileUnloadClosedEarly(:final ready) => ready.selectedSlot,
    MobileUnloadSuccess(:final selectedSlot) => selectedSlot,
    MobileUnloadError(:final previousState) => previousState.selectedSlot,
    MobileUnloadFatalError(:final previousState) => previousState.selectedSlot,
    MobileUnloadDrawerOpening(:final ready) => ready.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileUnloadNoPatient(:final selectedCell) => selectedCell,
    MobileUnloadReady(:final selectedCell) => selectedCell,
    MobileUnloadWaitingClose(:final ready) => ready.selectedCell,
    MobileUnloadClosedEarly(:final ready) => ready.selectedCell,
    MobileUnloadError(:final previousState) => previousState.selectedCell,
    MobileUnloadFatalError(:final previousState) => previousState.selectedCell,
    MobileUnloadDrawerOpening(:final ready) => ready.selectedCell,

    _ => null,
  };

  int get cabinId => switch (this) {
    MobileUnloadLoading(:final cabinId) => cabinId,
    MobileUnloadIdle(:final cabinId) => cabinId,
    MobileUnloadSlotSelected(:final cabinId) => cabinId,
    MobileUnloadNoPatient(:final cabinId) => cabinId,
    MobileUnloadReady(:final cabinId) => cabinId,
    MobileUnloadSaving(:final ready) => ready.cabinId,
    MobileUnloadWaitingClose(:final ready) => ready.cabinId,
    MobileUnloadClosedEarly(:final ready) => ready.cabinId,
    MobileUnloadSuccess(:final cabinId) => cabinId,
    MobileUnloadError(:final previousState) => previousState.cabinId,
    MobileUnloadFatalError(:final previousState) => previousState.cabinId,
    MobileUnloadDrawerOpening(:final ready) => ready.cabinId,
    MobileUnloadUninitialized() => 0,
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
    MobileUnloadWaitingClose(:final ready) => ready,
    MobileUnloadClosedEarly(:final ready) => ready,
    MobileUnloadSuccess(:final ready) => ready,
    MobileUnloadError(:final previousState) => previousState.readyContext,
    MobileUnloadFatalError(:final previousState) => previousState.readyContext,
    MobileUnloadDrawerOpening(:final ready) => ready,
    _ => null,
  };

  bool shouldKeepDialog(MobileDrawerStage stage) {
    return switch (this) {
      MobileUnloadSuccess() || MobileUnloadFatalError() => false,
      MobileUnloadClosedEarly() => true,
      MobileUnloadWaitingClose() => true,
      MobileUnloadSaving() => true,
      MobileUnloadError() => true,
      _ =>
        readyContext != null &&
            (stage is MobileDrawerOpening ||
                stage is MobileDrawerOpened ||
                (stage is MobileDrawerClosed && readyContext!.baselineCompleted)),
    };
  }
}
