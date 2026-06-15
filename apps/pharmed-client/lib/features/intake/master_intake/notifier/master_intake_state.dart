// [SWREQ-CLI-MINTAKE-001] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının state hiyerarşisi.
//
// Master dolumdaki MasterRefillState'in alım karşılığıdır. Hasta seçimi artık
// ekran ÖNÜNDEKİ bir modal/gateway ile değil, SOL PANELDE (OperationPanelBase)
// yapılır. Bu yüzden faz akışı:
//   FAZ 0 — NoPatient: hasta seçim listesi (PatientSelectionNotifier'a bağlı).
//           Hasta seçilince selectPatient → Selection.
//   FAZ 1 — Selection: alım item listesi (GetIntakeItemsUseCase), çoklu seçim,
//           her item için doz (dosePiece) ve gerekiyorsa şahit (witness).
//   FAZ 2 — Executing: toplu CheckIntake sonrası üretilen çekmece kuyruğu
//           sırayla işlenir; her çekmece açıkken CountType'a göre sayım yapılır.
//
// Hasta bağlamı (hospitalization + intakeType) Selection ve Executing içinde
// taşınır; "Hastayı değiştir" → NoPatient'a dönülür.
//
// Dolumdan farkları:
//   - Hasta seçim fazı (NoPatient) var.
//   - Selection'da doz stepper + şahit alanları var (dolumda yok).
//   - startIntake → önce toplu check (CheckIntakeUseCase) → kuyruk kurulur.
//     Check loading'i Selection.isChecking ile gösterilir (ayrı state yok;
//     böylece panel görünümü korunur).
//   - Executing'de "dolum" yerine "sayım" (censusQuantity) girilir.
//
// Sınıf: Class B

import 'package:pharmed_client/features/intake/intake.dart';
import 'package:pharmed_core/pharmed_core.dart';

sealed class MasterIntakeState {
  const MasterIntakeState();
}

/// Henüz init edilmedi (CabinVisualizerData yok).
final class MasterIntakeUninitialized extends MasterIntakeState {
  const MasterIntakeUninitialized();
}

/// Genel yükleme (istasyon çözümü, hasta seçimi sonrası item yükleme vb.).
final class MasterIntakeLoading extends MasterIntakeState {
  const MasterIntakeLoading();
}

// ── FAZ 0: Hasta seçimi ─────────────────────────────────────────────────────────

/// Henüz hasta seçilmedi — sol panelde hasta seçim listesi gösterilir.
///
/// Hasta listesi/filtre/arama durumu burada DEĞİL, ayrı
/// [PatientSelectionNotifier]'da yaşar. Bu state yalnızca "hasta seçilmemiş"
/// fazını temsil eder; panel o notifier'ı izleyerek listeyi çizer.
final class MasterIntakeNoPatient extends MasterIntakeState {
  const MasterIntakeNoPatient({required this.cabinId});

  final int cabinId;
}

// ── FAZ 1: Seçim ──────────────────────────────────────────────────────────────

/// İlaç listesi gösteriliyor; kullanıcı seçim + doz + şahit yapıyor.
final class MasterIntakeSelection extends MasterIntakeState {
  const MasterIntakeSelection({
    required this.cabinId,
    required this.hospitalization,
    required this.intakeType,
    required this.items,
    this.selectedItemIds = const {},
    this.search = '',
    this.checkStatuses = const {},
    this.isChecking = false,
  });

  final int cabinId;

  /// Seçilen hasta (yatış). Orderless/urgent akışta da taşınır.
  final Hospitalization hospitalization;

  /// Bu alımın tipi (hasta seçim modundan türetilir).
  final IntakeType intakeType;

  /// Alım için aday tüm kalemler (GetIntakeItemsUseCase, medicine bazlı gruplu).
  final List<IntakeItem> items;

  /// Seçilen kalem id'leri.
  final Set<int> selectedItemIds;

  /// Arama metni (ilaç adı / barkod filtresi).
  final String search;

  /// Item bazlı check durumu (idle/loading/success/failed) — kart üstü gösterim.
  final Map<int, IntakeCheckStatus> checkStatuses;

  /// Toplu check sürüyor mu? (Başlat butonu loading + seçim kilidi)
  final bool isChecking;

  /// İşlem öznesi hasta — aktif hasta kartı için.
  Patient? get patient => hospitalization.patient;

