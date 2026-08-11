// features/unload_drawer/notifier/unload_drawer_state.dart
//
// İade Kutusu Boşaltma ekranının state hiyerarşisi. Refund'dan farklı olarak
// hasta seçimi ve queue builder YOK — tek cabin, iki mod arasında segmented
// button ile geçiş: drawer (donanımlı, tek adım) / box (donanımsız, seçimli).
// Mobilde karşılığı olmadığı için "Master" öneki kullanılmıyor.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import '../../../../core/hardware/hardware.dart';

enum UnloadDrawerMode { drawer, box }

sealed class UnloadDrawerState {
  const UnloadDrawerState();
}

final class UnloadDrawerUninitialized extends UnloadDrawerState {
  const UnloadDrawerUninitialized();
}

final class UnloadDrawerLoading extends UnloadDrawerState {
  const UnloadDrawerLoading({required this.mode});
  final UnloadDrawerMode mode;
}

final class UnloadDrawerSelection extends UnloadDrawerState {
  const UnloadDrawerSelection({
    required this.cabinId,
    required this.mode,
    required this.items,
    this.selectedIds = const {},
    this.isSubmitting = false,
  });

  final int cabinId;
  final UnloadDrawerMode mode;
  final List<ReturnDrawerMedicine> items;

  /// Artık HER iki modda da anlamlı — hem drawer hem box tarafında
  /// kullanıcı hangi iadelerin boşaltılacağını kendisi seçer.
  final Set<int> selectedIds;
  final bool isSubmitting;

  List<ReturnDrawerMedicine> get selectedItems =>
      items.where((it) => it.id != null && selectedIds.contains(it.id)).toList();

  /// Mode'dan bağımsız — footer butonu (hangi aksiyonu tetikleyeceği View'da
  /// mode'a göre belirlenir) sadece seçim var mı / gönderim sürüyor mu bakar.
  bool get canConfirm => selectedIds.isNotEmpty && !isSubmitting;

  UnloadDrawerSelection copyWith({List<ReturnDrawerMedicine>? items, Set<int>? selectedIds, bool? isSubmitting}) {
    return UnloadDrawerSelection(
      cabinId: cabinId,
      mode: mode,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final class UnloadDrawerExecuting extends UnloadDrawerState {
  const UnloadDrawerExecuting({
    required this.cabinId,
    required this.items, // seçilen (tüm değil) item'lar
    required this.assignment,
    this.status = CabinOperationJobStatus.active,
    this.isSaving = false,
  });

  final int cabinId;
  final List<ReturnDrawerMedicine> items;
  final MedicineAssignment assignment;
  final CabinOperationJobStatus status;
  final bool isSaving;

  UnloadDrawerExecuting copyWith({
    List<ReturnDrawerMedicine>? items,
    MedicineAssignment? assignment,
    CabinOperationJobStatus? status,
    bool? isSaving,
  }) {
    return UnloadDrawerExecuting(
      cabinId: cabinId,
      items: items ?? this.items,
      assignment: assignment ?? this.assignment,
      status: status ?? this.status,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class UnloadDrawerError extends UnloadDrawerState {
  const UnloadDrawerError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final UnloadDrawerState previousState;
  final bool isQueueError;
}

extension UnloadDrawerStateX on UnloadDrawerState {
  int get cabinId => switch (this) {
    UnloadDrawerSelection(:final cabinId) => cabinId,
    UnloadDrawerExecuting(:final cabinId) => cabinId,
    UnloadDrawerError(:final previousState) => previousState.cabinId,
    _ => 0,
  };

  UnloadDrawerMode? get mode => switch (this) {
    UnloadDrawerLoading(:final mode) => mode,
    UnloadDrawerSelection(:final mode) => mode,
    UnloadDrawerError(:final previousState) => previousState.mode,
    _ => null,
  };
}

extension UnloadDrawerExecutingLocationX on UnloadDrawerExecuting {
  /// Queue'suz tek-job senaryo: kendisi tek elemanlı "job listesi" olarak
  /// besleniyor, currentIndex/currentTargetIndex sabit 0.
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) =>
      buildCabinExecutionLocationItems<UnloadDrawerExecuting>(
        allGroups: allGroups,
        jobs: [this],
        currentIndex: 0,
        currentTargetIndex: 0,
        cabinDrawerIdOf: (job) => job.assignment.cabinDrawerId ?? 0,
        statusOf: (job) => job.status,
        targetCountOf: (job) => 1,
        assignmentAt: (job, _) => job.assignment,
      );
}
