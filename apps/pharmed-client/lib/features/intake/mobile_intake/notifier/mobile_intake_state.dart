import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
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

/// Çekmece açılmadan ÖNCE: alım işleminin yapılabilir olup olmadığını
/// sunucuya soran kontrol fazı. Başarılı → Ready (çekmece açılır),
/// başarısız → Error (previousState: ready).
final class MobileIntakeCheckInProgress extends MobileIntakeState {
  const MobileIntakeCheckInProgress({required this.ready});

  final MobileIntakeReady ready;
}

/// Çekmece açılış komutu gönderildi, ilk stage event bekleniyor.
///
/// [startIntake] çağrıldıktan sonra [MobileDrawerOpening] event'i gelene kadar
/// geçen kısa süreyi kapsar. UI bu state'de "Doluma başla" butonunu loading
/// gösterir. Bu state Opened event'i ile [MobileIntakeReady]'e geri döner ve
/// baseline scan başlar.
final class MobileIntakeDrawerOpening extends MobileIntakeState {
  const MobileIntakeDrawerOpening({required this.ready});

  final MobileIntakeReady ready;
}

/// Göz seçildi, hasta var, reçeteler yüklendi — ana çalışma state'i.
///
/// RFID reconciliation modeli (dolumla simetrik, alım = kabinden ÇIKARMA):
///   Kalıcı runtime alanları YALNIZCA iki tanedir:
///     - baselineEpcs      = snapshot anındaki tüm kabin etiketleri (SABİT)
///     - baselineLostEpcs  = baseline'dan çıkarılan (lost olan) etiketler
///   Diğer tüm kümeler bunlardan + expectedEpcs (seçim) türetilir:
///     - takenEpcs      = baselineLostEpcs ∩ expectedEpcs  (başarıyla alındı)
///     - unplannedMovements = baselineLostEpcs ∖ expectedEpcs (izinsiz çıkış)
///     - notFoundEpcs   = expectedEpcs ∖ baselineEpcs  (kabinde hiç yoktu → eksik)
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
    required this.selectedItemIds,
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.purchasePending,
    this.baselineCompleted = false,
    this.baselineEpcs = const {},
    this.baselineLostEpcs = const {},
    this.placedEpcs = const {},
    this.markedMissingItemIds = const {},
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

  // ── RFID reconciliation — kalıcı iki alan ───────────────────────────────

  /// Çekmece açıldıktan sonra baseline snapshot tamamlandı mı?
  /// false iken dialog "Tarama yapılıyor..." gösterir; complete disabled.
  final bool baselineCompleted;

  /// Snapshot ile yakalanan, işlem ÖNCESİ kabinde bulunan TÜM etiketler.
  /// İşlem boyunca SABİT kalır; kaynak-doğruluk kümesi.
  final Set<String> baselineEpcs;

  /// Baseline'dan çıkarılan (lost olan) etiketler.
  /// Seçiliyse → alındı (taken), değilse → izinsiz çıkış (unplanned).
  /// Bidirectional: EPC tekrar okunursa buradan çıkar (kullanıcı geri koydu).
  final Set<String> baselineLostEpcs;

  /// İlk taramada (baseline) olmayıp, süreç esnasında okunan yabancı/hatalı etiketler.
  final Set<String> placedEpcs;

  /// Manuel EKSİK işaretlenen RFID'siz item id'leri.
  /// Complete anında değil — çekmece fiziksel kapandığında topluca eksik
  /// stok bildirimine dönüşür. Boşaltma/alım params'ından dışlanır.
  final Set<int> markedMissingItemIds;

  int get selectedSlotId => selectedSlot.slotId;

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

  /// Seçili RFID'li ilaçların beklenen etiketleri (alınması gerekenler).
  Set<String> get expectedEpcs => _selectedRfidItems.map((i) => i.rfidTag!).toSet();

  /// Baseline'dan çıkarılan VE seçili olan → başarıyla alındı.
  Set<String> get takenEpcs => baselineLostEpcs.intersection(expectedEpcs);

  /// Baseline'dan çıkarılan VE seçili OLMAYAN → izinsiz çıkış (başka hasta stoğu).
  /// Kapanışta eksik stok bildirimine dönüşür.
  Set<String> get unplannedMovements => baselineLostEpcs.difference(expectedEpcs);

  /// Beklenen ama baseline'da hiç okunmayan → kabinde yoktu (bulunamadı).
  /// "Tamamla" basıldığında otomatik eksik stok bildirimi tetiklenir.
  Set<String> get notFoundEpcs => expectedEpcs.difference(baselineEpcs);

  /// Kabinde anlık okunan toplam etiket (hâlâ duran baseline).
  int get totalReadCount => baselineEpcs.difference(baselineLostEpcs).length;

  int get unplannedCount => unplannedMovements.length;
  int get notFoundCount => notFoundEpcs.length;

  /// Banner sayacı: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => expectedEpcs.length;

  /// Bunlardan kaç tanesi alındı (taken).
  int get rfidTakenCount => takenEpcs.length;

  bool get hasUnplannedMovement => unplannedMovements.isNotEmpty;
  bool get hasUnexpectedEpc => placedEpcs.isNotEmpty;

  int get totalMissingCount => notFoundEpcs.length + markedMissingItemIds.length;

  /// Tamamla kuralı: seçili RFID'li ilaçların hepsi ya alındı ya bulunamadı.
  /// RFID'li ilaç yoksa (hepsi RFID'siz) direkt true.
  bool get canComplete {
    if (!baselineCompleted) return false;
    final rfidItems = _selectedRfidItems;
    if (rfidItems.isEmpty) return true;
    return rfidItems.every((i) {
      final epc = i.rfidTag!;
      return takenEpcs.contains(epc) || notFoundEpcs.contains(epc);
    });
  }

  /// RFID reconciliation kümelerini sıfırlayan kopya.
  /// Reopen, cancel, drawer fail, complete success akışlarında kullanılır.
  /// Reçete, seçim ve sahne KORUNUR.
  MobileIntakeReady get clearedRfidState =>
      copyWith(baselineCompleted: false, baselineEpcs: const {}, baselineLostEpcs: const {});

  MobileIntakeReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<int>? selectedItemIds,
    Set<int>? markedMissingItemIds,

    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? baselineEpcs,
    Set<String>? baselineLostEpcs,
    Set<String>? placedEpcs,
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
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      markedMissingItemIds: markedMissingItemIds ?? this.markedMissingItemIds,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      baselineEpcs: baselineEpcs ?? this.baselineEpcs,
      baselineLostEpcs: baselineLostEpcs ?? this.baselineLostEpcs,
      placedEpcs: placedEpcs ?? this.placedEpcs,
    );
  }
}

