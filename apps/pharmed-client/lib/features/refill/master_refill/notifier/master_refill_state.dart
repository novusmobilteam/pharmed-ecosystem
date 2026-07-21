// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// İlaç-merkezli master kabin dolum ekranının state hiyerarşisi.
//
// Akış iki faza ayrılır:
//   FAZ 1 — Selection: kabine atanmış ilaç listesi, çoklu ilaç seçimi,
//           her ilaç için hangi gözlere dolum yapılacağının seçimi.
//   FAZ 2 — Executing: seçimlerden üretilen çekmece kuyruğu sırayla işlenir.
//           Her adımda tek fiziksel çekmece açılır, gözleri doldurulur.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';

sealed class MasterRefillState {
  const MasterRefillState();
}

/// Henüz init edilmedi (CabinVisualizerData yok).
final class MasterRefillUninitialized extends MasterRefillState {
  const MasterRefillUninitialized();
}

/// Atanmış ilaçlar yükleniyor.
final class MasterRefillLoading extends MasterRefillState {
  const MasterRefillLoading();
}

// ── FAZ 1: Seçim ──────────────────────────────────────────────────────────────

/// İlaç listesi gösteriliyor, kullanıcı seçim yapıyor.
final class MasterRefillSelection extends MasterRefillState {
  const MasterRefillSelection({
    required this.cabinId,
    required this.medicines,
    this.selectedUnitIds = const {},
    this.search = '',
  });

  final int cabinId;

  /// Kabine atanmış tüm ilaç atamaları (her göz ayrı bir MedicineAssignment).
  final List<MedicineAssignment> medicines;

  /// Dolum için seçilen göz id'leri (cabinDrawerId). Bir ilaç birden çok göze
  /// atanmışsa her göz ayrı id taşır; kullanıcı tek tek seçer/çıkarır.
  final Set<int> selectedUnitIds;

  /// Arama metni (ilaç adı / barkod filtresi).
  final String search;

  /// Filtrelenmiş liste (görünür ilaçlar).
  List<MedicineAssignment> get visibleMedicines {
    if (search.trim().isEmpty) return medicines;
    final q = search.toLowerCase().trim();
    return medicines.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  /// Seçilen göz sayısı.
  int get selectedCount => selectedUnitIds.length;

  /// En az bir göz seçili mi? (Başlat butonu için)
  bool get canStart => selectedUnitIds.isNotEmpty;

  /// Seçilen atamalar.
  List<MedicineAssignment> get selectedAssignments =>
      medicines.where((a) => selectedUnitIds.contains(a.cabinDrawerId)).toList();

  MasterRefillSelection copyWith({List<MedicineAssignment>? medicines, Set<int>? selectedUnitIds, String? search}) {
    return MasterRefillSelection(
      cabinId: cabinId,
      medicines: medicines ?? this.medicines,
      selectedUnitIds: selectedUnitIds ?? this.selectedUnitIds,
      search: search ?? this.search,
    );
  }
}

// ── FAZ 2: Yürütme ──────────────────────────────────────────────────────────────

/// Otomatik dolum kuyruğu işleniyor.
final class MasterRefillExecuting extends MasterRefillState {
  const MasterRefillExecuting({
    required this.cabinId,
    required this.jobs,
    required this.currentIndex,
    this.currentTargetIndex = 0,
    this.isSaving = false,
  });

  final int cabinId;

  /// Çekmece kuyruğu (fiziksel çekmece bazlı, sıralı).
  final List<RefillDrawerJob> jobs;

  /// Şu an işlenen job'ın index'i.
  final int currentIndex;

  /// Kübik job içinde aktif göz/lid index'i (lid-by-lid alt-kuyruk).
  /// Birim doz/standart çekmecede her zaman 0 (tüm gözler tek formda).
  final int currentTargetIndex;

  /// Aktif job'ın kaydı sürüyor mu?
  final bool isSaving;

  // ── Türetilen ──────────────────────────────────────────────────────────

  RefillDrawerJob? get currentJob => (currentIndex >= 0 && currentIndex < jobs.length) ? jobs[currentIndex] : null;

  /// Kübik akışta o an açık olan gözün hedefi.
  RefillFillTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (currentTargetIndex < 0 || currentTargetIndex >= job.targets.length) return null;
    return job.targets[currentTargetIndex];
  }

  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((j) => j.status == RefillJobStatus.completed).length;

  /// Kuyruğun tamamı bitti mi?
  bool get isQueueFinished => currentIndex >= jobs.length;

  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  MasterRefillExecuting copyWith({
    List<RefillDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return MasterRefillExecuting(
      cabinId: cabinId,
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
/// [isQueueError] true ise hata aktif bir kuyruk işlemi sırasında (dolum kaydı
/// veya çekmece) oluşmuştur; kullanıcıya "ilaçları alın" yönlendirmesiyle
/// devam/sonlandır seçeneği sunulur.
final class MasterRefillError extends MasterRefillState {
  const MasterRefillError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterRefillState previousState;
  final bool isQueueError;
}

extension MasterRefillExecutingLocationX on MasterRefillExecuting {
  /// [allGroups] → CabinVisualizerData.groups (tüm kabin çekmeceleri)
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) {
    // Job'ları slotId → job index ile hızlı erişim için index'le.
    final jobBySlotId = <int, (int index, RefillDrawerJob job)>{};
    for (int i = 0; i < jobs.length; i++) {
      final slotId = jobs[i].representativeAssignment.drawerUnit?.drawerSlotId;
      if (slotId != null) jobBySlotId[slotId] = (i, jobs[i]);
    }

    return allGroups.map((group) {
      final slotId = group.slot.id;
      final entry = slotId != null ? jobBySlotId[slotId] : null;

      if (entry == null) {
        // Bu çekmece kuyruğa girmedi.
        return DrawerQueueItem(group: group, status: DrawerQueueStatus.notInQueue);
      }

      final (jobIndex, job) = entry;
      final isActive = jobIndex == currentIndex;

      final status = switch (job.status) {
        RefillJobStatus.completed => DrawerQueueStatus.completed,
        RefillJobStatus.failed => DrawerQueueStatus.failed,
        RefillJobStatus.active => DrawerQueueStatus.active,
        RefillJobStatus.pending => isActive ? DrawerQueueStatus.active : DrawerQueueStatus.pending,
      };

      // Kübik: currentTargetIndex öncesindeki lid'ler tamamlandı.
      final completedIndexes = <int>{};
      if (isActive && job.isKubik) {
        for (int t = 0; t < currentTargetIndex; t++) {
          completedIndexes.add(t);
        }
      }

      // Birim doz: hedef unit index'lerini job'daki target assignment'larından türet.
      // Her target'ın drawerUnit'i group.units içindeki index'iyle eşleştirilir.
      final activeUnitIndexes = <int>{};
      if (!job.isKubik && isActive) {
        for (final target in job.targets) {
          final unitId = target.assignment.drawerUnit?.id;
          if (unitId == null) continue;
          final idx = group.units.indexWhere((u) => u.id == unitId);
          if (idx >= 0) activeUnitIndexes.add(idx);
        }
      }

      return DrawerQueueItem(
        group: group,
        status: status,
        activeTargetIndex: isActive && job.isKubik ? currentTargetIndex : null,
        completedTargetIndexes: completedIndexes,
        activeUnitIndexes: activeUnitIndexes,
      );
    }).toList();
  }
}
