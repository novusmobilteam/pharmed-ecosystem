import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';

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

final class MobileCensusDrawerOpening extends MobileCensusState {
  const MobileCensusDrawerOpening({required this.ready});

  final MobileCensusReady ready;
}

/// Göz seçildi, hasta var, reçeteler yüklendi — ana çalışma state'i.
///
/// Sayım = Alım (eksik yönü) + Dolum (yabancı etiket blokajı) birleşimi:
/// - Etiketli ilaç bulunamaz/çıkarsa → EKSİK (Alım semantiği)
/// - Yabancı etiket (expectedMap'te yok) → BLOKAJ, bildirim yok (Dolum semantiği)
/// - RFID'siz item → manuel EKSİK (markedMissingItemIds) veya manuel FAZLA (extraStocks)
///
/// Bildirimler complete anında TOPLUCA gider → anlık loading/reported set YOK.
/// Persistent runtime kümeleri üç tanedir; kalanlar TÜRETİLİR.
///
/// SWREQ-CLI-CENSUS-002
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
    required this.selectedItemIds,
    this.markedMissingItemIds = const {},
    this.extraStocks = const [],
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.purchasePending,
    this.baselineCompleted = false,
    this.baselineEpcs = const {},
    this.baselineLostEpcs = const {},
    this.placedEpcs = const {},
  });

  // ── Sahne ──────────────────────────────────────────────────────────────
  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final MobileCellCoord selectedCell;
  final List<BedAssignment> assignments;
  final int cabinId;
  final Patient patient;
  final Bed? bed;
  final Room? room;

  // ── Reçete ve seçim ────────────────────────────────────────────────────
  final List<PrescriptionItem> prescriptionItems;

  final Set<int> selectedItemIds;
  final DateRangePreset datePreset;
  final PrescriptionMovementType? statusFilter;

  /// Manuel EKSİK işaretlenen RFID'siz item id'leri (listedeki ilaçlar).
  /// Complete anında topluca eksik stok bildirimine dönüşür.
  final Set<int> markedMissingItemIds;

  /// Manuel FAZLA stok kayıtları (listede olmayan ilaç + adet).
  /// Complete anında topluca fazla stok bildirimine dönüşür.
  final List<CensusExtraStock> extraStocks;

  // ── RFID reconciliation — kalıcı üç alan ────────────────────────────────

  /// Baseline snapshot tamamlandı mı? false iken complete disabled.
  final bool baselineCompleted;

  /// İşlem öncesi kabinde bulunan TÜM etiketler (snapshot). SABİT.
  final Set<String> baselineEpcs;

  /// Baseline'dan çıkan (lost) etiketler. Bidirectional.
  final Set<String> baselineLostEpcs;

  /// Baseline'da yokken sonradan okunan etiketler.
  /// expectedMap'te varsa PASSIVE (sessiz), yoksa UNEXPECTED (yabancı → blokaj).
  final Set<String> placedEpcs;

  int get selectedSlotId => selectedSlot.slotId;

  // ── Türetilmiş kümeler ──────────────────────────────────────────────────

  /// Sayımda TÜM "alım bekleyen" RFID'li ilaçlar otomatik dahildir — seçim yok.
  List<PrescriptionItem> get _censusRfidItems => prescriptionItems
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
  Set<String> get expectedEpcs => _censusRfidItems.map((i) => i.rfidTag!).toSet();

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
  List<PrescriptionItem> get _censusNonRfidItems => prescriptionItems
      .where((i) => i.id != null && i.status == PrescriptionMovementType.purchasePending && i.rfidTag == null)
      .toList();

  /// Sayılacak toplam ilaç sayısı = RFID'li + RFID'siz.
  int get censusTotalCount => _censusRfidItems.length + _censusNonRfidItems.length;

  /// Toplam eksik bildirim sayısı = otomatik RFID eksikleri + manuel işaretlenen RFID'siz eksikler.
  int get totalMissingCount => missingEpcs.length + markedMissingItemIds.length;

  /// Sayılmış kabul edilen = kabinde okunan RFID'li + eksik İŞARETLENMEYEN RFID'siz.
  /// (Kullanıcı bir RFID'siz item'ı eksik işaretlerse "sayılmadı" demektir.)
  int get censusCountedTotal {
    final rfidCounted = rfidCountedCount; // expected ∩ read
    final nonRfidCounted = _censusNonRfidItems.where((i) => !markedMissingItemIds.contains(i.id)).length;
    return rfidCounted + nonRfidCounted;
  }

  int get unplannedCount => unplannedMovements.length;
  int get notFoundCount => notFoundEpcs.length;
  int get rfidExpectedCount => expectedEpcs.length;

  bool get hasUnplannedMovement => unplannedMovements.isNotEmpty;
  bool get hasUnexpectedTag => placedEpcs.isNotEmpty;

  /// Tamamla: baseline bitti VE yabancı etiket yok.
  /// Eksik/fazla engellemez (bildirim gider); yabancı etiket BLOKE eder.
  ///
  /// SWREQ-CLI-CENSUS-003
  bool get canComplete {
    if (!baselineCompleted) return false;
    if (placedEpcs.isNotEmpty) return false; // yabancı etiket → blokaj
    return true;
  }

  List<CensusMedicineGroup> get groups => groupPrescriptionItemsByMedicine(
    items: prescriptionItems,
    rfidReadEpcs: rfidReadEpcs,
    markedMissingItemIds: markedMissingItemIds,
  );

  /// RFID reconciliation kümelerini sıfırlar. Reçete/seçim/sahne KORUNUR.
  MobileCensusReady get clearedRfidState =>
      copyWith(baselineCompleted: false, baselineEpcs: const {}, baselineLostEpcs: const {}, placedEpcs: const {});

  MobileCensusReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<int>? selectedItemIds,
    Set<int>? markedMissingItemIds,
    List<CensusExtraStock>? extraStocks,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? baselineEpcs,
    Set<String>? baselineLostEpcs,
    Set<String>? placedEpcs,
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
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      markedMissingItemIds: markedMissingItemIds ?? this.markedMissingItemIds,
      extraStocks: extraStocks ?? this.extraStocks,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      baselineEpcs: baselineEpcs ?? this.baselineEpcs,
      baselineLostEpcs: baselineLostEpcs ?? this.baselineLostEpcs,
      placedEpcs: placedEpcs ?? this.placedEpcs,
    );
  }
}