/// Alım tamamlama işlemi devam ediyor.
final class MobileIntakeSaving extends MobileIntakeState {
  const MobileIntakeSaving({required this.ready});

  final MobileIntakeReady ready;
}

/// Kayıt başarıyla gitti; çekmece hâlâ açık, kullanıcının kapatması bekleniyor.
/// Butonlar kalkar. RFID canlı dinlenir — kullanıcı bu sırada tag alır/geri
/// koyarsa ready.baselineLostEpcs güncellenir, banner anlık gösterilir.
/// Çekmece kapandığı an _reportUnplannedMovements bu kümeleri okuyup bildirir.
final class MobileIntakeWaitingClose extends MobileIntakeState {
  const MobileIntakeWaitingClose({required this.ready});

  final MobileIntakeReady ready;
}

/// Kullanıcı "Tamamla" demeden çekmeceyi kapattı. Kayıt YOK.
/// İptal (çık) veya Tekrar Dene (çekmece yeniden açılır) seçenekleri sunulur.
final class MobileIntakeClosedEarly extends MobileIntakeState {
  const MobileIntakeClosedEarly({required this.ready});

  final MobileIntakeReady ready;
}

/// Alım başarıyla tamamlandı.
final class MobileIntakeSuccess extends MobileIntakeState {
  const MobileIntakeSuccess({required this.ready, this.message});

  final MobileIntakeReady ready;
  final String? message;
}

/// İşlem hatası — previousState'e dönülür.
final class MobileIntakeError extends MobileIntakeState {
  const MobileIntakeError({required this.message, required this.previousState});

  final String message;
  final MobileIntakeState previousState;
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
final class MobileIntakeFatalError extends MobileIntakeState {
  const MobileIntakeFatalError({required this.message, required this.previousState});

