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

/// Çekmece açılış komutu gönderildi, ilk stage event bekleniyor.
///
/// [startIntake] çağrıldıktan sonra [MobileDrawerOpening] event'i gelene kadar
/// geçen kısa süreyi kapsar. UI bu state'de "Doluma başla" butonunu loading
/// gösterir. Bu state Opened event'i ile [MobileIntakeReady]'e geri döner ve
/// baseline scan başlar.
final class MobileIntakeDrawerOpening extends MobileIntakeState {
  const MobileIntakeDrawerOpening({
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

  /// Hata veya geri dönüş için referans. RFID kümeleri burada tutulur;
  /// orchestrator opened sonrası ready'e döner.
  final MobileIntakeReady ready;
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
    this.reportingItemIds = const {}, // "eksik stok bildiriliyor" loading
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.purchasePending,
    this.baselineCompleted = false,
    this.notFoundEpcs = const {},
    this.unexpectedEpcs = const {},
    this.unplannedMovements = const {},
    this.previouslyTakenEpcs = const {},
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
  final Set<String> rfidReadEpcs;
  final Set<int> reportingItemIds;

  /// Kabinden çıkarılmış (alındı sayılan) EPC'ler.
  ///
  /// Dolumun tersine: [rfidReadEpcs] artık okunabilenler,
  /// [takenEpcs] ise artık okunmayanlar (kabinden çıkarılanlar).
  /// EPC geri gelirse [takenEpcs]'ten çıkarılır.
  final Set<String> takenEpcs;
  final Set<int> selectedItemIds;
  final DateRangePreset datePreset;
  final PrescriptionMovementType? statusFilter;

  /// Çekmece açıldıktan sonra baseline snapshot tamamlandı mı?
  /// false iken dialog "Tarama yapılıyor..." gösterir.
  final bool baselineCompleted;

  /// Seçili RFID'li item'ların snapshot'ta okunmayan EPC'leri.
  /// Bu EPC'ler için kullanıcı hiçbir şey yapmaz; "Tamamla" basıldığında
  /// otomatik eksik stok bildirimi tetiklenir.
  ///
  /// SWREQ-CLI-INTAKE-007
  final Set<String> notFoundEpcs;

  /// Snapshot'ta okunan ama seçili herhangi bir item'a ait olmayan EPC'ler.
  /// Kabinde olmaları normal (başka hastaların ilaçları); yalnızca
  /// kaybolurlarsa plan dışı sayılır.
  final Set<String> unexpectedEpcs;

  /// Plan dışı hareket eden EPC'ler.
  /// unexpectedEpcs'ten lost olanlar buraya geçer.
  ///
  /// SWREQ-CLI-INTAKE-008
  final Set<String> unplannedMovements;

  /// MobileIntakeRollbackInProgress state'inde, daha önce yerleştirilmiş olan tag'leri tutar.
  /// Bu sayede tag çıkarıldığında "Kabine Bırakıldı" badge'i gösterebiliriz.
  final Set<String> previouslyTakenEpcs;

  /// Manuel eksik stok bildirimi BAŞARIYLA gönderilmiş item id'leri.
  /// reportingItemIds (anlık loading) ile karıştırılmamalı — bu kalıcıdır,
  /// backend reçeteyi yenileyip item'ı düşürene kadar butonu disabled tutar.
  final Set<int> reportedMissingItemIds;

  /// Kabinde okunan, expectedEpcs'te olan ama seçili olmayan EPC'ler
  /// (= PASSIVE, başka hastaların ilaçları). Kaybolurlarsa unplannedMovements'a geçer.
  final Set<String> passiveEpcs;

  int get selectedSlotId => selectedSlot.slotId;

  /// Snapshot'ta okunan toplam etiket sayısı (mockup'taki "Kabinde okunan").
  int get totalReadCount => rfidReadEpcs.length + passiveEpcs.length + unexpectedEpcs.length;

  /// Plan dışı hareket sayısı (mockup'taki "Plan dışı hareket").
  int get unplannedCount => unplannedMovements.length;

  /// Bulunamayan seçili RFID'li item sayısı.
  int get notFoundCount => _selectedRfidItems.where((i) => notFoundEpcs.contains(i.rfidTag!)).length;

  /// Tamamla butonu için: seçili RFID'li item'ların EPC'si takenEpcs'te mi?
  ///
  /// RFID'li item yoksa (hepsi RFID'siz) direkt true döner.
  bool get canComplete {
    if (!baselineCompleted) return false; // snapshot daha bitmedi
    final rfidItems = _selectedRfidItems;
    if (rfidItems.isEmpty) return true;
    return rfidItems.every((i) {
      final epc = i.rfidTag!;
      // Ya kabinde okundu ve çıkartıldı → takenEpcs
      // Ya da hiç okunmadı → notFoundEpcs (otomatik eksik bildirim olacak)
      return takenEpcs.contains(epc) || notFoundEpcs.contains(epc);
    });
  }

  /// Banner sayacı için: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => _selectedRfidItems.length;

  /// Bunlardan kaç tanesinin EPC'si takenEpcs'te (alındı sayıldı).
  int get rfidTakenCount => _selectedRfidItems.where((i) => takenEpcs.contains(i.rfidTag!)).length;

  /// UI banner'ı için: plan dışı hareket var mı?
  bool get hasUnplannedMovement => unplannedMovements.isNotEmpty;

  bool get hasUnexpectedTag => unexpectedEpcs.isNotEmpty;

  /// Rollback sırasında: previouslyTakenEpcs'ten henüz kabine geri konmamış
  /// (yani hâlâ rfidReadEpcs'te OKUNMAYAN) tag'ler. Boşsa rollback tamamdır.
  /// _onDrawerStageChange'deki MobileDrawerClosed branch'i bunu kullanır.
  Set<String> get pendingRollbackEpcs => previouslyTakenEpcs.difference(rfidReadEpcs);

  /// Rollback tamamlanma koşulu: tüm alınan tag'ler kabine geri kondu mu?
  bool get isRollbackComplete => pendingRollbackEpcs.isEmpty;

  Set<String> get selectedRfidEpcs => _selectedRfidItems.map((i) => i.rfidTag!).toSet();

  /// RFID reconciliation kümelerinin tümünü sıfırlayan bir kopya.
  /// Reopen, cancel, drawer fail, complete success akışlarında kullanılır.
  /// Reçete, seçim ve sahne KORUNUR — sadece RFID bayrakları sıfırlanır.
  /// previouslyTakenEpcs de sıfırlanır (rollback bağlamı bitti).
  MobileIntakeReady get clearedRfidState => copyWith(
    // ← YENİ (dolumdan uyarlandı)
    baselineCompleted: false,
    rfidReadEpcs: const {},
    takenEpcs: const {},
    notFoundEpcs: const {},
    unexpectedEpcs: const {},
    passiveEpcs: const {},
    unplannedMovements: const {},
    previouslyTakenEpcs: const {},
  );

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
    Set<int>? reportingItemIds,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? notFoundEpcs,
    Set<String>? unexpectedEpcs,
    Set<String>? unplannedMovements,
    Set<String>? previouslyTakenEpcs,
    Set<int>? reportedMissingItemIds,
    Set<String>? expectedEpcs,
    Set<String>? passiveEpcs,
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
      reportingItemIds: reportingItemIds ?? this.reportingItemIds,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      notFoundEpcs: notFoundEpcs ?? this.notFoundEpcs,
      unexpectedEpcs: unexpectedEpcs ?? this.unexpectedEpcs,
      unplannedMovements: unplannedMovements ?? this.unplannedMovements,
      previouslyTakenEpcs: previouslyTakenEpcs ?? this.previouslyTakenEpcs,
      reportedMissingItemIds: reportedMissingItemIds ?? this.reportedMissingItemIds,

      passiveEpcs: passiveEpcs ?? this.passiveEpcs,
    );
  }
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

/// Kullanıcı hata aldıktan sonra "Vazgeç" ile işlemi iptal etti.
/// RFID state'i KORUNUR, böylece kullanıcı çıkardığı tag'ler
/// unplannedMovements olarak doğru şekilde kaydedilir.
///
/// Bu state'teyken:
///   - Drawer açık veya kapanmış olabilir
///   - Kullanıcı tag'leri çıkarırken event'ler çalışmaya devam eder
///   - Tüm tag'ler çıkınca işlem doğal olarak sonlanır
final class MobileIntakeRollbackInProgress extends MobileIntakeState {
  const MobileIntakeRollbackInProgress({
    required this.slots,
    required this.mobileSlots,
    required this.selectedSlot,
    required this.assignments,
    required this.cabinId,
    required this.ready,
    this.cancelledAt,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileDrawerSlot> mobileSlots;
  final MobileSlotVisual selectedSlot;
  final List<BedAssignment> assignments;
  final int cabinId;

  /// RFID state'i KORUNAN Ready (baselineCompleted, rfidReadEpcs, passiveEpcs, unplannedMovements, vs.)
  final MobileIntakeReady ready;

  final DateTime? cancelledAt;

  int get selectedSlotId => selectedSlot.slotId;
  MobileCellCoord get selectedCell => ready.selectedCell;

  MobileIntakeRollbackInProgress copyWith({MobileIntakeReady? ready}) {
    return MobileIntakeRollbackInProgress(
      slots: slots,
      mobileSlots: mobileSlots,
      selectedSlot: selectedSlot,
      assignments: assignments,
      cabinId: cabinId,
      ready: ready ?? this.ready,
    );
  }
}

/// Geri alma (rollback) işlemi başarıyla tamamlandı.
///
/// Kullanıcı, donanımdan geri alması gereken tüm etiketleri çıkardığında
/// (yani rfidReadEpcs kümesi tamamen boşaldığında) bu state'e geçilir.
///
/// Bu state'teyken:
///   - UI katmanı bu değişimi dinler ve açık olan dialogu otomatik kapatır.
///   - Sistem güvenli bir şekilde [MobileIntakeIdle] veya uygun sahneye döner.
final class MobileIntakeRollbackCompleted extends MobileIntakeState {
  const MobileIntakeRollbackCompleted({
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
    MobileIntakeDrawerOpening(:final slots) => slots,
    MobileIntakeRollbackInProgress(:final slots) => slots,
    MobileIntakeRollbackCompleted(:final slots) => slots,
    MobileIntakeFatalError(:final slots) => slots,
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
    MobileIntakeDrawerOpening(:final cabinId) => cabinId,
    MobileIntakeRollbackInProgress(:final cabinId) => cabinId,
    MobileIntakeRollbackCompleted(:final cabinId) => cabinId,
    MobileIntakeFatalError(:final cabinId) => cabinId,
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

  /// RFID reconciliation kümelerini taşıyan Ready'i çıkarır.
  ///
  /// Error state'i için previousState içine recursive bakar — böylece complete
  /// fail sırasında dialog hâlâ RFID kümelerini, baseline durumunu ve
  /// reçete/seçim sahnesini gösterebilir. Dialog state geçişleri (Ready →
  /// Saving → Error → Ready) sırasında kapanmaz, içinde error mesajı + retry
  /// butonu göstererek yerinde kalır.
  MobileIntakeReady? get readyContext => switch (this) {
    MobileIntakeReady r => r,
    MobileIntakeCheckInProgress(:final ready) => ready,
    MobileIntakeDrawerOpening(:final ready) => ready,
    MobileIntakeSaving(:final ready) => ready,
    MobileIntakeSuccess(:final ready) => ready,
    MobileIntakeError(:final previousState) => previousState.readyContext,
    MobileIntakeRollbackInProgress(:final ready) => ready,
    _ => null,
  };

  /// Dialog şu anki state + drawer stage kombinasyonunda açık tutulmalı mı?
  ///
  /// Aynı mantık hem view'da (açma kararı) hem dialog'da (kapanma kararı)
  /// kullanılır — tek kaynak, çift kontrol noktasında tutarlılık. Pop'u
  /// dialog'un kendi context'inden çağırmak için bu helper gereklidir;
  /// böylece manuel `Navigator.pop` ile state geçişleri arasındaki yarış
  /// sorunu kalmaz.
  bool shouldKeepDialog(MobileDrawerStage stage) {
    // Terminal state'ler — drawer stage ne olursa olsun dialog KAPANIR
    if (this is MobileIntakeSuccess) return false;
    if (this is MobileIntakeRollbackCompleted) return false;
    if (this is MobileIntakeFatalError) return false;

    // Bu state'lerde drawer stage ne olursa olsun dialog AÇIK kalmalı
    if (this is MobileIntakeRollbackInProgress) return true;
    if (this is MobileIntakeSaving) return true;
    if (this is MobileIntakeError) return true;

    final hasReady = readyContext != null;
    final drawerActive = stage is MobileDrawerOpening || stage is MobileDrawerOpened || stage is MobileDrawerClosed;
    return hasReady && drawerActive;
  }
}
