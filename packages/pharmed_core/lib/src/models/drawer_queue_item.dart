// [SWREQ-CORE-DRAWERQUEUE-001] [IEC 62304 §5.5]
// Kabin konum rehberi widget'ının kullandığı ekrandan bağımsız kuyruk öğesi.
//
// Her ekran (dolum, alım, sayım, iade, imha) kendi job modelinden
// [DrawerQueueItem] listesi üretir; [CabinLocationGuide] yalnızca bu modeli bilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

/// Kuyruk öğesinin görsel durumu.
enum DrawerQueueStatus {
  /// Henüz işlenmedi (bu işlemde seçildi, sıra gelmedi).
  pending,

  /// Şu an işleniyor (çekmece açık veya açılıyor).
  active,

  /// Tamamlandı.
  completed,

  /// Hata ile sonuçlandı.
  failed,

  /// Bu işleme dahil değil (seçilmedi / kuyruğa girmedi).
  notInQueue,
}

/// Kabin konum rehberinde gösterilecek tek bir çekmece öğesi.
///
/// [group]  → Fiziksel çekmece yapısı (adres, tip, unit listesi).
/// [status] → Kuyruktaki görsel durum.
///
/// Kübik çekmece için ek alanlar:
///   [activeTargetIndex]       → O an açık lid'in index'i (0-tabanlı).
///   [completedTargetIndexes]  → Tamamlanan lid index'leri (0-tabanlı).
///
/// Birim doz çekmece için ek alan:
///   [activeUnitIndexes] → Dolum yapılacak bölme index'leri (0-tabanlı).
///   Boşsa tüm bölmeler eşit gösterilir (serbest dolum).
class DrawerQueueItem {
  const DrawerQueueItem({
    required this.group,
    required this.status,
    this.activeTargetIndex,
    this.completedTargetIndexes = const {},
    this.activeUnitIndexes = const {},
    this.activeStepNo,
    this.completedCells = const {},
    this.isReturnDrawerTarget = false,
  });

  final DrawerGroup group;
  final DrawerQueueStatus status;

  /// Kübik: aktif lid index'i. Birim doz ve notInQueue'da null.
  final int? activeTargetIndex;

  /// Kübik: tamamlanan lid index'leri. Birim doz'da boş.
  final Set<int> completedTargetIndexes;

  /// Birim doz: bu işlemde hedef olan bölme index'leri (0-tabanlı, units listesine göre).
  /// Boş set → tüm bölmeler eşit (serbest dolum).
  final Set<int> activeUnitIndexes;

  /// Birim doz: aktif hedefin DERİNLİK (step) numarası — 1-tabanlı,
  /// DrawerCell.stepNo ile birebir. stockIdAt sağlanmayan ekranlarda null
  /// kalır (fallback: tüm sütun aktif gösterilir).
  final int? activeStepNo;

  /// Birim doz: (ön göz index'i, step numarası) çiftleri — tamamlanan
  /// hücrelerin TAM konumu. Boşsa fallback (tüm sütun) kullanılır.
  final Set<(int unitIndex, int stepNo)> completedCells;

  /// true SADECE bu job'un GERÇEK hedefi iade kutusuysa (ReturnType.toDrawer).
  /// group.isReturnDrawer'dan (fiziksel çekmecenin işaretinden) BAĞIMSIZ —
  /// aynı fiziksel iade çekmecesinde toOrigin ile normal bir göze iade
  /// yapılıyorsa bu false kalmalı, aksi halde konum rehberi yanlışlıkla
  /// birleşik İADE kutusunu aktif gösterir.
  final bool isReturnDrawerTarget;

  // ── Türetilen ─────────────────────────────────────────────────────────────

  bool get isKubik => group.isKubik;
  bool get isInQueue => status != DrawerQueueStatus.notInQueue;
  String get address => group.slot.address ?? '?';
  List<DrawerUnit> get units => group.units;
  int get numberOfSteps => group.slot.drawerConfig?.numberOfSteps ?? 0;
}

