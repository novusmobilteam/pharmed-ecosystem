// Master kabin İLAÇ İADE ekranının state hiyerarşisi. Check sonrası dallanma
// intake'ten farklı: her item'ın returnType'ına (ilaç tanımının sabit
// özelliği) göre donanım gerekip gerekmediği ayrı ayrı belirlenir. "Hepsi tek
// kuyruğa girer" varsayımı YOK — check sonrası item'lar iki gruba ayrılır:
//   - donanımsız (toPharmacy) → hemen completeRefund
//   - donanımlı (toReturnBox/toDrawer/toOrigin) → MasterRefundExecuting kuyruğuna girer
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';
import '../../../../core/hardware/hardware.dart';

sealed class MasterRefundState {
  const MasterRefundState();
}

final class MasterRefundUninitialized extends MasterRefundState {
  const MasterRefundUninitialized();
}

final class MasterRefundLoading extends MasterRefundState {
  const MasterRefundLoading();
}

final class MasterRefundPatientSelection extends MasterRefundState {
  const MasterRefundPatientSelection();
}

final class MasterRefundMedicineSelection extends MasterRefundState {
  const MasterRefundMedicineSelection({
    required this.hospitalization,
    required this.items,
    this.selectedItemIds = const {},
    this.search = '',
    this.checkStatuses = const {},
    this.isChecking = false,
  });

  final Hospitalization hospitalization;

  /// Kullanıcının GİRDİĞİ iade miktarı artık item'ın kendi returnQuantity
  /// alanında taşınıyor — IntakeItem.dosePiece ile aynı desen (ayrı bir Map
  /// tutmuyoruz, RefundAmounts kaldırıldı).
  final List<RefundableItem> items;

  final Set<int> selectedItemIds;
  final String search;
  final Map<int, RefundCheckStatus> checkStatuses;
  final bool isChecking;

  List<RefundableItem> get visibleItems {
    if (search.trim().isEmpty) return items;
    final q = search.toLowerCase().trim();
    return items.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  /// item.returnQuantity düzenlendiyse onu, düzenlenmediyse appliedQuantity'yi
  /// (üst sınır) döner.
  double amountFor(int itemId) {
    final item = items.firstWhereOrNull((it) => it.id == itemId);
    if (item == null) return 0;
    return (item.returnQuantity ?? item.lastMovement?.prescriptionItem?.receiveDosePiece ?? 0).toDouble();
  }

  double maxAmountFor(int itemId) {
    final item = items.firstWhereOrNull((it) => it.id == itemId);
    return item?.lastMovement?.prescriptionItem?.receiveDosePiece?.toDouble() ?? 0;
  }

  /// Footer'daki "İadeyi Başlat" butonu SADECE donanım gerektiren
  /// (toOrigin/toDrawer) seçili item varsa anlamlıdır — toReturnBox/
  /// toPharmacy kendi kart butonundan (completeDirectRefund) tamamlanır.
  bool get hasHardwareSelection => selectedItems.any((it) {
    final drug = it.medicine?.when(drug: (d) => d, consumable: (_) => null);
    return drug?.returnType?.requiresCabinHardware ?? false;
  });

  bool get canStart => hasHardwareSelection && !isChecking;
  List<RefundableItem> get selectedItems => items.where((a) => selectedItemIds.contains(a.id)).toList();

  MasterRefundMedicineSelection copyWith({
    List<RefundableItem>? items,
    Set<int>? selectedItemIds,
    String? search,
    Map<int, RefundCheckStatus>? checkStatuses,
    bool? isChecking,
  }) {
    return MasterRefundMedicineSelection(
      hospitalization: hospitalization,
      items: items ?? this.items,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      search: search ?? this.search,
      checkStatuses: checkStatuses ?? this.checkStatuses,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

final class MasterRefundExecuting extends MasterRefundState {
  const MasterRefundExecuting({
    required this.jobs,
    this.currentIndex = 0,
    this.currentTargetIndex = 0,
    this.isSaving = false,
  });

  final List<RefundDrawerJob> jobs;
  final int currentIndex;
  final int currentTargetIndex;
  final bool isSaving;

  RefundDrawerJob? get currentJob => currentIndex < jobs.length ? jobs[currentIndex] : null;
  RefundTarget? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    return currentTargetIndex < job.targets.length ? job.targets[currentTargetIndex] : null;
  }

  double get progress => jobs.isEmpty ? 0 : currentIndex / jobs.length;

  int? get currentCabinId => currentJob?.cabinId;

  MasterRefundExecuting copyWith({
    List<RefundDrawerJob>? jobs,
    int? currentIndex,
    int? currentTargetIndex,
    bool? isSaving,
  }) {
    return MasterRefundExecuting(
      jobs: jobs ?? this.jobs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentTargetIndex: currentTargetIndex ?? this.currentTargetIndex,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class MasterRefundError extends MasterRefundState {
  const MasterRefundError({required this.failure, required this.previousState, this.isQueueError = false});

  final CabinOperationFailure failure;
  final MasterRefundState previousState;
  final bool isQueueError;
}

extension MasterRefundStateX on MasterRefundState {
  int get cabinId => switch (this) {
    MasterRefundPatientSelection(:final cabinId) => cabinId,
    MasterRefundMedicineSelection(:final cabinId) => cabinId,
    MasterRefundExecuting(:final cabinId) => cabinId,
    MasterRefundError(:final previousState) => previousState.cabinId,
    _ => 0,
  };

  Hospitalization? get hospitalization => switch (this) {
    MasterRefundMedicineSelection(:final hospitalization) => hospitalization,
    MasterRefundError(:final previousState) => previousState.hospitalization,
    _ => null,
  };
}

extension MasterRefundExecutingLocationX on MasterRefundExecuting {
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups) => buildCabinExecutionLocationItems(
    allGroups: allGroups,
    jobs: jobs,
    currentIndex: currentIndex,
    currentTargetIndex: currentTargetIndex,
    cabinDrawerIdOf: (job) => job.cabinDrawerId,
    statusOf: (job) => job.status,
    targetCountOf: (job) => job.targets.length,
    assignmentAt: (job, i) => job.targets[i].assignment,
    stockIdAt: (job, i) => job.targets[i].item.source.stock?.id,
    isReturnDrawerTargetOf: (job) => job.isReturnDrawer,
  );
}
