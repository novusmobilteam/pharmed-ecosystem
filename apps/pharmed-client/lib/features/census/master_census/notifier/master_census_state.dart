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

// ── FAZ 1: Seçim ──────────────────────────────────────────────────────────

final class MasterCensusSelection extends MasterCensusState {
  const MasterCensusSelection({
    required this.cabinId,
    required this.medicines,
    required this.selectedUnitIds,
    this.search = '',
  });

  final int cabinId;
  final List<MedicineAssignment> medicines;

  /// Varsayılan: hepsi seçili (init() sırasında hesaplanır) — "hiç seçim
  /// yapmadan devam" tüm kabini saymak anlamına gelir.
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

// ── FAZ 2: Yürütme ──────────────────────────────────────────────────────────

final class MasterCensusExecuting extends MasterCensusState {
  const MasterCensusExecuting({
    required this.cabinId,
    required this.jobs,
    required this.currentIndex,
    this.currentTargetIndex = 0,
    this.isSaving = false,
  });

  final int cabinId;
  final List<CabinOperationDrawerJob> jobs;
  final int currentIndex;
  final int currentTargetIndex;
  final bool isSaving;

  CabinOperationDrawerJob? get currentJob =>
      (currentIndex >= 0 && currentIndex < jobs.length) ? jobs[currentIndex] : null;

  CabinOperationTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (currentTargetIndex < 0 || currentTargetIndex >= job.targets.length) return null;
    return job.targets[currentTargetIndex];
  }

  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;
  bool get isQueueFinished => currentIndex >= jobs.length;
  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  MasterCensusExecuting copyWith({
    List<CabinOperationDrawerJob>? jobs,
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

// ── Hata ──────────────────────────────────────────────────────────────────

final class MasterCensusError extends MasterCensusState {
  const MasterCensusError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterCensusState previousState;
  final bool isQueueError;
}

extension MasterCensusExecutingLocationX on MasterCensusExecuting {
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => buildCabinExecutionLocationItems(
    allGroups: allGroups,
    jobs: jobs,
    currentIndex: currentIndex,
    currentTargetIndex: currentTargetIndex,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    statusOf: (job) => job.status,
    targetCountOf: (job) => job.targets.length,
    assignmentAt: (job, i) => job.targets[i].assignment,
  );
}