/// Kayıt başarıyla gitti; çekmece hâlâ açık, kullanıcının kapatması bekleniyor.
/// Butonlar kalkar. RFID canlı dinlenir — kullanıcı bu sırada tag alır/geri
/// koyarsa ready.baselineLostEpcs güncellenir, banner anlık gösterilir.
/// Çekmece kapandığı an _reportUnplannedMovements bu kümeleri okuyup bildirir.
final class MobileCensusWaitingClose extends MobileCensusState {
  const MobileCensusWaitingClose({required this.ready});

  final MobileCensusReady ready;
}

/// Kullanıcı "Tamamla" demeden çekmeceyi kapattı. Kayıt YOK.
/// İptal (çık) veya Tekrar Dene (çekmece yeniden açılır) seçenekleri sunulur.
final class MobileCensusClosedEarly extends MobileCensusState {
  const MobileCensusClosedEarly({required this.ready});

  final MobileCensusReady ready;
}

/// Sayım tamamlama işlemi devam ediyor.
final class MobileCensusSaving extends MobileCensusState {
  const MobileCensusSaving({required this.ready});

  final MobileCensusReady ready;
}

/// Sayım başarıyla tamamlandı.
final class MobileCensusSuccess extends MobileCensusState {
  const MobileCensusSuccess({this.message, required this.ready});

  final String? message;
  final MobileCensusReady ready;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileCensusError extends MobileCensusState {
  const MobileCensusError({required this.message, required this.previousState});

  final String message;
  final MobileCensusState previousState;
}

/// Kurtarılamaz, kritik sistem veya donanım hatası.
///
/// Örneğin: Çekmece mekanik olarak sıkıştı, donanım bağlantısı aniden koptu
/// veya API'den 500 Internal Server Error gibi bloklayıcı bir yanıt alındı.
///
/// Bu state'teyken:
///   - Süreç tamamen durdurulur.
///   - Kullanıcıya net bir hata mesajı gösterilir.
///   - Dialog kapatıldığında (dismiss), [previousState] içinden ayıklanan
///     temiz bir state'e (örneğin Idle) geri dönülür.
final class MobileCensusFatalError extends MobileCensusState {
  const MobileCensusFatalError({required this.failure, required this.previousState});

