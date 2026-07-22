// [SWREQ-CLI-MCENSUS-001] [IEC 62304 §5.5]
// Sayım (census) akışının tam state hiyerarşisi — MasterRefillState ile
// birebir aynı desende (Uninitialized → Loading → Selection → Executing,
// hata her zaman previousState taşıyan bir sarmalayıcı).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';

sealed class MasterCensusState {
  const MasterCensusState();
}

final class MasterCensusUninitialized extends MasterCensusState {
  const MasterCensusUninitialized();
}

final class MasterCensusLoading extends MasterCensusState {
  const MasterCensusLoading();
}

// ── FAZ 1: Seçim ──────────────────────────────────────────────────────────────

final class MasterCensusSelection extends MasterCensusState {
  const MasterCensusSelection({
    required this.cabinId,
    required this.medicines,
    required this.selectedUnitIds,
    this.search = '',
  });

  final int cabinId;

  /// NOT: allGroups burada YOK — refill'deki gibi, CabinVisualizerData.groups
  /// View'dan (widget.data.groups) doğrudan panel'e geçiriliyor, state
  /// taşımıyor. Böylece kuyruk bitince reload'da groups kaybolma riski de
  /// hiç oluşmuyor (widget.data ekran açıkken sabit kalıyor).
  final List<MedicineAssignment> medicines;

  /// Sayım için seçilen unit id'leri (cabinDrawerId). Varsayılan: hepsi
  /// seçili (init() sırasında hesaplanır) — refill'in aksine, sayımda
  /// "hiç seçim yapmadan devam" tüm kabini saymak anlamına geliyor.
  final Set<int> selectedUnitIds;

  final String search;

  List<MedicineAssignment> get visibleMedicines {
    if (search.trim().isEmpty) return medicines;
    final q = search.toLowerCase().trim();
    return medicines.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  int get selectedCount => selectedUnitIds.length;
  bool get canStart => selectedUnitIds.isNotEmpty;

  List<MedicineAssignment> get selectedAssignments =>
      medicines.where((a) => selectedUnitIds.contains(a.cabinDrawerId)).toList();

  MasterCensusSelection copyWith({List<MedicineAssignment>? medicines, Set<int>? selectedUnitIds, String? search}) {
    return MasterCensusSelection(
      cabinId: cabinId,
      medicines: medicines ?? this.medicines,
      selectedUnitIds: selectedUnitIds ?? this.selectedUnitIds,
      search: search ?? this.search,
    );
  }
}

// ── FAZ 2: Yürütme ──────────────────────────────────────────────────────────────

final class MasterCensusExecuting extends MasterCensusState {
  const MasterCensusExecuting({
    required this.cabinId,
    required this.jobs,
    required this.currentIndex,
    this.currentTargetIndex = 0,
    this.isSaving = false,
  });

  final int cabinId;
  final List<CensusDrawerJob> jobs;
  final int currentIndex;
  final int currentTargetIndex;
  final bool isSaving;

  CensusDrawerJob? get currentJob => (currentIndex >= 0 && currentIndex < jobs.length) ? jobs[currentIndex] : null;

  CensusTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (currentTargetIndex < 0 || currentTargetIndex >= job.targets.length) return null;
    return job.targets[currentTargetIndex];
  }

  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((j) => j.status == CensusJobStatus.completed).length;
  bool get isQueueFinished => currentIndex >= jobs.length;
  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  MasterCensusExecuting copyWith({
    List<CensusDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return MasterCensusExecuting(
      cabinId: cabinId,
      jobs: jobs ?? this.jobs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTargetIndex: currentTargetIndex ?? this.currentTargetIndex,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// ── Hata ────────────────────────────────────────────────────────────────────

final class MasterCensusError extends MasterCensusState {
  const MasterCensusError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterCensusState previousState;
  final bool isQueueError;
}

extension MasterCensusExecutingLocationX on MasterCensusExecuting {
  /// [allGroups] → CabinVisualizerData.groups (tüm kabin çekmeceleri).
  /// MasterRefillExecutingLocationX.toLocationItems ile birebir aynı mantık.
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) {
    final jobBySlotId = <int, (int index, CensusDrawerJob job)>{};
    for (int i = 0; i < jobs.length; i++) {
      // job.cabinDrawerId zaten CensusQueueBuilder'da doğru fiziksel id
      // olarak (drawerSlot.id öncelikli) hesaplandı — representativeAssignment
      // üzerinden tekrar (bazen null gelen) drawerSlotId'ye düşmeye gerek yok.
      jobBySlotId[jobs[i].cabinDrawerId] = (i, jobs[i]);
    }

    return allGroups.map((group) {
      final slotId = group.slot.id;
      final entry = slotId != null ? jobBySlotId[slotId] : null;

      if (entry == null) {
        return DrawerQueueItem(group: group, status: DrawerQueueStatus.notInQueue);
      }

      final (jobIndex, job) = entry;
      final isActive = jobIndex == currentIndex;

      final status = switch (job.status) {
        CensusJobStatus.completed => DrawerQueueStatus.completed,
        CensusJobStatus.failed => DrawerQueueStatus.failed,
        CensusJobStatus.active => DrawerQueueStatus.active,
        CensusJobStatus.pending => isActive ? DrawerQueueStatus.active : DrawerQueueStatus.pending,
      };

      final completedIndexes = <int>{};
      if (isActive && job.isKubik) {
        for (int t = 0; t < currentTargetIndex; t++) {
          completedIndexes.add(t);
        }
      }

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
