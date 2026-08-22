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
    this.search = '',
  });

  final int cabinId;
  final UnloadDrawerMode mode;
  final List<ReturnDrawerMedicine> items;
  final String search;

  /// Artık HER iki modda da anlamlı — hem drawer hem box tarafında
  /// kullanıcı hangi iadelerin boşaltılacağını kendisi seçer.
  final Set<int> selectedIds;
  final bool isSubmitting;

  List<ReturnDrawerMedicine> get selectedItems =>
      items.where((it) => it.id != null && selectedIds.contains(it.id)).toList();

  /// Mode'dan bağımsız — footer butonu (hangi aksiyonu tetikleyeceği View'da
  /// mode'a göre belirlenir) sadece seçim var mı / gönderim sürüyor mu bakar.
  bool get canConfirm => selectedIds.isNotEmpty && !isSubmitting;

  List<ReturnDrawerMedicine> get visibleMedicines {
    if (search.trim().isEmpty) return items;
    final q = search.toLowerCase().trim();
    return items.where((a) {
      final name = a.material?.name?.toLowerCase() ?? '';
      final barcode = a.material?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  UnloadDrawerSelection copyWith({
    List<ReturnDrawerMedicine>? items,
    Set<int>? selectedIds,
    bool? isSubmitting,
    String? search,
  }) {
    return UnloadDrawerSelection(
      cabinId: cabinId,
      mode: mode,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      search: search ?? this.search,
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
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) =>
      buildCabinExecutionLocationItems<UnloadDrawerExecuting>(
        allGroups: allGroups,
        jobs: [this],
        currentIndex: 0,
        currentTargetIndex: 0,
        // Diğer tüm ekranlarla (Refund/Census/Refill) TUTARLI olması için
        // unit id değil SLOT id gönderilmeli — buildCabinExecutionLocationItems
        // allGroups'u slot bazlı eşliyor (DrawerGroup = DrawerSlot + units).
        // assignment.cabinDrawerId burada yanlışlıkla unit.id'yi taşıyor
        // (bkz. _resolveReturnDrawerAssignment: cabinDrawerId: unit.id).
        cabinDrawerIdOf: (job) =>
            job.assignment.drawerUnit?.drawerSlot?.id ?? job.assignment.drawerUnit?.drawerSlotId ?? 0,
        statusOf: (job) => job.status,
        targetCountOf: (job) => 1,
        assignmentAt: (job, _) => job.assignment,
        // Unload akışının TEK hedefi zaten fiziksel iade çekmecesinin kendisi
        // (bkz. UnloadDrawerNotifier._resolveReturnDrawerAssignment) — bu
        // yüzden koşulsuz true. Refund'daki gibi toOrigin/toDrawer ayrımı
        // burada yok, her Unload job'ı iade kutusunu hedefler.
        isReturnDrawerTargetOf: (job) => true,
      );
}
