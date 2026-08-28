import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';

sealed class MasterRefillState {
  const MasterRefillState();
}

final class MasterRefillUninitialized extends MasterRefillState {
  const MasterRefillUninitialized();
}

final class MasterRefillLoading extends MasterRefillState {
  const MasterRefillLoading();
}

final class MasterRefillSelection extends MasterRefillState {
  const MasterRefillSelection({
    required this.cabinId,
    required this.medicines,
    this.selectedUnitIds = const {},
    this.search = '',
  });

  final int cabinId;
  final List<MedicineAssignment> medicines;
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

  MasterRefillSelection copyWith({List<MedicineAssignment>? medicines, Set<int>? selectedUnitIds, String? search}) {
    return MasterRefillSelection(
      cabinId: cabinId,
      medicines: medicines ?? this.medicines,
      selectedUnitIds: selectedUnitIds ?? this.selectedUnitIds,
      search: search ?? this.search,
    );
  }
}

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
  final List<CabinOperationDrawerJob> jobs;

  final int currentIndex;

  /// Kübik job içinde aktif göz/lid index'i. Birim doz/standart çekmecede
  /// her zaman 0.
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

  MasterRefillExecuting copyWith({
    List<CabinOperationDrawerJob>? jobs,
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

final class MasterRefillError extends MasterRefillState {
  const MasterRefillError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterRefillState previousState;
  final bool isQueueError;
}

extension MasterRefillExecutingLocationX on MasterRefillExecuting {
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
