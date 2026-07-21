import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../../core/hardware/hardware.dart';

// [SWREQ-CLI-REFILL-003] [IEC 62304 §5.5]
// Mobil kabin dolum ekranı state tanımları.
//
// State hiyerarşisi (sealed class):
//
//   MobileRefillState
//   ├─ Uninitialized      → init() çağrılmadı
//   ├─ Loading            → kabin verisi / reçeteler yükleniyor
//   ├─ Idle               → veri hazır, slot seçilmedi
//   ├─ SlotSelected       → slot seçildi, göz seçilmedi
//   ├─ NoPatient          → göz seçildi, atanmış hasta yok
//   ├─ Ready              → ANA ÇALIŞMA STATE'İ (RFID reconciliation kümeleri burada)
//   ├─ DrawerStarting     → çekmece açılış komutu gönderildi, ilk stage event bekleniyor
//   ├─ Saving             → completeRefill API çağrısı devam ediyor
//   ├─ Success            → dolum başarıyla tamamlandı
//   └─ Error              → herhangi bir hata; previousState ile geri dönülür
//
// RFID reconciliation kümeleri ve operasyon-bazlı sapmalar için
// `rfid-stock-notifications` skill'i (§3, §5.1 Dolum) birincil referanstır.
// MobileRefillReady'deki 6 küme + Dolum'a özel `unexpectedLostEpcs` o skill'in
// §3 state kontratıyla bire bir uyumludur.
//
// Sınıf: Class B

sealed class MobileRefillState {
  const MobileRefillState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Geçici / sahne state'leri
// ─────────────────────────────────────────────────────────────────────────────

/// init() çağrılana kadar geçici state — view ilk frame'de bunu görür.
final class MobileRefillUninitialized extends MobileRefillState {
  const MobileRefillUninitialized();
}

/// İlk yükleme veya reçete yenileme devam ediyor.
///
/// İki ayrı amaç için kullanılır:
///   1) init() — atama listesi yükleniyor (slots/mobileSlots/assignments null olabilir)
///   2) _loadPrescriptions — bir göz seçildi, o hastanın reçeteleri çekiliyor
///      (slots/mobileSlots/assignments dolu, üst panel kaybolmasın diye)
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

/// Kabin verisi yüklendi, hiçbir slot/göz seçilmedi.
/// Sağ panel "hasta listesi" gösterir.
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

/// Göz seçildi ancak atanmış hasta yok.
/// Reçete yüklenmez; kullanıcı başka göze geçebilir.
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

// ─────────────────────────────────────────────────────────────────────────────
// MobileRefillReady — ana çalışma state'i
// ─────────────────────────────────────────────────────────────────────────────

/// Göz seçildi, hasta var, reçeteler yüklendi.
///
/// RFID reconciliation kümeleri bu state'te tutulur. Tüm sarmalayıcı state'ler
/// (DrawerStarting, Saving) içlerinde bir [MobileRefillReady] referansı taşır;
/// böylece sahne korunur ve hata sonrası geri dönüş kolay olur.
///
/// **Reconciliation kümeleri** (rfid-stock-notifications §3):
///   Snapshot anında doldurulur:
///     - passiveEpcs       = OBSERVED ∩ EXPECTED
///     - unexpectedEpcs    = OBSERVED ∖ EXPECTED   (Dolum blokajı)
///   Snapshot sonrası canlı RFID event'leri ile değişir:
///     - rfidReadEpcs      = yerleştirilen yeni dolum tag'leri (EXPECTED'da OLMAYAN
///                           ve baseline sonrası okunan tag'ler)
///     - unplannedMovements= PASSIVE'ten lost olanlar (izinsiz çıkış → bildirim)
///     - unexpectedLostEpcs= UNEXPECTED'ten lost olanlar (düzeltici → bildirim YOK)
///   Dolum'da NOT_FOUND anlamsızdır (SELECTED EPC'leri yok); `notFoundEpcs`
///   alanı state kontrat uniformitesi için tutulur, daima boştur.
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
    required this.selectedItemIds,
    this.datePreset = DateRangePreset.today,
    this.statusFilter = PrescriptionMovementType.filledWaiting,
    this.baselineCompleted = false,
    this.baselineEpcs = const {},
    this.placedEpcs = const {},
    this.baselineLostEpcs = const {},
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

