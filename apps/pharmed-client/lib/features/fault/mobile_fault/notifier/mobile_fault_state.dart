import 'package:pharmed_core/pharmed_core.dart';

import '../../fault.dart';

sealed class MobileFaultState {
  const MobileFaultState();
}

class MobileFaultUninitialized extends MobileFaultState {
  const MobileFaultUninitialized();
}

class MobileFaultLoading extends MobileFaultState {
  const MobileFaultLoading({required this.slots, required this.cabinId});

  final List<MobileSlotVisual> slots;
  final int cabinId;
}

class MobileFaultIdle extends MobileFaultState {
  const MobileFaultIdle({required this.slots, required this.faults, required this.cabinId});

  final List<MobileSlotVisual> slots;
  final List<MobileFault> faults;
  final int cabinId;
}

class MobileFaultSlotSelected extends MobileFaultState implements FaultPanelState {
  const MobileFaultSlotSelected({
    required this.slots,
    required this.faults,
    required this.cabinId,
    required this.faultHistory,
    required this.selectedStatus,
    required this.selectedSlot,
    this.activeFault,
    this.description,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileFault> faults;
  final int cabinId;
  final MobileSlotVisual selectedSlot;

  @override
  final IFaultRecord? activeFault;

  @override
  final CabinWorkingStatus selectedStatus;

  @override
  final String? description;

  @override
  final List<IFaultRecord> faultHistory;

  @override
  bool get isNewRecord => activeFault == null;

  @override
  bool get canSubmit => isNewRecord || activeFault != null;
}

class MobileFaultSaving extends MobileFaultState {
  const MobileFaultSaving({
    required this.slots,
    required this.faults,
    required this.cabinId,
    required this.selectedSlot,
  });

  final List<MobileSlotVisual> slots;
  final List<MobileFault> faults;
  final int cabinId;
  final MobileSlotVisual selectedSlot;
}

class MobileFaultSuccess extends MobileFaultState {
  const MobileFaultSuccess({required this.message, required this.previous});

  final String message;
  final MobileFaultSlotSelected previous;
}

class MobileFaultError extends MobileFaultState {
  const MobileFaultError({required this.message, required this.previous});

  final String message;
  final MobileFaultState previous;
}

extension MobileFaultStateX on MobileFaultState {
  List<MobileSlotVisual> get slots => switch (this) {
    MobileFaultLoading(:final slots) => slots,
    MobileFaultIdle(:final slots) => slots,
    MobileFaultSlotSelected(:final slots) => slots,
    MobileFaultSaving(:final slots) => slots,
    MobileFaultSuccess(:final previous) => previous.slots,
    MobileFaultError(:final previous) => previous.slots,
    MobileFaultUninitialized() => const [],
  };

  List<MobileFault> get faults => switch (this) {
    MobileFaultIdle(:final faults) => faults,
    MobileFaultSlotSelected(:final faults) => faults,
    MobileFaultSaving(:final faults) => faults,
    MobileFaultSuccess(:final previous) => previous.faults,
    MobileFaultError(:final previous) => previous.faults,
    _ => const [],
  };

  int get cabinId => switch (this) {
    MobileFaultLoading(:final cabinId) => cabinId,
    MobileFaultIdle(:final cabinId) => cabinId,
    MobileFaultSlotSelected(:final cabinId) => cabinId,
    MobileFaultSaving(:final cabinId) => cabinId,
    MobileFaultSuccess(:final previous) => previous.cabinId,
    MobileFaultError(:final previous) => previous.cabinId,
    MobileFaultUninitialized() => 0,
  };

  int? get selectedSlotId => switch (this) {
    MobileFaultSlotSelected(:final selectedSlot) => selectedSlot.slotId,
    MobileFaultSaving(:final selectedSlot) => selectedSlot.slotId,
    MobileFaultSuccess(:final previous) => previous.selectedSlot.slotId,
    _ => null,
  };

  MobileSlotVisual? get selectedSlot => switch (this) {
    MobileFaultSlotSelected(:final selectedSlot) => selectedSlot,
    MobileFaultSaving(:final selectedSlot) => selectedSlot,
    MobileFaultSuccess(:final previous) => previous.selectedSlot,
    _ => null,
  };
}