  final String message;
  final MobileIntakeState previousState;
}

extension MobileIntakeStateX on MobileIntakeState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileIntakeLoading(:final slots) => slots,
    MobileIntakeIdle(:final slots) => slots,
    MobileIntakeSlotSelected(:final slots) => slots,
    MobileIntakeNoPatient(:final slots) => slots,
    MobileIntakeReady(:final slots) => slots,
    MobileIntakeDrawerOpening(:final ready) => ready.slots,
    MobileIntakeSaving(:final ready) => ready.slots,
    MobileIntakeWaitingClose(:final ready) => ready.slots,
    MobileIntakeClosedEarly(:final ready) => ready.slots,
    MobileIntakeSuccess(:final ready) => ready.slots,
    MobileIntakeError(:final previousState) => previousState.slots,
    MobileIntakeFatalError(:final previousState) => previousState.slots,
    MobileIntakeUninitialized() => const [],
    MobileIntakeCheckInProgress(:final ready) => ready.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileIntakeIdle(:final mobileSlots) => mobileSlots,
    MobileIntakeLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileIntakeSlotSelected(:final mobileSlots) => mobileSlots,
    MobileIntakeNoPatient(:final mobileSlots) => mobileSlots,
    MobileIntakeReady(:final mobileSlots) => mobileSlots,
    MobileIntakeDrawerOpening(:final ready) => ready.mobileSlots,
    MobileIntakeSaving(:final ready) => ready.mobileSlots,
    MobileIntakeWaitingClose(:final ready) => ready.mobileSlots,
    MobileIntakeClosedEarly(:final ready) => ready.mobileSlots,
    MobileIntakeSuccess(:final ready) => ready.mobileSlots,
    MobileIntakeError(:final previousState) => previousState.mobileSlots,
    MobileIntakeCheckInProgress(:final ready) => ready.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileIntakeIdle(:final assignments) => assignments,
    MobileIntakeSlotSelected(:final assignments) => assignments,
    MobileIntakeLoading(:final assignments) => assignments ?? const [],
    MobileIntakeNoPatient(:final assignments) => assignments,
    MobileIntakeReady(:final assignments) => assignments,
    MobileIntakeDrawerOpening(:final ready) => ready.assignments,
    MobileIntakeSaving(:final ready) => ready.assignments,
    MobileIntakeWaitingClose(:final ready) => ready.assignments,
    MobileIntakeClosedEarly(:final ready) => ready.assignments,
    MobileIntakeSuccess(:final ready) => ready.assignments,
    MobileIntakeError(:final previousState) => previousState.assignments,
    MobileIntakeCheckInProgress(:final ready) => ready.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileIntakeSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileIntakeNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileIntakeReady(:final selectedSlotId) => selectedSlotId,
    MobileIntakeDrawerOpening(:final ready) => ready.selectedSlotId,
    MobileIntakeSaving(:final ready) => ready.selectedSlotId,
    MobileIntakeWaitingClose(:final ready) => ready.selectedSlotId,
    MobileIntakeClosedEarly(:final ready) => ready.selectedSlotId,
    MobileIntakeSuccess(:final ready) => ready.selectedSlotId,
    MobileIntakeError(:final previousState) => previousState.selectedSlotId,
    MobileIntakeCheckInProgress(:final ready) => ready.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileIntakeSlotSelected(:final selectedSlot) => selectedSlot,
    MobileIntakeLoading(:final selectedSlot) => selectedSlot,
    MobileIntakeNoPatient(:final selectedSlot) => selectedSlot,
    MobileIntakeReady(:final selectedSlot) => selectedSlot,
    MobileIntakeDrawerOpening(:final ready) => ready.selectedSlot,
    MobileIntakeSaving(:final ready) => ready.selectedSlot,
    MobileIntakeWaitingClose(:final ready) => ready.selectedSlot,
    MobileIntakeClosedEarly(:final ready) => ready.selectedSlot,
    MobileIntakeSuccess(:final ready) => ready.selectedSlot,
    MobileIntakeError(:final previousState) => previousState.selectedSlot,
    MobileIntakeCheckInProgress(:final ready) => ready.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileIntakeNoPatient(:final selectedCell) => selectedCell,
    MobileIntakeReady(:final selectedCell) => selectedCell,
    MobileIntakeDrawerOpening(:final ready) => ready.selectedCell,
    MobileIntakeSaving(:final ready) => ready.selectedCell,
    MobileIntakeWaitingClose(:final ready) => ready.selectedCell,
    MobileIntakeClosedEarly(:final ready) => ready.selectedCell,
    MobileIntakeSuccess(:final ready) => ready.selectedCell,
    MobileIntakeError(:final previousState) => previousState.selectedCell,
    MobileIntakeCheckInProgress(:final ready) => ready.selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileIntakeLoading(:final cabinId) => cabinId,
    MobileIntakeIdle(:final cabinId) => cabinId,
    MobileIntakeSlotSelected(:final cabinId) => cabinId,
    MobileIntakeNoPatient(:final cabinId) => cabinId,
    MobileIntakeReady(:final cabinId) => cabinId,
    MobileIntakeDrawerOpening(:final ready) => ready.cabinId,
    MobileIntakeSaving(:final ready) => ready.cabinId,
    MobileIntakeWaitingClose(:final ready) => ready.cabinId,
    MobileIntakeClosedEarly(:final ready) => ready.cabinId,
    MobileIntakeSuccess(:final ready) => ready.cabinId,
    MobileIntakeError(:final previousState) => previousState.cabinId,
    MobileIntakeUninitialized() => 0,
    MobileIntakeCheckInProgress(:final ready) => ready.cabinId,
    _ => 0,
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

  MobileIntakeReady? get readyContext => switch (this) {
    MobileIntakeReady r => r,
    MobileIntakeDrawerOpening(:final ready) => ready,
    MobileIntakeSaving(:final ready) => ready,
    MobileIntakeWaitingClose(:final ready) => ready,
    MobileIntakeClosedEarly(:final ready) => ready,
    MobileIntakeSuccess(:final ready) => ready,
    MobileIntakeError(:final previousState) => previousState.readyContext,
    MobileIntakeCheckInProgress(:final ready) => ready,
    MobileIntakeFatalError(:final previousState) => previousState.readyContext,
    _ => null,
  };

  bool shouldKeepDialog(MobileDrawerStage stage) {
    return switch (this) {
      MobileIntakeSuccess() || MobileIntakeFatalError() => false,
      MobileIntakeCheckInProgress() => false, // ← kontrol fazı, dialog kapalı (inline spinner)
      MobileIntakeClosedEarly() => true,
      MobileIntakeWaitingClose() => true,
      MobileIntakeSaving() => true,
      MobileIntakeError() => true,
      _ => readyContext != null && (stage is MobileDrawerOpening || stage is MobileDrawerOpened),
    };
  }
}