  /// Çekmece açıldığında alınan snapshot ile yakalanan, işlem ÖNCESİ kabinde
  /// fiziksel olarak bulunan TÜM etiketler (OBSERVED@baseline).
  ///
  /// Çekmece açıldığında snapshot ile yakalanan, işlem ÖNCESİ kabinde bulunan
  /// TÜM etiketler. İşlem boyunca SABİT; hepsi eşit ("kabin stoğu, çıkmamalı").
  /// Lost olan etiketler `baselineLostEpcs`'te izlenir, bu küme değişmez.
  final Set<String> baselineEpcs;

  /// Baseline SONRASI kabine yerleştirilen (yeni okunan) ve baseline'da olmayan
  /// etiketler — kullanıcının bu işlemde eklediği dolum tag'leri.
  ///
  /// Bidirectional: EPC lost olursa buradan çıkar (kullanıcı geri aldı).
  /// Bunlardan seçili ilaçlara denk gelmeyenler `extraPlacedEpcs` ile yakalanır.
  final Set<String> placedEpcs;

  /// Baseline'dan lost olan etiketler — kullanıcının işlem sırasında kabinden
  /// çıkardığı, çıkarmaması gereken etiketler (dolumda hiçbir şey alınmamalı).
  /// Hepsi **izinsiz çıkış**; complete'te her biri Eksik Stok Bildirimi üretir.
  /// Bidirectional: EPC tekrar okunursa buradan çıkar (kullanıcı geri koydu).
  final Set<String> baselineLostEpcs;

  /// Çekmece açıldıktan sonra baseline snapshot tamamlandı mı?
  /// false iken UI "Tarama yapılıyor..." gösterir; complete butonu disabled.
  final bool baselineCompleted;

  int get selectedSlotId => selectedSlot.slotId;

  /// Kullanıcının dolum için seçtiği, etiketi olan (RFID'li) ilaçlar.
  /// Etiketsiz seçili ilaçlar listede gösterilir ama burada yer almaz
  /// (etiket takibi yapılamaz).
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

  /// Seçili RFID'li ilaçların beklenen etiketleri — bu işlemde kabine
  /// yerleştirilmesi gereken tag'ler. Seçimden türetilir (tek kaynak-doğruluk).
  Set<String> get expectedEpcs => _selectedRfidItems.map((i) => i.rfidTag!).toSet();

  /// Kullanıcının seçtiği ilaçlara denk gelmeyen, fazladan/yanlış yerleştirilmiş
  /// etiketler. Boş değilse complete blokeli — kullanıcı çekmeceyi tekrar açıp
  /// fazla etiketi çıkarmalı (lost olunca otomatik silinir, blokaj kalkar).
  Set<String> get unexpectedEpcs => placedEpcs.difference(expectedEpcs);

  /// Beklenen etiketlere denk gelen yerleştirmeler (doğru dolum).
  Set<String> get correctlyPlacedEpcs => placedEpcs.intersection(expectedEpcs);

  /// Kapanışta eksik bildirilecek etiketler: çıkarılan mevcut stok +
  /// yerleştirilmesi beklenip yerleştirilmeyen dolum etiketleri.
  Set<String> get missingEpcs => baselineLostEpcs.union(expectedEpcs.difference(placedEpcs));

  /// Banner: plan dışı (izinsiz) çıkış sayısı.
  int get unplannedCount => baselineLostEpcs.length;

  /// Hâlâ kabinde duran yabancı tag sayısı — 0 değilse complete blokeli.
  int get unexpectedCount => unexpectedEpcs.length;

  /// Banner: seçili RFID'li ilaç sayısı (yerleştirilmesi beklenen).
  int get expectedCount => expectedEpcs.length;