  /// Filtrelenmiş liste (görünür ilaçlar).
  List<IntakeItem> get visibleItems {
    if (search.trim().isEmpty) return items;
    final q = search.toLowerCase().trim();
    return items.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  int get selectedCount => selectedItemIds.length;

  bool get canStart => selectedItemIds.isNotEmpty && !isChecking;

  List<IntakeItem> get selectedItems => items.where((a) => selectedItemIds.contains(a.id)).toList();

  MasterIntakeSelection copyWith({
    List<IntakeItem>? items,
    Set<int>? selectedItemIds,
    String? search,
    Map<int, IntakeCheckStatus>? checkStatuses,
    bool? isChecking,
  }) {
    return MasterIntakeSelection(
      cabinId: cabinId,
      hospitalization: hospitalization,
      intakeType: intakeType,
      items: items ?? this.items,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      search: search ?? this.search,
      checkStatuses: checkStatuses ?? this.checkStatuses,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

// ── FAZ 2: Yürütme ──────────────────────────────────────────────────────────────

/// Alım kuyruğu işleniyor (sırayla çekmece açılır, sayım yapılır).
final class MasterIntakeExecuting extends MasterIntakeState {
  const MasterIntakeExecuting({
    required this.cabinId,
    required this.hospitalization,
    required this.intakeType,
    required this.jobs,
    required this.currentIndex,
    this.currentTargetIndex = 0,
    this.isSaving = false,
  });

  final int cabinId;
  final Hospitalization hospitalization;
  final IntakeType intakeType;

  /// Çekmece kuyruğu (fiziksel çekmece bazlı, sıralı).
  final List<IntakeDrawerJob> jobs;

  /// Şu an işlenen job'ın index'i.
  final int currentIndex;

  /// Kübik job içinde aktif göz/lid index'i (lid-by-lid alt-kuyruk).
  /// Birim doz/standart çekmecede her zaman 0.
  final int currentTargetIndex;

  /// Aktif kaydın (CompleteIntake) işlemi sürüyor mu?
  final bool isSaving;

  Patient? get patient => hospitalization.patient;

  // ── Türetilen ──────────────────────────────────────────────────────────

  IntakeDrawerJob? get currentJob => (currentIndex >= 0 && currentIndex < jobs.length) ? jobs[currentIndex] : null;

  /// Kübik akışta o an açık olan gözün hedefi.
  IntakeTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (currentTargetIndex < 0 || currentTargetIndex >= job.targets.length) return null;
    return job.targets[currentTargetIndex];
  }

  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((j) => j.status == RefillJobStatus.completed).length;

  bool get isQueueFinished => currentIndex >= jobs.length;

  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  MasterIntakeExecuting copyWith({
    List<IntakeDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return MasterIntakeExecuting(
      cabinId: cabinId,
      hospitalization: hospitalization,
      intakeType: intakeType,
      jobs: jobs ?? this.jobs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTargetIndex: currentTargetIndex ?? this.currentTargetIndex,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// ── Hata ────────────────────────────────────────────────────────────────────

/// Hata — önceki state'e dönmek için previousState taşınır.
///
/// [isQueueError] true ise hata aktif kuyruk işlemi sırasında (alım kaydı veya
/// çekmece) oluşmuştur; kullanıcıya "ilaçları geri bırakın" yönlendirmesiyle
/// devam/sonlandır seçeneği sunulur.
final class MasterIntakeError extends MasterIntakeState {
  const MasterIntakeError({required this.message, required this.previousState, this.isQueueError = false});

  final String message;
  final MasterIntakeState previousState;
  final bool isQueueError;
}

// ── Ortak erişim ────────────────────────────────────────────────────────────

extension MasterIntakeStateX on MasterIntakeState {
  /// Hasta bağlamı taşıyan tüm state'lerden cabinId.
  int get cabinId => switch (this) {
    MasterIntakeNoPatient(:final cabinId) => cabinId,
    MasterIntakeSelection(:final cabinId) => cabinId,
    MasterIntakeExecuting(:final cabinId) => cabinId,
    MasterIntakeError(:final previousState) => previousState.cabinId,
    _ => 0,
  };

  /// Seçili hasta (varsa). NoPatient / Loading / Uninitialized'da null.
  Hospitalization? get hospitalization => switch (this) {
    MasterIntakeSelection(:final hospitalization) => hospitalization,
    MasterIntakeExecuting(:final hospitalization) => hospitalization,
    MasterIntakeError(:final previousState) => previousState.hospitalization,
    _ => null,
  };

  IntakeType? get intakeType => switch (this) {
    MasterIntakeSelection(:final intakeType) => intakeType,
    MasterIntakeExecuting(:final intakeType) => intakeType,
    MasterIntakeError(:final previousState) => previousState.intakeType,
    _ => null,
  };
}
