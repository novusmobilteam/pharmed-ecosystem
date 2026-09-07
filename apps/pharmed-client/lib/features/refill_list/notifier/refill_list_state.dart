// notifier/refill_list_state.dart
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/hardware/hardware.dart';

sealed class RefillListState {
  const RefillListState();
}

final class RefillListUninitialized extends RefillListState {
  const RefillListUninitialized();
}

final class RefillListLoading extends RefillListState {
  const RefillListLoading();
}

final class RefillListSelection extends RefillListState {
  const RefillListSelection({
    required this.stationId,
    required this.lists,
    this.selectedList,
    this.rows = const [],
    this.selectedDrawerIds = const {}, // eskiden selectedRowIds
    this.search = '',
    this.isDetailLoading = false,
  });

  final int stationId;
  final List<RefillList> lists;
  final RefillList? selectedList;
  final List<RefillListDetail> rows;

  /// assignment.cabinDrawerId bazlı seçim — CabinAssignmentListView'in
  /// kendi seçim mekanizmasıyla BİREBİR aynı anahtar (bkz. ad-hoc refill).
  final Set<int> selectedDrawerIds;
  final String search;
  final bool isDetailLoading;

  List<RefillListDetail> get visibleRows {
    if (search.trim().isEmpty) return rows;
    final q = search.toLowerCase().trim();
    return rows.where((r) => (r.medicine?.name?.toLowerCase() ?? '').contains(q)).toList();
  }

  List<RefillListDetail> get selectedRows => rows
      .where(
        (r) => r.cabinAssignment?.cabinDrawerId != null && selectedDrawerIds.contains(r.cabinAssignment!.cabinDrawerId),
      )
      .toList();

  int get selectedCount => selectedDrawerIds.length;
  bool get canStart => selectedDrawerIds.isNotEmpty;

  RefillListSelection copyWith({
    List<RefillList>? lists,
    RefillList? selectedList,
    bool clearSelectedList = false,
    List<RefillListDetail>? rows,
    Set<int>? selectedDrawerIds,
    String? search,
    bool? isDetailLoading,
  }) {
    return RefillListSelection(
      stationId: stationId,
      lists: lists ?? this.lists,
      selectedList: clearSelectedList ? null : (selectedList ?? this.selectedList),
      rows: rows ?? this.rows,
      selectedDrawerIds: selectedDrawerIds ?? this.selectedDrawerIds,
      search: search ?? this.search,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }
}

final class RefillListExecuting extends RefillListState {
  const RefillListExecuting({
    required this.stationId,
    required this.fillingListId,
    required this.jobs,
    required this.currentIndex,
    this.currentTargetIndex = 0,
    this.isSaving = false,
    this.skippedCount = 0,
  });

  final int stationId;
  final int fillingListId;
  final List<CabinOperationDrawerJob> jobs;
  final int currentIndex;
  final int currentTargetIndex;
  final bool isSaving;
  final int skippedCount;

  CabinOperationDrawerJob? get currentJob =>
      (currentIndex >= 0 && currentIndex < jobs.length) ? jobs[currentIndex] : null;
  int? get currentCabinId => currentJob?.cabinId;

  CabinOperationTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (currentTargetIndex < 0 || currentTargetIndex >= job.targets.length) return null;
    return job.targets[currentTargetIndex];
  }

  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((j) => j.status == CabinOperationJobStatus.completed).length;
  double get progress => totalJobs == 0 ? 0 : completedJobs / totalJobs;

  RefillListExecuting copyWith({
    List<CabinOperationDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return RefillListExecuting(
      stationId: stationId,
      fillingListId: fillingListId,
      jobs: jobs ?? this.jobs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTargetIndex: currentTargetIndex ?? this.currentTargetIndex,
      isSaving: isSaving ?? this.isSaving,
      skippedCount: skippedCount,
    );
  }
}

final class RefillListError extends RefillListState {
  const RefillListError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final RefillListState previousState;
  final bool isQueueError;
}

extension RefillListExecutingLocationX on RefillListExecuting {
  List<DrawerQueueItem> toLocationItems(Map<int, CabinVisualizerData> cabinDataByCabinId) {
    final cabinId = currentCabinId;
    final groups = cabinId != null ? cabinDataByCabinId[cabinId]?.groups ?? const [] : const <DrawerGroup>[];
    return buildCabinExecutionLocationItems(
      allGroups: groups,
      jobs: jobs,
      currentIndex: currentIndex,
      currentTargetIndex: currentTargetIndex,
      cabinDrawerIdOf: (job) => job.cabinDrawerId,
      statusOf: (job) => job.status,
      targetCountOf: (job) => job.targets.length,
      assignmentAt: (job, i) => job.targets[i].assignment,
    );
  }
}