  /// Banner: seçili RFID'li ilaç sayısı (yerleştirilmesi beklenen).
  int get rfidExpectedCount => expectedEpcs.length;

  /// Beklenen etiketlerden kaç tanesi yerleştirilmiş.
  int get rfidReadCount => placedEpcs.intersection(expectedEpcs).length;

  /// Tüm seçili RFID'li etiketler yerleştirildi mi? (RFID'li ilaç yoksa true)
  bool get allSelectedRfidRead => rfidExpectedCount == 0 || rfidReadCount >= rfidExpectedCount;

  bool get hasExtraPlacement => unexpectedEpcs.isNotEmpty;
  bool get hasUnplannedMovement => baselineLostEpcs.isNotEmpty;

  /// Tamamla butonu için kompozit kural (§5.1 Dolum):
  ///   1) Baseline scan tamamlanmış olmalı
  ///   2) Seçili ilaçlara denk gelmeyen (yabancı/fazla) tag olmamalı
  ///   3) Tüm seçili RFID'li etiketler yerleştirilmiş olmalı
  bool get canComplete {
    if (!baselineCompleted) return false;
    if (unexpectedEpcs.isNotEmpty) return false; // yabancı/fazla tag var
    return allSelectedRfidRead; // beklenenlerin hepsi yerleşti
  }

  /// RFID reconciliation kümelerinin tümünü sıfırlayan bir kopya.
  /// Reopen, cancel, drawer fail, complete success akışlarında kullanılır.
  /// Reçete, seçim ve sahne KORUNUR — sadece RFID bayrakları sıfırlanır.
  MobileRefillReady get clearedRfidState =>
      copyWith(baselineCompleted: false, baselineEpcs: const {}, placedEpcs: const {}, baselineLostEpcs: const {});

  MobileRefillReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<int>? selectedItemIds,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? baselineEpcs,
    Set<String>? placedEpcs,
    Set<String>? baselineLostEpcs,
    Set<String>? previouslyPlacedEpcs,
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
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      datePreset: datePreset ?? this.datePreset,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      baselineCompleted: baselineCompleted ?? this.baselineCompleted,
      baselineEpcs: baselineEpcs ?? this.baselineEpcs,
      placedEpcs: placedEpcs ?? this.placedEpcs,
      baselineLostEpcs: baselineLostEpcs ?? this.baselineLostEpcs,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Süreç state'leri — Ready'i sarmalayanlar
// ─────────────────────────────────────────────────────────────────────────────

/// Çekmece açılış komutu gönderildi, ilk stage event bekleniyor.
///
/// [startRefill] çağrıldıktan sonra [MobileDrawerOpening] event'i gelene kadar
/// geçen kısa süreyi kapsar. UI bu state'de "Doluma başla" butonunu loading
/// gösterir. Bu state Opened event'i ile [MobileRefillReady]'e geri döner ve
/// baseline scan başlar.
final class MobileRefillDrawerOpening extends MobileRefillState {
  const MobileRefillDrawerOpening({required this.ready});

  /// Hata veya geri dönüş için referans. RFID kümeleri burada tutulur;
  /// orchestrator opened sonrası ready'e döner.
  final MobileRefillReady ready;
}

/// completeRefill API çağrısı devam ediyor.
///
/// rfid-stock-notifications §7 — bu state'te yalnızca **kayıt API'si** çalışır,
/// bildirim API'leri DEĞİL. Bildirimler kayıt başarılı olduktan sonra arka
/// planda fire-and-forget gönderilir.
final class MobileRefillSaving extends MobileRefillState {
  const MobileRefillSaving({required this.ready});

  final MobileRefillReady ready;
}

/// Dolum başarıyla tamamlandı.
///
/// dismissSuccess() bu state'i Idle'a çevirir veya seçili göz için reçeteleri
/// yenileyerek Ready'e döner (yeni dolum yapılabilmesi için).
final class MobileRefillSuccess extends MobileRefillState {
  const MobileRefillSuccess({required this.ready});