  final CabinOperationFailure failure;
  final MobileCensusState previousState;
}

extension MobileCensusStateX on MobileCensusState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileCensusLoading(:final slots) => slots,
    MobileCensusIdle(:final slots) => slots,
    MobileCensusSlotSelected(:final slots) => slots,
    MobileCensusNoPatient(:final slots) => slots,
    MobileCensusReady(:final slots) => slots,
    MobileCensusSaving(:final ready) => ready.slots,
    MobileCensusWaitingClose(:final ready) => ready.slots,
    MobileCensusClosedEarly(:final ready) => ready.slots,
    MobileCensusSuccess(:final ready) => ready.slots,
    MobileCensusError(:final previousState) => previousState.slots,
    MobileCensusFatalError(:final previousState) => previousState.slots,
    MobileCensusUninitialized() => const [],
    MobileCensusDrawerOpening(:final ready) => ready.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileCensusIdle(:final mobileSlots) => mobileSlots,
    MobileCensusLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileCensusSlotSelected(:final mobileSlots) => mobileSlots,
    MobileCensusNoPatient(:final mobileSlots) => mobileSlots,
    MobileCensusReady(:final mobileSlots) => mobileSlots,
    MobileCensusSaving(:final ready) => ready.mobileSlots,
    MobileCensusWaitingClose(:final ready) => ready.mobileSlots,
    MobileCensusClosedEarly(:final ready) => ready.mobileSlots,
    MobileCensusSuccess(:final ready) => ready.mobileSlots,
    MobileCensusError(:final previousState) => previousState.mobileSlots,
    MobileCensusFatalError(:final previousState) => previousState.mobileSlots,
    MobileCensusDrawerOpening(:final ready) => ready.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileCensusIdle(:final assignments) => assignments,
    MobileCensusSlotSelected(:final assignments) => assignments,
    MobileCensusLoading(:final assignments) => assignments ?? const [],
    MobileCensusNoPatient(:final assignments) => assignments,
    MobileCensusReady(:final assignments) => assignments,
    MobileCensusSaving(:final ready) => ready.assignments,
    MobileCensusWaitingClose(:final ready) => ready.assignments,
    MobileCensusClosedEarly(:final ready) => ready.assignments,
    MobileCensusSuccess(:final ready) => ready.assignments,
    MobileCensusError(:final previousState) => previousState.assignments,
    MobileCensusFatalError(:final previousState) => previousState.assignments,
    MobileCensusDrawerOpening(:final ready) => ready.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileCensusSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileCensusNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileCensusReady(:final selectedSlotId) => selectedSlotId,
    MobileCensusSaving(:final ready) => ready.selectedSlotId,
    MobileCensusWaitingClose(:final ready) => ready.selectedSlotId,
    MobileCensusClosedEarly(:final ready) => ready.selectedSlotId,
    MobileCensusSuccess(:final ready) => ready.selectedSlotId,
    MobileCensusError(:final previousState) => previousState.selectedSlotId,
    MobileCensusFatalError(:final previousState) => previousState.selectedSlotId,
    MobileCensusDrawerOpening(:final ready) => ready.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileCensusSlotSelected(:final selectedSlot) => selectedSlot,
    MobileCensusLoading(:final selectedSlot) => selectedSlot,
    MobileCensusNoPatient(:final selectedSlot) => selectedSlot,
    MobileCensusReady(:final selectedSlot) => selectedSlot,
    MobileCensusSaving(:final ready) => ready.selectedSlot,
    MobileCensusWaitingClose(:final ready) => ready.selectedSlot,
    MobileCensusClosedEarly(:final ready) => ready.selectedSlot,
    MobileCensusSuccess(:final ready) => ready.selectedSlot,
    MobileCensusError(:final previousState) => previousState.selectedSlot,
    MobileCensusFatalError(:final previousState) => previousState.selectedSlot,
    MobileCensusDrawerOpening(:final ready) => ready.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileCensusNoPatient(:final selectedCell) => selectedCell,
    MobileCensusReady(:final selectedCell) => selectedCell,
    MobileCensusWaitingClose(:final ready) => ready.selectedCell,
    MobileCensusClosedEarly(:final ready) => ready.selectedCell,
    MobileCensusError(:final previousState) => previousState.selectedCell,
    MobileCensusFatalError(:final previousState) => previousState.selectedCell,
    MobileCensusDrawerOpening(:final ready) => ready.selectedCell,

    _ => null,
  };

  int get cabinId => switch (this) {
    MobileCensusLoading(:final cabinId) => cabinId,
    MobileCensusIdle(:final cabinId) => cabinId,
    MobileCensusSlotSelected(:final cabinId) => cabinId,
    MobileCensusNoPatient(:final cabinId) => cabinId,
    MobileCensusReady(:final cabinId) => cabinId,
    MobileCensusSaving(:final ready) => ready.cabinId,
    MobileCensusWaitingClose(:final ready) => ready.cabinId,
    MobileCensusClosedEarly(:final ready) => ready.cabinId,
    MobileCensusSuccess(:final ready) => ready.cabinId,
    MobileCensusError(:final previousState) => previousState.cabinId,
    MobileCensusFatalError(:final previousState) => previousState.cabinId,
    MobileCensusDrawerOpening(:final ready) => ready.cabinId,
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

  List<BedAssignment> get availableAssignments =>
      assignments.where((a) => a.cellId != null && a.hospitalization != null).toList();

  MobileCensusReady? get readyContext => switch (this) {
    MobileCensusReady r => r,
    MobileCensusSaving(:final ready) => ready,
    MobileCensusWaitingClose(:final ready) => ready,
    MobileCensusClosedEarly(:final ready) => ready,
    MobileCensusSuccess(:final ready) => ready,
    MobileCensusError(:final previousState) => previousState.readyContext,
    MobileCensusFatalError(:final previousState) => previousState.readyContext,
    MobileCensusDrawerOpening(:final ready) => ready,
    _ => null,
  };

  bool shouldKeepDialog(MobileDrawerStage stage) {
    return switch (this) {
      MobileCensusSuccess() || MobileCensusFatalError() => false,
      MobileCensusClosedEarly() => true,
      MobileCensusWaitingClose() => true,
      MobileCensusSaving() => true,
      MobileCensusError() => true,
      _ =>
        readyContext != null &&
            (stage is MobileDrawerOpening ||
                stage is MobileDrawerOpened ||
                (stage is MobileDrawerClosed && readyContext!.baselineCompleted)),
    };
  }
}
