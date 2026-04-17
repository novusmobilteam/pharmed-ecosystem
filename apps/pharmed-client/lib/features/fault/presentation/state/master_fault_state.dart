// [SWREQ-UI-CAB-006]
// FaultView için sealed UI state.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../fault.dart';

sealed class MasterFaultState {
  const MasterFaultState();
}

final class MasterFaultUninitialized extends MasterFaultState {
  const MasterFaultUninitialized();
}

/// Arıza kayıtları yükleniyor.
final class MasterFaultLoading extends MasterFaultState {
  const MasterFaultLoading({required this.groups, required this.cabinId});

  final List<DrawerGroup> groups;
  final int cabinId;
}

/// Kayıtlar yüklendi, göz seçilmedi.
final class MasterFaultIdle extends MasterFaultState {
  const MasterFaultIdle({required this.groups, required this.faults, required this.cabinId});

  final List<DrawerGroup> groups;

  /// Tüm kabin arıza kayıtları — slotId üzerinden lookup yapılır.
  final List<MasterFault> faults;

  final int cabinId;
}

/// Çekmece seçildi, göz seçilmedi.
final class MasterFaultDrawerSelected extends MasterFaultState {
  const MasterFaultDrawerSelected({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
  });

  final List<DrawerGroup> groups;
  final List<MasterFault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
}

/// Göz seçildi — sağ panel aktif.
///
/// [activeFault] null → yeni kayıt modu.
/// [activeFault] dolu → sonlandır modu (endDate set edilecek).
final class MasterFaultCellSelected extends MasterFaultState implements FaultPanelState {
  const MasterFaultCellSelected({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
    required this.selectedUnit,
    required this.selectedStatus,
    required this.faultHistory,
    this.activeFault,
    this.description,
  });

  final List<DrawerGroup> groups;
  final List<MasterFault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;

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

/// Kayıt işlemi devam ediyor.
final class MasterFaultSaving extends MasterFaultState {
  const MasterFaultSaving({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
    required this.selectedUnit,
  });

  final List<DrawerGroup> groups;
  final List<MasterFault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;
}

/// Kayıt işlemi başarılı
class MasterFaultSuccess extends MasterFaultState {
  const MasterFaultSuccess({required this.message, required this.previous});

  final String message;
  final MasterFaultCellSelected previous;
}

/// İşlem hatası.
final class MasterFaultError extends MasterFaultState {
  const MasterFaultError({required this.message, required this.previous});

  final String message;
  final MasterFaultState previous;
}

extension MasterFaultUiStateX on MasterFaultState {
  List<DrawerGroup> get groups => switch (this) {
    MasterFaultLoading(:final groups) => groups,
    MasterFaultIdle(:final groups) => groups,
    MasterFaultDrawerSelected(:final groups) => groups,
    MasterFaultCellSelected(:final groups) => groups,
    MasterFaultSaving(:final groups) => groups,
    MasterFaultSuccess(:final previous) => previous.groups,
    MasterFaultError(:final previous) => previous.groups,
    MasterFaultUninitialized() => const [],
  };

  List<MasterFault> get faults => switch (this) {
    MasterFaultIdle(:final faults) => faults,
    MasterFaultDrawerSelected(:final faults) => faults,
    MasterFaultCellSelected(:final faults) => faults,
    MasterFaultSaving(:final faults) => faults,
    MasterFaultSuccess(:final previous) => previous.faults,
    MasterFaultError(:final previous) => previous.faults,
    _ => const [],
  };

  int get cabinId => switch (this) {
    MasterFaultLoading(:final cabinId) => cabinId,
    MasterFaultIdle(:final cabinId) => cabinId,
    MasterFaultDrawerSelected(:final cabinId) => cabinId,
    MasterFaultCellSelected(:final cabinId) => cabinId,
    MasterFaultSaving(:final cabinId) => cabinId,
    MasterFaultSuccess(:final previous) => previous.cabinId,
    MasterFaultError(:final previous) => previous.cabinId,
    MasterFaultUninitialized() => 0,
  };

  int? get selectedSlotId => switch (this) {
    MasterFaultDrawerSelected(:final selectedSlotId) => selectedSlotId,
    MasterFaultCellSelected(:final selectedSlotId) => selectedSlotId,
    MasterFaultSaving(:final selectedGroup) => selectedGroup.slot.id,
    MasterFaultSuccess(:final previous) => previous.selectedSlotId,
    _ => null,
  };

  DrawerGroup? get selectedGroup => switch (this) {
    MasterFaultDrawerSelected(:final selectedGroup) => selectedGroup,
    MasterFaultCellSelected(:final selectedGroup) => selectedGroup,
    MasterFaultSaving(:final selectedGroup) => selectedGroup,
    MasterFaultSuccess(:final previous) => previous.selectedGroup,
    _ => null,
  };

  int? get selectedUnitId => switch (this) {
    MasterFaultCellSelected(:final selectedUnit) => selectedUnit.id,
    MasterFaultSaving(:final selectedUnit) => selectedUnit.id,
    MasterFaultSuccess(:final previous) => previous.selectedUnitId,
    _ => null,
  };
}