  final MobileRefillReady ready;
}

/// Kayıt başarıyla gitti; çekmece hâlâ açık, kullanıcının kapatması bekleniyor.
/// Butonlar kalkar. RFID canlı dinlenmeye devam eder — kullanıcı bu sırada
/// tag alır/bırakırsa `ready.placedEpcs` / `ready.baselineLostEpcs` güncellenir
/// ve `missingEpcs` / `extraEpcs` banner'da anlık gösterilir.
/// Çekmece kapandığı an `_reportUnplannedMovements` bu kümeleri okuyup bildirir.
final class MobileRefillWaitingClose extends MobileRefillState {
  const MobileRefillWaitingClose({required this.ready});

  final MobileRefillReady ready;
}

/// Kullanıcı "Tamamla" demeden çekmeceyi kapattı. Kayıt YOK.
/// Kullanıcıya seçenek sunulur: İptal (çık) veya Tekrar Dene (çekmece yeniden açılır).
/// `ready` korunur ki tekrar açılışta sahne + seçim kaybolmasın.
final class MobileRefillClosedEarly extends MobileRefillState {
  const MobileRefillClosedEarly({required this.ready});
  final MobileRefillReady ready;
}

/// Genel hata state'i — herhangi bir API/akış hatasında çağrılır.
///
/// previousState ile dismissError'da geri dönülür. Complete fail durumunda
/// previousState **RFID kümeleriyle birlikte korunmuş Ready** olur; kullanıcı
/// retry edebilsin diye sıfırlama YAPILMAZ (rfid-stock-notifications §7).
final class MobileRefillError extends MobileRefillState {
  const MobileRefillError({required this.message, required this.previousState});

  final String message;
  final MobileRefillState previousState;
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
final class MobileRefillFatalError extends MobileRefillState {
  const MobileRefillFatalError({required this.failure, required this.previousState});

