// master_unload_state.dart
// [SWREQ-CLI-MUNLOAD-002] [IEC 62304 §5.5]
// Master kabin İLAÇ BOŞALTMA — 2 fazlı state hiyerarşisi (dolum/sayım
// iskeletinin birebir kopyası, master-cabin-operations §1).
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';

sealed class MasterUnloadState {
  const MasterUnloadState();
}

final class MasterUnloadUninitialized extends MasterUnloadState {
  const MasterUnloadUninitialized();
}

final class MasterUnloadLoading extends MasterUnloadState {
  const MasterUnloadLoading();
}

/// FAZ 1: dolumdaki gibi seçim BOŞ başlar — sayımın "hepsi seçili" davranışı
/// burada YOK, tüm kabini boşaltmak istisnai bir durum, varsayılan olmamalı.
final class MasterUnloadSelection extends MasterUnloadState {
  const MasterUnloadSelection({
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

  bool get canStart => selectedUnitIds.isNotEmpty;

  List<MedicineAssignment> get selectedAssignments =>
      medicines.where((a) => selectedUnitIds.contains(a.cabinDrawerId)).toList();

  MasterUnloadSelection copyWith({List<MedicineAssignment>? medicines, Set<int>? selectedUnitIds, String? search}) {
    return MasterUnloadSelection(
      cabinId: cabinId,
      medicines: medicines ?? this.medicines,
      selectedUnitIds: selectedUnitIds ?? this.selectedUnitIds,
      search: search ?? this.search,
    );
  }
}

final class MasterUnloadExecuting extends MasterUnloadState {
  const MasterUnloadExecuting({
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
  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  MasterUnloadExecuting copyWith({
    List<CabinOperationDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return MasterUnloadExecuting(
      cabinId: cabinId,
      jobs: jobs ?? this.jobs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTargetIndex: currentTargetIndex ?? this.currentTargetIndex,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class MasterUnloadError extends MasterUnloadState {
  const MasterUnloadError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterUnloadState previousState;
  final bool isQueueError;
}

extension MasterUnloadExecutingLocationX on MasterUnloadExecuting {
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
