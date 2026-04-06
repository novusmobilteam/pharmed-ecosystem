// [SWREQ-UI-CAB-006]
// FaultView için sealed UI state.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class FaultUiState {
  const FaultUiState();
}

final class FaultUninitialized extends FaultUiState {
  const FaultUninitialized();
}

/// Arıza kayıtları yükleniyor.
final class FaultLoading extends FaultUiState {
  const FaultLoading({required this.groups, required this.cabinId});

  final List<DrawerGroup> groups;
  final int cabinId;
}

/// Kayıtlar yüklendi, göz seçilmedi.
final class FaultIdle extends FaultUiState {
  const FaultIdle({required this.groups, required this.faults, required this.cabinId});

  final List<DrawerGroup> groups;

  /// Tüm kabin arıza kayıtları — slotId üzerinden lookup yapılır.
  final List<Fault> faults;

  final int cabinId;
}

/// Çekmece seçildi, göz seçilmedi.
final class FaultDrawerSelected extends FaultUiState {
  const FaultDrawerSelected({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
  });

  final List<DrawerGroup> groups;
  final List<Fault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
}

/// Göz seçildi — sağ panel aktif.
///
/// [activeFault] null → yeni kayıt modu.
/// [activeFault] dolu → sonlandır modu (endDate set edilecek).
final class FaultCellSelected extends FaultUiState {
  const FaultCellSelected({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
    required this.selectedUnit,
    required this.faultHistory,
    this.activeFault,
    this.selectedStatus = CabinWorkingStatus.faulty,
    this.description,
  });

  final List<DrawerGroup> groups;
  final List<Fault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;

  /// Seçili göze ait tüm arıza geçmişi — en yeni en üstte.
  final List<Fault> faultHistory;

  /// Aktif (endDate == null) arıza kaydı.
  /// null → yeni kayıt modu, dolu → sonlandır modu.
  final Fault? activeFault;

  /// Segmented button seçimi — sadece yeni kayıt modunda değiştirilebilir.
  final CabinWorkingStatus selectedStatus;

  /// Açıklama alanı.
  final String? description;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;

  /// Yeni kayıt modu mu?
  bool get isNewRecord => activeFault == null;

  /// Kaydet butonu aktif mi?
  bool get canSubmit => isNewRecord || activeFault?.id != null;
}

/// Kayıt işlemi devam ediyor.
final class FaultSaving extends FaultUiState {
  const FaultSaving({
    required this.groups,
    required this.faults,
    required this.cabinId,
    required this.selectedGroup,
    required this.selectedUnit,
  });

  final List<DrawerGroup> groups;
  final List<Fault> faults;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;
}

/// İşlem hatası.
final class FaultError extends FaultUiState {
  const FaultError({required this.message, required this.previous});

  final String message;
  final FaultUiState previous;
}
