import 'package:pharmed_core/pharmed_core.dart';
import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/widgets.dart';

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
    this.rfidReadEpcs = const {},
    this.notFoundEpcs = const {},
    this.passiveEpcs = const {},
    this.unexpectedEpcs = const {},
    this.unplannedMovements = const {},
    this.unexpectedLostEpcs = const {},
    this.previouslyPlacedEpcs = const {},
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

  // ── RFID reconciliation kümeleri (§3) ──────────────────────────────────

  /// Çekmece açıldıktan sonra baseline snapshot tamamlandı mı?
  /// false iken UI "Tarama yapılıyor..." gösterir; complete butonu disabled.
  final bool baselineCompleted;

  /// Baseline sonrası kabinde okunan ve EXPECTED listesinde olmayan tag'ler.
  /// Dolum semantiğinde "kullanıcı tarafından yerleştirilen yeni dolum tag'leri".
  /// Bidirectional: EPC lost olursa bu kümeden çıkar (kullanıcı çıkardı).
  final Set<String> rfidReadEpcs;

  /// Dolum'da kullanılmaz (NOT_FOUND yok — SELECTED'da EPC olmadığı için).
  /// State kontrat uniformitesi için tutulur; daima boş.
  final Set<String> notFoundEpcs;

  /// Baseline'da okunan ve EXPECTED listesinde olan, dolum hedefi olmayan tag'ler.
  /// Mevcut kabin stoğu = bunlar lost olursa **izinsiz çıkış** sayılır →
  /// UNPLANNED olarak `unplannedMovements`'a yazılır.
  final Set<String> passiveEpcs;

  /// Baseline'da okunan ve EXPECTED listesinde OLMAYAN tag'ler.
  /// Kabin stoğuna ait değil; kullanıcı kabini açtığında orada olmamalıydı.
  /// **Dolum'a özel kural:** Bu küme boş olmadan complete edilemez (§5.1 blokaj).
  /// Kullanıcı tag'i çıkardığında → `unexpectedLostEpcs`'e geçer, complete açılır.
  final Set<String> unexpectedEpcs;

  /// PASSIVE'ten lost olan tag'ler — izinsiz çıkış.
  /// Complete sırasında Eksik Stok Bildirimi'ne dönüşür (her EPC için ayrı).
  /// Bidirectional: EPC geri okunursa bu kümeden çıkar, PASSIVE'e geri yazılır.
  final Set<String> unplannedMovements;

  /// UNEXPECTED'ten lost olan tag'ler — kullanıcı kabine ait olmayan tag'i çıkardı.
  /// **Dolum'da bildirim ÜRETMEZ** (düzeltici hareket, §5.1 matris).
  /// `unplannedMovements` ile karışmaması için ayrı tutulur.
  /// Bidirectional: EPC geri okunursa UNEXPECTED'a geri yazılır → tekrar blokaj.
  final Set<String> unexpectedLostEpcs;

  /// MobileRefillRollbackInProgress state'inde, daha önce yerleştirilmiş olan tag'leri tutar.
  /// Bu sayede tag çıkarıldığında "Kabinden Çıkarıldı" badge'i gösterebiliriz.
  final Set<String> previouslyPlacedEpcs;

  // ── Türetilmiş alanlar ─────────────────────────────────────────────────

  int get selectedSlotId => selectedSlot.slotId;

  /// Dialog stats için: kabinde anlık okunan TOPLAM etiket sayısı.
  /// Yerleştirilen yeni + baseline kabin stoğu + (kalıcı) UNEXPECTED.
  int get totalReadCount => rfidReadEpcs.length + passiveEpcs.length + unexpectedEpcs.length;

  /// Plan dışı hareket sayısı (banner sayacı).
  int get unplannedCount => unplannedMovements.length;

  /// Hâlâ kabinde olan UNEXPECTED tag sayısı — 0 değilse complete blokeli.
  int get unexpectedCount => unexpectedEpcs.length;

  /// Banner sayacı: işaretli RFID'li ilaç sayısı.
  int get rfidExpectedCount => _selectedRfidItems.length;

  /// İşaretli RFID'li ilaçların kaç tanesinin tag'i yerleştirilmiş.
  int get rfidReadCount => _selectedRfidItems.where((i) => rfidReadEpcs.contains(i.rfidTag)).length;

  /// Tüm seçili RFID'li ilaçların etiketleri yerleştirilmiş mi?
  /// RFID'li ilaç yoksa true (sadece RFID'siz item'lar varsa "tamamla"ya izin verir).
  bool get allSelectedRfidRead => rfidExpectedCount == 0 || rfidReadCount >= rfidExpectedCount;

  /// Tamamla butonu için kompozit kural (§5.1 Dolum):
  ///   1) Baseline scan tamamlanmış olmalı (snapshot anlamlı sonuç versin)
  ///   2) UNEXPECTED kümesi boş olmalı (kabine ait olmayan tag yok)
  ///   3) Fazladan yerleştirme yok olmalı (seçili item'a denk gelmeyen tag yok)
  ///   4) Tüm seçili RFID'li gözlere doğru tag yerleştirilmiş olmalı
  bool get canComplete {
    if (!baselineCompleted) return false;
    if (unexpectedEpcs.isNotEmpty) return false;
    if (extraPlacedEpcs.isNotEmpty) return false;
    return allSelectedRfidRead;
  }

  /// UI uyarısı için: kullanıcı bir UNEXPECTED tag'i çıkartana kadar bloke.
  /// Banner text: "Kabinde bu kabine ait olmayan N etiket var, lütfen çıkartın".
  bool get isBlockedByUnexpected => baselineCompleted && unexpectedEpcs.isNotEmpty;

  /// UI banner'ı için: plan dışı hareket var mı?
  bool get hasUnplannedMovement => unplannedMovements.isNotEmpty;

  /// Baseline sonrası kabine yerleştirilen ama seçili item'ların rfidTag'leriyle
  /// eşleşmeyen EPC'ler. Yani kullanıcı yanlışlıkla seçtiği ilaçların dışında
  /// bir etiket koymuş. Bu küme boş değilse complete blokeli — kullanıcı
  /// çekmeceyi tekrar açıp fazla tag'i çıkartmalı (lost olduğunda otomatik
  /// silinir, blokaj kalkar).
  Set<String> get extraPlacedEpcs {
    final selectedRfidTags = _selectedRfidItems.map((i) => i.rfidTag!).toSet();
    return rfidReadEpcs.difference(selectedRfidTags);
  }

  /// UI banner'ı için: fazladan yerleştirme var mı?
  bool get hasExtraPlacement => extraPlacedEpcs.isNotEmpty;

  /// RFID reconciliation kümelerinin tümünü sıfırlayan bir kopya.
  /// Reopen, cancel, drawer fail, complete success akışlarında kullanılır.
  /// Reçete, seçim ve sahne KORUNUR — sadece RFID bayrakları sıfırlanır.
  MobileRefillReady get clearedRfidState => copyWith(
    baselineCompleted: false,
    rfidReadEpcs: const {},
    notFoundEpcs: const {},
    passiveEpcs: const {},
    unexpectedEpcs: const {},
    unplannedMovements: const {},
    unexpectedLostEpcs: const {},
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

  MobileRefillReady copyWith({
    List<PrescriptionItem>? prescriptionItems,
    Set<int>? selectedItemIds,
    DateRangePreset? datePreset,
    PrescriptionMovementType? statusFilter,
    bool clearStatusFilter = false,
    bool? baselineCompleted,
    Set<String>? rfidReadEpcs,
    Set<String>? notFoundEpcs,
    Set<String>? passiveEpcs,
    Set<String>? unexpectedEpcs,
    Set<String>? unplannedMovements,
    Set<String>? unexpectedLostEpcs,
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
      rfidReadEpcs: rfidReadEpcs ?? this.rfidReadEpcs,
      notFoundEpcs: notFoundEpcs ?? this.notFoundEpcs,
      passiveEpcs: passiveEpcs ?? this.passiveEpcs,
      unexpectedEpcs: unexpectedEpcs ?? this.unexpectedEpcs,
      unplannedMovements: unplannedMovements ?? this.unplannedMovements,
      unexpectedLostEpcs: unexpectedLostEpcs ?? this.unexpectedLostEpcs,
      previouslyPlacedEpcs: previouslyPlacedEpcs ?? this.previouslyPlacedEpcs,
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
  const MobileRefillDrawerOpening({
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
  final MobileRefillReady ready;
}

/// completeRefill API çağrısı devam ediyor.
///
/// rfid-stock-notifications §7 — bu state'te yalnızca **kayıt API'si** çalışır,
/// bildirim API'leri DEĞİL. Bildirimler kayıt başarılı olduktan sonra arka
/// planda fire-and-forget gönderilir.
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
///
/// dismissSuccess() bu state'i Idle'a çevirir veya seçili göz için reçeteleri
/// yenileyerek Ready'e döner (yeni dolum yapılabilmesi için).
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

/// Kullanıcı hata aldıktan sonra "Vazgeç" ile işlemi iptal etti.
/// RFID state'i KORUNUR, böylece kullanıcı çıkardığı tag'ler
/// unplannedMovements olarak doğru şekilde kaydedilir.
///
/// Bu state'teyken:
///   - Drawer açık veya kapanmış olabilir
///   - Kullanıcı tag'leri çıkarırken event'ler çalışmaya devam eder
///   - Tüm tag'ler çıkınca işlem doğal olarak sonlanır
final class MobileRefillRollbackInProgress extends MobileRefillState {
  const MobileRefillRollbackInProgress({
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
  final MobileRefillReady ready;

  final DateTime? cancelledAt;

  int get selectedSlotId => selectedSlot.slotId;
  MobileCellCoord get selectedCell => ready.selectedCell;

  MobileRefillRollbackInProgress copyWith({MobileRefillReady? ready}) {
    return MobileRefillRollbackInProgress(
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
///   - Sistem güvenli bir şekilde [MobileRefillIdle] veya uygun sahneye döner.
final class MobileRefillRollbackCompleted extends MobileRefillState {
  const MobileRefillRollbackCompleted({
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
  const MobileRefillFatalError({required this.message, required this.previousState});

  final String message;
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
    MobileRefillDrawerOpening(:final slots) => slots,
    MobileRefillSaving(:final slots) => slots,
    MobileRefillSuccess(:final slots) => slots,
    MobileRefillError(:final previousState) => previousState.slots,
    MobileRefillUninitialized() => const [],
    MobileRefillRollbackInProgress(:final slots) => slots,
    MobileRefillRollbackCompleted(:final slots) => slots,
    MobileRefillFatalError(:final previousState) => previousState.slots,
  };

  List<MobileDrawerSlot> get mobileSlots => switch (this) {
    MobileRefillIdle(:final mobileSlots) => mobileSlots,
    MobileRefillLoading(:final mobileSlots) => mobileSlots ?? const [],
    MobileRefillSlotSelected(:final mobileSlots) => mobileSlots,
    MobileRefillNoPatient(:final mobileSlots) => mobileSlots,
    MobileRefillReady(:final mobileSlots) => mobileSlots,
    MobileRefillDrawerOpening(:final mobileSlots) => mobileSlots,
    MobileRefillSaving(:final mobileSlots) => mobileSlots,
    MobileRefillSuccess(:final mobileSlots) => mobileSlots,
    MobileRefillError(:final previousState) => previousState.mobileSlots,
    MobileRefillRollbackInProgress(:final mobileSlots) => mobileSlots,
    _ => const [],
  };

  List<BedAssignment> get assignments => switch (this) {
    MobileRefillIdle(:final assignments) => assignments,
    MobileRefillSlotSelected(:final assignments) => assignments,
    MobileRefillLoading(:final assignments) => assignments ?? const [],
    MobileRefillNoPatient(:final assignments) => assignments,
    MobileRefillReady(:final assignments) => assignments,
    MobileRefillDrawerOpening(:final assignments) => assignments,
    MobileRefillSaving(:final assignments) => assignments,
    MobileRefillSuccess(:final assignments) => assignments,
    MobileRefillError(:final previousState) => previousState.assignments,
    MobileRefillRollbackInProgress(:final assignments) => assignments,
    _ => const [],
  };

  int? get selectedSlotId => switch (this) {
    MobileRefillSlotSelected(:final selectedSlotId) => selectedSlotId,
    MobileRefillNoPatient(:final selectedSlotId) => selectedSlotId,
    MobileRefillReady(:final selectedSlotId) => selectedSlotId,
    MobileRefillDrawerOpening(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillSuccess(:final selectedSlot) => selectedSlot.slotId,
    MobileRefillError(:final previousState) => previousState.selectedSlotId,
    MobileRefillRollbackInProgress(:final selectedSlotId) => selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileRefillSlotSelected(:final selectedSlot) => selectedSlot,
    MobileRefillLoading(:final selectedSlot) => selectedSlot,
    MobileRefillNoPatient(:final selectedSlot) => selectedSlot,
    MobileRefillReady(:final selectedSlot) => selectedSlot,
    MobileRefillDrawerOpening(:final selectedSlot) => selectedSlot,
    MobileRefillSaving(:final selectedSlot) => selectedSlot,
    MobileRefillSuccess(:final selectedSlot) => selectedSlot,
    MobileRefillError(:final previousState) => previousState.selectedSlot,

    MobileRefillRollbackInProgress(:final selectedSlot) => selectedSlot,
    _ => null,
  };

  MobileCellCoord? get selectedCell => switch (this) {
    MobileRefillNoPatient(:final selectedCell) => selectedCell,
    MobileRefillReady(:final selectedCell) => selectedCell,
    MobileRefillError(:final previousState) => previousState.selectedCell,
    MobileRefillRollbackInProgress(:final selectedCell) => selectedCell,
    _ => null,
  };

  int get cabinId => switch (this) {
    MobileRefillLoading(:final cabinId) => cabinId,
    MobileRefillIdle(:final cabinId) => cabinId,
    MobileRefillSlotSelected(:final cabinId) => cabinId,
    MobileRefillNoPatient(:final cabinId) => cabinId,
    MobileRefillReady(:final cabinId) => cabinId,
    MobileRefillDrawerOpening(:final cabinId) => cabinId,
    MobileRefillSaving(:final cabinId) => cabinId,
    MobileRefillSuccess(:final cabinId) => cabinId,
    MobileRefillError(:final previousState) => previousState.cabinId,
    MobileRefillUninitialized() => 0,
    MobileRefillRollbackInProgress(:final cabinId) => cabinId,
    MobileRefillRollbackCompleted(:final cabinId) => cabinId,
    MobileRefillFatalError(:final cabinId) => cabinId,
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
    MobileRefillSuccess(:final ready) => ready,
    MobileRefillError(:final previousState) => previousState.readyContext,
    MobileRefillRollbackInProgress(:final ready) => ready,
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
    final hasReady = readyContext != null;
    final drawerActive = stage is MobileDrawerOpening || stage is MobileDrawerOpened || stage is MobileDrawerClosed;
    return hasReady && drawerActive;
  }
}