// [SWREQ-CORE-CABINOP-013] [IEC 62304 §5.5]
//
// Executing state'lerin ortak "konum rehberi" hesaplayıcısı. Dolum/sayım/
// boşaltma/alım/iade'nin toLocationItems'ı birebir aynı mantığı taşıyordu —
// tek fark job/target tipleriydi. Kübik/birim-doz FARKI YOK — ikisi de artık
// aynı sıralı akışla ilerliyor (tek tek hedef aç → işle → kapat, bkz.
// notifier'lardaki confirmCurrent). Bu fonksiyon hiçbir ekrana özel tip
// bilmez, sadece çağıranın verdiği erişimci closure'ları kullanır.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

List<DrawerQueueItem> buildCabinExecutionLocationItems<TJob>({
  required List<DrawerGroup> allGroups,
  required List<TJob> jobs,
  required int currentIndex,
  required int currentTargetIndex,
  required int Function(TJob job) cabinDrawerIdOf,
  required CabinOperationJobStatus Function(TJob job) statusOf,
  required int Function(TJob job) targetCountOf,
  required MedicineAssignment? Function(TJob job, int targetIndex) assignmentAt,

  /// YENİ, opsiyonel. Verilirse derinlik (step) bazlı hassas grid hesaplanır
  /// — verilmezse eski davranış (sütun bazlı, step'siz) korunur, hiçbir
  /// çağıran kırılmaz.
  int? Function(TJob job, int targetIndex)? stockIdAt,

  /// YENİ, opsiyonel. Sadece iade gibi "aynı fiziksel çekmece hem normal
  /// göz hem birleşik kutu hedefi olabiliyor" ekranlarda verilir.
  bool Function(TJob job)? isReturnDrawerTargetOf,
}) {
  final jobBySlotId = <int, (int index, TJob job)>{};
  for (int i = 0; i < jobs.length; i++) {
    jobBySlotId[cabinDrawerIdOf(jobs[i])] = (i, jobs[i]);
  }

  int? stepNoFor(TJob job, int targetIndex) {
    if (stockIdAt == null) return null;
    final stockId = stockIdAt(job, targetIndex);
    if (stockId == null) return null;
    final assignment = assignmentAt(job, targetIndex);
    final stock = assignment?.stocks?.firstWhereOrNull((s) => s.id == stockId);
    return stock?.cabinDrawerDetail?.stepNo;
  }

  return allGroups.map((group) {
    final slotId = group.slot.id;
    final entry = slotId != null ? jobBySlotId[slotId] : null;

    if (entry == null) {
      return DrawerQueueItem(group: group, status: DrawerQueueStatus.notInQueue);
    }

    final (jobIndex, job) = entry;
    final isActive = jobIndex == currentIndex;

    final status = switch (statusOf(job)) {
      CabinOperationJobStatus.completed => DrawerQueueStatus.completed,
      CabinOperationJobStatus.failed => DrawerQueueStatus.failed,
      CabinOperationJobStatus.active => DrawerQueueStatus.active,
      CabinOperationJobStatus.pending => isActive ? DrawerQueueStatus.active : DrawerQueueStatus.pending,
    };

    final completedIndexes = <int>{};
    final completedCells = <(int, int)>{};
    int? activeUnitIndex;
    int? activeStepNo;

    if (isActive) {
      for (int t = 0; t < currentTargetIndex; t++) {
        final unitId = assignmentAt(job, t)?.drawerUnit?.id;
        if (unitId == null) continue;
        final idx = group.units.indexWhere((u) => u.id == unitId);
        if (idx < 0) continue;
        completedIndexes.add(idx);
        final step = stepNoFor(job, t);
        if (step != null) completedCells.add((idx, step));
      }
      final targetCount = targetCountOf(job);
      if (currentTargetIndex >= 0 && currentTargetIndex < targetCount) {
        final activeId = assignmentAt(job, currentTargetIndex)?.drawerUnit?.id;
        if (activeId != null) {
          final idx = group.units.indexWhere((u) => u.id == activeId);
          if (idx >= 0) {
            activeUnitIndex = idx;
            activeStepNo = stepNoFor(job, currentTargetIndex);
          }
        }
      }
    }

    return DrawerQueueItem(
      group: group,
      status: status,
      activeTargetIndex: isActive ? activeUnitIndex : null,
      completedTargetIndexes: completedIndexes,
      activeUnitIndexes: const {},
      activeStepNo: isActive ? activeStepNo : null,
      completedCells: completedCells,
      isReturnDrawerTarget: isReturnDrawerTargetOf?.call(job) ?? false,
    );
  }).toList();
}
