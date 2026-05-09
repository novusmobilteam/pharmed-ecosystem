// lib/features/refill/master_refill/presentation/state/master_refill_ui_state.dart
//
// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// Master kabin dolum ekranı sealed UI state.
//
// Kabin tipi farkları:
//   Kübik      → CellSelected: selectedUnit + fillingQuantity/countQuantity/miadDate
//   Birim doz  → CellSelected: selectedGroup tüm unit'leriyle seçilir,
//                stepInputs listesi her göz için ayrı input tutar
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'refill_step_input.dart';

sealed class MasterRefillState {
  const MasterRefillState();
}

/// init() çağrılana kadar geçici state.
final class MasterRefillUninitialized extends MasterRefillState {
  const MasterRefillUninitialized();
}

/// Atamalar ve stoklar yükleniyor.
final class MasterRefillLoading extends MasterRefillState {
  const MasterRefillLoading({required this.groups, required this.cabinId});

  final List<DrawerGroup> groups;
  final int cabinId;
}

/// Kabin verisi yüklendi, çekmece seçilmedi.
final class MasterRefillIdle extends MasterRefillState {
  const MasterRefillIdle({
    required this.groups,
    required this.assignments,
    required this.stocks,
    required this.faults,
    required this.cabinId,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final List<MasterFault> faults;
  final int cabinId;
}

/// Çekmece seçildi, göz seçilmedi.
/// Sadece kübik çekmeceler için — birim doz drawer tap'inde
/// direkt CellSelected'a geçilir.
final class MasterRefillDrawerSelected extends MasterRefillState {
  const MasterRefillDrawerSelected({
    required this.groups,
    required this.assignments,
    required this.stocks,
    required this.faults,
    required this.selectedGroup,
    required this.cabinId,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final List<MasterFault> faults;
  final DrawerGroup selectedGroup;
  final int cabinId;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
}

/// Göz / çekmece seçildi — sağ panel aktif.
///
/// Kübik çekmece:
///   [stepInputs] null — [fillingQuantity], [countQuantity], [miadDate] kullanılır.
///   [selectedUnit] seçili göz.
///
/// Birim doz çekmece:
///   [stepInputs] dolu — grup'taki tüm unit'ler için birer [RefillStepInput].
///   [selectedUnit] ilk unit (referans, orta panelde highlight için kullanılır).
///   [fillingQuantity], [countQuantity], [miadDate] ignored.
///
/// TODO: isPerCellMiadEnabled SettingsNotifier'a eklenince
///   stepInputs içindeki miadDate göz bazlı veya tek değer olarak yönetilecek.
final class MasterRefillCellSelected extends MasterRefillState {
  const MasterRefillCellSelected({
    required this.groups,
    required this.assignments,
    required this.stocks,
    required this.faults,
    required this.selectedGroup,
    required this.selectedUnit,
    required this.cabinId,
    this.selectedStepNo,
    this.stepInputs,
    this.fillingQuantity = 0,
    this.countQuantity = 0,
    this.miadDate,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final List<MasterFault> faults;
  final DrawerGroup selectedGroup;

  /// Kübik: seçili göz. Birim doz: ilk unit (referans).
  final DrawerUnit selectedUnit;
  final int? selectedStepNo;
  final int cabinId;

  /// Birim doz: her göz için input listesi. Kübik: null.
  final List<RefillStepInput>? stepInputs;

  /// Kübik input alanları — birim doz'da ignored.
  final double fillingQuantity;
  final double countQuantity;
  final DateTime? miadDate;

  bool get isUnitDose => stepInputs != null;
  bool get isKubik => !isUnitDose;

  int get selectedSlotId => selectedGroup.slot.id ?? -1;
  int? get selectedUnitId => selectedUnit.id;

  /// Kübik: seçili göze ait atama.
  MedicineAssignment? get selectedAssignment =>
      isKubik ? assignments.firstWhereOrNull((a) => a.cabinDrawerId == selectedUnit.id) : null;

  /// Kübik: seçili göze ait stok.
  CabinStock? get selectedStock => isKubik
      ? stocks.firstWhereOrNull((s) {
          final unitId = s.cabinDrawerDetail?.drawerUnit?.id;
          if (unitId != selectedUnit.id) return false;
          if (selectedStepNo != null) return s.cabinDrawerDetail?.stepNo == selectedStepNo;
          return true;
        })
      : null;

  /// Kaydet butonu aktif mi?
  bool get canSave {
    if (isKubik) return selectedAssignment != null && fillingQuantity > 0;
    return stepInputs?.any((s) => s.fillingQuantity > 0) ?? false;
  }

  /// Kübik copyWith — sadece kübik input alanlarını günceller.
  MasterRefillCellSelected copyWithKubik({double? fillingQuantity, double? countQuantity, DateTime? miadDate}) {
    assert(isKubik, 'copyWithKubik sadece kübik çekmece için kullanılabilir');
    return MasterRefillCellSelected(
      groups: groups,
      assignments: assignments,
      stocks: stocks,
      faults: faults,
      selectedGroup: selectedGroup,
      selectedUnit: selectedUnit,
      selectedStepNo: selectedStepNo,
      cabinId: cabinId,
      stepInputs: null,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
      countQuantity: countQuantity ?? this.countQuantity,
      miadDate: miadDate ?? this.miadDate,
    );
  }

  /// Birim doz copyWith — belirli index'teki stepInput'u günceller.
  MasterRefillCellSelected copyWithStepInput(int index, RefillStepInput input) {
    assert(isUnitDose, 'copyWithStepInput sadece birim doz çekmece için kullanılabilir');
    final updated = List<RefillStepInput>.from(stepInputs!);
    updated[index] = input;
    return MasterRefillCellSelected(
      groups: groups,
      assignments: assignments,
      stocks: stocks,
      faults: faults,
      selectedGroup: selectedGroup,
      selectedUnit: selectedUnit,
      cabinId: cabinId,
      stepInputs: updated,
    );
  }
}

/// Dolum kaydediliyor.
final class MasterRefillSaving extends MasterRefillState {
  const MasterRefillSaving({
    required this.groups,
    required this.assignments,
    required this.stocks,
    required this.faults,
    required this.selectedGroup,
    required this.selectedUnit,
    required this.cabinId,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final List<MasterFault> faults;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;
  final int cabinId;
}

/// Dolum başarıyla kaydedildi.
final class MasterRefillSuccess extends MasterRefillState {
  const MasterRefillSuccess({
    required this.groups,
    required this.assignments,
    required this.stocks,
    required this.faults,
    required this.selectedGroup,
    required this.selectedUnit,
    required this.cabinId,
    required this.message,
  });

  final List<DrawerGroup> groups;
  final List<MedicineAssignment> assignments;
  final List<CabinStock> stocks;
  final List<MasterFault> faults;
  final DrawerGroup selectedGroup;
  final DrawerUnit selectedUnit;
  final int cabinId;
  final String message;
}

/// İşlem hatası — previousState'e dönülür.
final class MasterRefillError extends MasterRefillState {
  const MasterRefillError({required this.message, required this.previousState});

  final String message;
  final MasterRefillState previousState;
}

// ─────────────────────────────────────────────────────────────────
// Extension — view'da state switch yazmamak için
// ─────────────────────────────────────────────────────────────────

extension MasterRefillStateX on MasterRefillState {
  List<DrawerGroup> get groups => switch (this) {
    MasterRefillLoading(:final groups) => groups,
    MasterRefillIdle(:final groups) => groups,
    MasterRefillDrawerSelected(:final groups) => groups,
    MasterRefillCellSelected(:final groups) => groups,
    MasterRefillSaving(:final groups) => groups,
    MasterRefillSuccess(:final groups) => groups,
    MasterRefillError(:final previousState) => previousState.groups,
    MasterRefillUninitialized() => const [],
  };

  DrawerGroup? get selectedGroup => switch (this) {
    MasterRefillDrawerSelected(:final selectedGroup) => selectedGroup,
    MasterRefillCellSelected(:final selectedGroup) => selectedGroup,
    MasterRefillSaving(:final selectedGroup) => selectedGroup,
    MasterRefillSuccess(:final selectedGroup) => selectedGroup,
    MasterRefillError(:final previousState) => previousState.selectedGroup,
    _ => null,
  };

  int? get selectedSlotId => switch (this) {
    MasterRefillDrawerSelected s => s.selectedSlotId,
    MasterRefillCellSelected s => s.selectedSlotId,
    MasterRefillSaving(:final selectedGroup) => selectedGroup.slot.id,
    MasterRefillSuccess(:final selectedGroup) => selectedGroup.slot.id,
    MasterRefillError(:final previousState) => previousState.selectedSlotId,
    _ => null,
  };

  int? get selectedUnitId => switch (this) {
    MasterRefillCellSelected s => s.selectedUnitId,
    MasterRefillSaving(:final selectedUnit) => selectedUnit.id,
    MasterRefillSuccess(:final selectedUnit) => selectedUnit.id,
    MasterRefillError(:final previousState) => previousState.selectedUnitId,
    _ => null,
  };

  int? get selectedStepNo => switch (this) {
    MasterRefillCellSelected(:final selectedStepNo) => selectedStepNo,
    MasterRefillError(:final previousState) => previousState.selectedStepNo,
    _ => null,
  };

  List<MedicineAssignment> get assignments => switch (this) {
    MasterRefillIdle(:final assignments) => assignments,
    MasterRefillDrawerSelected(:final assignments) => assignments,
    MasterRefillCellSelected(:final assignments) => assignments,
    MasterRefillSaving(:final assignments) => assignments,
    MasterRefillSuccess(:final assignments) => assignments,
    MasterRefillError(:final previousState) => previousState.assignments,
    _ => const [],
  };

  List<CabinStock> get stocks => switch (this) {
    MasterRefillIdle(:final stocks) => stocks,
    MasterRefillDrawerSelected(:final stocks) => stocks,
    MasterRefillCellSelected(:final stocks) => stocks,
    MasterRefillSaving(:final stocks) => stocks,
    MasterRefillSuccess(:final stocks) => stocks,
    MasterRefillError(:final previousState) => previousState.stocks,
    _ => const [],
  };

  List<MasterFault> get faults => switch (this) {
    MasterRefillIdle(:final faults) => faults,
    MasterRefillDrawerSelected(:final faults) => faults,
    MasterRefillCellSelected(:final faults) => faults,
    MasterRefillSaving(:final faults) => faults,
    MasterRefillSuccess(:final faults) => faults,
    MasterRefillError(:final previousState) => previousState.faults,
    _ => const [],
  };

  int get cabinId => switch (this) {
    MasterRefillLoading(:final cabinId) => cabinId,
    MasterRefillIdle(:final cabinId) => cabinId,
    MasterRefillDrawerSelected(:final cabinId) => cabinId,
    MasterRefillCellSelected(:final cabinId) => cabinId,
    MasterRefillSaving(:final cabinId) => cabinId,
    MasterRefillSuccess(:final cabinId) => cabinId,
    MasterRefillError(:final previousState) => previousState.cabinId,
    MasterRefillUninitialized() => 0,
  };
}
