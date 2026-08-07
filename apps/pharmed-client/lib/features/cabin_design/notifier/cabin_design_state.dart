// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

sealed class CabinDesignState {
  const CabinDesignState();
}

final class CabinDesignLoading extends CabinDesignState {
  const CabinDesignLoading();
}

final class CabinDesignReady extends CabinDesignState {
  const CabinDesignReady({
    required this.cabin,
    required this.groups,
    required this.currentReturnSlotId,
    this.selectedSlotId,
    this.pendingReturnSlotId,
    this.pendingReturnValue,
    this.isSaving = false,
  });

  final Cabin cabin;
  final List<DrawerGroup> groups;
  final int? selectedSlotId;
  final int? currentReturnSlotId;

  /// Kaydedilmemiş toggle değişikliğinin uygulanacağı slot.
  final int? pendingReturnSlotId;

  /// true → pendingReturnSlotId iade çekmecesi OLACAK.
  /// false → pendingReturnSlotId iade çekmecesi OLMAKTAN ÇIKACAK
  /// (yalnızca pendingReturnSlotId == currentReturnSlotId iken anlamlıdır —
  /// toggle sadece o an iade çekmecesi olan slot üzerinde kapatılabilir).
  final bool? pendingReturnValue;

  final bool isSaving;

  bool get hasPendingReturnChange => pendingReturnSlotId != null && pendingReturnValue != null;

  DrawerGroup? get selectedGroup => groups.firstWhereOrNull((g) => g.slot.id == selectedSlotId);

  int? get effectiveReturnSlotId {
    if (!hasPendingReturnChange) return currentReturnSlotId;
    return pendingReturnValue! ? pendingReturnSlotId : null;
  }

  bool get canSave => hasPendingReturnChange && !isSaving;

  CabinDesignReady copyWith({
    Cabin? cabin,
    List<DrawerGroup>? groups,
    int? selectedSlotId,
    int? currentReturnSlotId,
    bool clearCurrentReturnSlotId = false,
    int? pendingReturnSlotId,
    bool? pendingReturnValue,
    bool clearPendingReturn = false,
    bool? isSaving,
  }) {
    return CabinDesignReady(
      cabin: cabin ?? this.cabin,
      groups: groups ?? this.groups,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
      currentReturnSlotId: clearCurrentReturnSlotId ? null : (currentReturnSlotId ?? this.currentReturnSlotId),
      pendingReturnSlotId: clearPendingReturn ? null : (pendingReturnSlotId ?? this.pendingReturnSlotId),
      pendingReturnValue: clearPendingReturn ? null : (pendingReturnValue ?? this.pendingReturnValue),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class CabinDesignError extends CabinDesignState {
  const CabinDesignError({required this.message, required this.previousState});

  final String message;
  final CabinDesignState previousState;
}