  final CabinOperationFailure failure;
  final MobileRefillState previousState;
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension — Tüm state'lerden ortak alanları çekmek için
// ─────────────────────────────────────────────────────────────────────────────

extension MobileRefillStateX on MobileRefillState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileRefillLoading(:final slots) => slots,
    MobileRefillIdle(:final slots) => slots,
    MobileRefillSlotSelected(:final slots) => slots,
    MobileRefillNoPatient(:final slots) => slots,
    MobileRefillReady(:final slots) => slots,
    MobileRefillDrawerOpening(:final ready) => ready.slots,
    MobileRefillSaving(:final ready) => ready.slots,
    MobileRefillSuccess(:final ready) => ready.slots,
    MobileRefillError(:final previousState) => previousState.slots,
    MobileRefillUninitialized() => const [],
    MobileRefillFatalError(:final previousState) => previousState.slots,
    MobileRefillWaitingClose(:final ready) => ready.slots,
    MobileRefillClosedEarly(:final ready) => ready.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileRefillIdle(:final mobileSlots) => mobileSlots,
    MobileRefillLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileRefillSlotSelected(:final mobileSlots) => mobileSlots,
    MobileRefillNoPatient(:final mobileSlots) => mobileSlots,
    MobileRefillReady(:final mobileSlots) => mobileSlots,
    MobileRefillDrawerOpening(:final ready) => ready.mobileSlots, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.mobileSlots, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.mobileSlots, // ← düzeltildi
    MobileRefillError(:final previousState) => previousState.mobileSlots,
    MobileRefillWaitingClose(:final ready) => ready.mobileSlots,
    MobileRefillClosedEarly(:final ready) => ready.mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileRefillIdle(:final assignments) => assignments,
    MobileRefillSlotSelected(:final assignments) => assignments,
    MobileRefillLoading(:final assignments) => assignments ?? const [],
    MobileRefillNoPatient(:final assignments) => assignments,
    MobileRefillReady(:final assignments) => assignments,
    MobileRefillDrawerOpening(:final ready) => ready.assignments, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.assignments, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.assignments, // ← düzeltildi
    MobileRefillError(:final previousState) => previousState.assignments,
    MobileRefillWaitingClose(:final ready) => ready.assignments,
    MobileRefillClosedEarly(:final ready) => ready.assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileRefillSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileRefillNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileRefillReady(:final selectedSlotId) => selectedSlotId,
    MobileRefillDrawerOpening(:final ready) => ready.selectedSlotId, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.selectedSlotId, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.selectedSlotId, // ← düzeltildi
    MobileRefillError(:final previousState) => previousState.selectedSlotId,
    MobileRefillWaitingClose(:final ready) => ready.selectedSlotId,
    MobileRefillClosedEarly(:final ready) => ready.selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileRefillSlotSelected(:final selectedSlot) => selectedSlot,
    MobileRefillLoading(:final selectedSlot) => selectedSlot,
    MobileRefillNoPatient(:final selectedSlot) => selectedSlot,
    MobileRefillReady(:final selectedSlot) => selectedSlot,
    MobileRefillDrawerOpening(:final ready) => ready.selectedSlot, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.selectedSlot, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.selectedSlot, // ← düzeltildi
    MobileRefillError(:final previousState) => previousState.selectedSlot,
    MobileRefillWaitingClose(:final ready) => ready.selectedSlot,
    MobileRefillClosedEarly(:final ready) => ready.selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileRefillNoPatient(:final selectedCell) => selectedCell,
    MobileRefillReady(:final selectedCell) => selectedCell,
    MobileRefillError(:final previousState) => previousState.selectedCell,
    MobileRefillWaitingClose(:final ready) => ready.selectedCell,
    MobileRefillClosedEarly(:final ready) => ready.selectedCell,
    MobileRefillDrawerOpening(:final ready) => ready.selectedCell, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.selectedCell, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.selectedCell, // ← düzeltildi
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileRefillLoading(:final cabinId) => cabinId,
    MobileRefillIdle(:final cabinId) => cabinId,
    MobileRefillSlotSelected(:final cabinId) => cabinId,
    MobileRefillNoPatient(:final cabinId) => cabinId,
    MobileRefillReady(:final cabinId) => cabinId,
    MobileRefillDrawerOpening(:final ready) => ready.cabinId, // ← düzeltildi
    MobileRefillSaving(:final ready) => ready.cabinId, // ← düzeltildi
    MobileRefillSuccess(:final ready) => ready.cabinId, // ← düzeltildi
    MobileRefillError(:final previousState) => previousState.cabinId,
    MobileRefillUninitialized() => 0,
    MobileRefillFatalError(:final cabinId) => cabinId,
    MobileRefillWaitingClose(:final ready) => ready.cabinId,
    MobileRefillClosedEarly(:final ready) => ready.cabinId,
  };

  /// Atamaları gözle eşleştirir — panel listesi ve drawer panel hücreleri için.
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

  /// RFID reconciliation kümelerini taşıyan Ready'i çıkarır.
  ///
  /// Error state'i için previousState içine recursive bakar — böylece complete
  /// fail sırasında dialog hâlâ RFID kümelerini, baseline durumunu ve
  /// reçete/seçim sahnesini gösterebilir. Dialog state geçişleri (Ready →
  /// Saving → Error → Ready) sırasında kapanmaz, içinde error mesajı + retry
  /// butonu göstererek yerinde kalır.
  MobileRefillReady? get readyContext => switch (this) {
    MobileRefillReady r => r,
    MobileRefillDrawerOpening(:final ready) => ready,
    MobileRefillSaving(:final ready) => ready,
    MobileRefillWaitingClose(:final ready) => ready,
    MobileRefillClosedEarly(:final ready) => ready,
    MobileRefillSuccess(:final ready) => ready,
    MobileRefillError(:final previousState) => previousState.readyContext,
    MobileRefillFatalError(:final previousState) => previousState.readyContext,
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
    return switch (this) {
      MobileRefillSuccess() || MobileRefillFatalError() => false,
      MobileRefillClosedEarly() => true,
      MobileRefillWaitingClose() => true,
      _ => readyContext != null && (stage is MobileDrawerOpening || stage is MobileDrawerOpened),
    };
  }
}
