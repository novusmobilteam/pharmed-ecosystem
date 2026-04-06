// lib/features/cabin/presentation/state/drug_assignment_ui_state.dart
//
// [SWREQ-UI-CAB-005]
// DrugAssignmentView için sealed UI state.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class DrugAssignmentUiState {
  const DrugAssignmentUiState();
}

/// init() çağrılana kadar geçici state.
final class DrugAssignmentUninitialized extends DrugAssignmentUiState {
  const DrugAssignmentUninitialized();
}

/// Atamalar yükleniyor.
final class DrugAssignmentLoading extends DrugAssignmentUiState {
  const DrugAssignmentLoading({required this.groups, required this.cabinId});

  final List<DrawerGroup> groups;
  final int cabinId;
}

/// Kabin verisi ve atamalar yüklendi, çekmece seçilmedi.
final class DrugAssignmentIdle extends DrugAssignmentUiState {
  const DrugAssignmentIdle({required this.groups, required this.assignments, required this.cabinId});

  final List<DrawerGroup> groups;

  /// Kabine ait tüm atamalar — unit ID üzerinden lookup yapılır.
  final List<CabinAssignment> assignments;

  final int cabinId;
}

/// Çekmece seçildi, göz seçilmedi.
final class DrugAssignmentDrawerSelected extends DrugAssignmentUiState {
  const DrugAssignmentDrawerSelected({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    required this.selectedGroup,
  });

  final List<DrawerGroup> groups;
  final List<CabinAssignment> assignments;
  final int cabinId;
  final DrawerGroup selectedGroup;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
}

/// Göz seçildi — sağ panel aktif.
///
/// [assignment] boşsa [CabinAssignment.empty()] gelir.
/// [selectedDrug] null → ilaç henüz seçilmedi / atanmamış.
/// [selectedDrug] dolu → ya mevcut atamadan ya da dialog'dan seçildi.
final class DrugAssignmentCellSelected extends DrugAssignmentUiState {
  const DrugAssignmentCellSelected({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    required this.selectedGroup,
    required this.assignment,
    this.selectedStepNo,
    this.selectedDrug,
    this.minQty,
    this.maxQty,
    this.criticalQty,
  });

  final List<DrawerGroup> groups;
  final List<CabinAssignment> assignments;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final int? selectedStepNo;

  /// Seçili göze ait atama — boş göz için [CabinAssignment.empty()].
  final CabinAssignment assignment;

  /// Seçili / atanmış ilaç.
  final Medicine? selectedDrug;

  /// Form alanları — kullanıcı düzenleyebilir.
  final int? minQty;
  final int? maxQty;
  final int? criticalQty;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
  int? get selectedUnitId => assignment.cabinDrawerId;

  /// Göz daha önce atanmış mı?
  bool get isAssigned => assignment.id != null;

  /// Kaydet butonu aktif mi?
  /// İlaç seçili + en az minQty girilmiş olmalı.
  bool get canSave => selectedDrug != null && minQty != null && minQty! > 0;
}

/// Kayıt / silme işlemi devam ediyor.
final class DrugAssignmentSaving extends DrugAssignmentUiState {
  const DrugAssignmentSaving({
    required this.groups,
    required this.assignments,
    required this.cabinId,
    required this.selectedGroup,
    required this.assignment,
    this.selectedDrug,
    this.minQty,
    this.maxQty,
    this.criticalQty,
  });

  final List<DrawerGroup> groups;
  final List<CabinAssignment> assignments;
  final int cabinId;
  final DrawerGroup selectedGroup;
  final CabinAssignment assignment;
  final Medicine? selectedDrug;
  final int? minQty;
  final int? maxQty;
  final int? criticalQty;
}

/// İşlem hatası — önceki state'e dönülür.
final class DrugAssignmentError extends DrugAssignmentUiState {
  const DrugAssignmentError({required this.message, required this.previous});

  final String message;

  /// Hata öncesi state — UI geri dönebilir.
  final DrugAssignmentUiState previous;
}
