// [SWREQ-UI-CAB-005]
// İlaç bazlı atama ekranı state yönetimi.
//
// Sorumluluk:
//   - CabinVisualizerData'dan groups alır (ekstra istek yok)
//   - init() → GetAssignmentsUseCase ile atamaları çeker
//   - Çekmece / göz seçimi → bellekte lookup, istek atılmaz
//   - onDrugSelected() → dialog'dan gelen ilacı state'e yazar
//   - saveAssignment() → UpdateAssignmentUseCase
//   - deleteAssignment() → DeleteAssignmentUseCase
//   - İşlem sonrası atamaları yeniler
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../assignment.dart';

final drugAssignmentNotifierProvider = NotifierProvider<DrugAssignmentNotifier, DrugAssignmentUiState>(
  DrugAssignmentNotifier.new,
);

class DrugAssignmentNotifier extends Notifier<DrugAssignmentUiState> {
  GetMedicineAssignmentsUseCase get _getAssignments => ref.read(getAssignmentsUseCaseProvider);
  CreateMedicineAssignmentUseCase get _createAssignment => ref.read(createAssignmentUseCaseProvider);
  UpdateMedicineAssignmentUseCase get _updateAssignment => ref.read(updateAssignmentUseCaseProvider);
  DeleteMedicineAssignmentUseCase get _deleteAssignment => ref.read(deleteAssignmentUseCaseProvider);

  @override
  DrugAssignmentUiState build() => const DrugAssignmentUninitialized();

  /// [CabinVisualizerData] dashboard'dan gelir.
  /// Atamaları API'den çeker.
  Future<void> init(CabinVisualizerData data) async {
    final cabinId = data.cabinId;

    state = DrugAssignmentLoading(groups: data.groups, cabinId: cabinId);

    final result = await _getAssignments.call(data.cabinId);

    state = result.when(
      ok: (assignments) => DrugAssignmentIdle(groups: data.groups, assignments: assignments, cabinId: cabinId),
      error: (e) => DrugAssignmentError(
        message: e.message,
        previous: DrugAssignmentIdle(groups: data.groups, assignments: const [], cabinId: cabinId),
      ),
    );
  }

  /// Sol panelden bir çekmecye tıklandığında çağrılır.
  /// Aynı çekmece tekrar tıklanırsa [DrugAssignmentIdle]'a döner.
  void onDrawerTap(DrawerGroup group) {
    final current = state;
    final groups = _extractGroups(current);
    final assignments = _extractAssignments(current);
    final cabinId = _extractCabinId(current);

    // Toggle
    final currentSlotId = switch (current) {
      DrugAssignmentDrawerSelected s => s.selectedSlotId,
      DrugAssignmentCellSelected s => s.selectedSlotId,
      _ => null,
    };

    if (currentSlotId == (group.slot.id ?? -1)) {
      state = DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId);
      return;
    }

    state = DrugAssignmentDrawerSelected(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: group,
    );
  }

  /// Orta panelden bir göze tıklandığında çağrılır.
  /// Göze ait atamayı bellekte bulur, yoksa empty üretir.
  /// Aynı göz tekrar tıklanırsa [DrugAssignmentDrawerSelected]'a döner.
  void onCellTap(DrawerUnit unit, int? stepNo) {
    final current = state;

    final groups = _extractGroups(current);
    final assignments = _extractAssignments(current);
    final cabinId = _extractCabinId(current);

    final selectedGroup = switch (current) {
      DrugAssignmentDrawerSelected s => s.selectedGroup,
      DrugAssignmentCellSelected s => s.selectedGroup,
      _ => null,
    };

    if (selectedGroup == null) return;

    // Toggle — aynı göz tekrar tıklandı
    if (current is DrugAssignmentCellSelected &&
        current.selectedUnitId == unit.id &&
        current.selectedStepNo == stepNo) {
      state = DrugAssignmentDrawerSelected(
        groups: groups,
        assignments: assignments,
        cabinId: cabinId,
        selectedGroup: selectedGroup,
      );
      return;
    }

    // Göze ait atamayı bul — yoksa empty üret
    final assignment = _findAssignment(unitId: unit.id, cabinId: cabinId, assignments: assignments);

    // Mevcut atamadan ilaç bilgisini çek
    final drug = assignment.medicine;

    state = DrugAssignmentCellSelected(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      assignment: assignment,
      selectedDrug: drug,
      selectedStepNo: stepNo,
      minQty: assignment.minQuantityFromBackend.toInt(),
      maxQty: assignment.maxQuantityFromBackend.toInt(),
      criticalQty: assignment.critQuantityFromBackend.toInt(),
    );
  }

  // ── İlaç seçimi ──────────────────────────────────────────────────

  /// Dialog'dan ilaç seçildiğinde çağrılır.
  void onDrugSelected(Medicine drug) {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;

    state = DrugAssignmentCellSelected(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      assignment: current.assignment,
      selectedDrug: drug,
      minQty: current.minQty,
      maxQty: current.maxQty,
      criticalQty: current.criticalQty,
    );
  }

  // ── Form alanları ────────────────────────────────────────────────

  void onMinQtyChanged(int? value) => _updateFormField(minQty: value);
  void onMaxQtyChanged(int? value) => _updateFormField(maxQty: value);
  void onCriticalQtyChanged(int? value) => _updateFormField(criticalQty: value);

  void _updateFormField({int? minQty, int? maxQty, int? criticalQty}) {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;

    state = DrugAssignmentCellSelected(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      assignment: current.assignment,
      selectedDrug: current.selectedDrug,
      minQty: minQty ?? current.minQty,
      maxQty: maxQty ?? current.maxQty,
      criticalQty: criticalQty ?? current.criticalQty,
    );
  }

  // ── Kaydet ───────────────────────────────────────────────────────

  /// Atamayı kaydeder — yeni atama veya güncelleme.
  Future<void> saveAssignment() async {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    if (!current.canSave) return;

    final updated = current.assignment.copyWith(
      medicine: current.selectedDrug,
      minQuantity: current.minQty,
      maxQuantity: current.maxQty,
      criticalQuantity: current.criticalQty,
    );

    state = DrugAssignmentSaving(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      assignment: current.assignment,
      selectedDrug: current.selectedDrug,
      minQty: current.minQty,
      maxQty: current.maxQty,
      criticalQty: current.criticalQty,
    );

    final result = current.isAssigned ? await _updateAssignment.call(updated) : await _createAssignment.call(updated);

    result.when(
      ok: (_) => _refreshAssignments(
        groups: current.groups,
        cabinId: current.cabinId,
        selectedGroup: current.selectedGroup,
        selectedUnitId: current.selectedUnitId,
        selectedStepNo: null,
      ),
      error: (e) {
        state = DrugAssignmentError(message: e.message, previous: current);
      },
    );
  }

  /// Atamayı siler.
  Future<void> deleteAssignment() async {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    if (!current.isAssigned) return;

    state = DrugAssignmentSaving(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: current.selectedGroup,
      assignment: current.assignment,
      selectedDrug: current.selectedDrug,
      minQty: current.minQty,
      maxQty: current.maxQty,
      criticalQty: current.criticalQty,
    );

    final result = await _deleteAssignment.call(current.assignment.cabinDrawerId ?? 0);

    result.when(
      ok: (_) => _refreshAssignments(
        groups: current.groups,
        cabinId: current.cabinId,
        selectedGroup: current.selectedGroup,
        selectedUnitId: current.selectedUnitId,
        selectedStepNo: current.selectedStepNo,
      ),
      error: (e) {
        state = DrugAssignmentError(message: e.message, previous: current);
      },
    );
  }

  void dismissError() {
    final current = state;
    if (current is! DrugAssignmentError) return;
    state = current.previous;
  }

  /// İşlem sonrası atamaları yeniler, seçili grup korunur.
  Future<void> _refreshAssignments({
    required List<DrawerGroup> groups,
    required int cabinId,
    required DrawerGroup selectedGroup,
    required int? selectedUnitId,
    required int? selectedStepNo,
  }) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) {
        final assignment = _findAssignment(unitId: selectedUnitId, cabinId: cabinId, assignments: assignments);

        return DrugAssignmentCellSelected(
          groups: groups,
          assignments: assignments,
          cabinId: cabinId,
          selectedGroup: selectedGroup,
          assignment: assignment,
          selectedDrug: assignment.medicine,
          minQty: assignment.minQuantity?.toInt(),
          maxQty: assignment.maxQuantity?.toInt(),
          criticalQty: assignment.criticalQuantity?.toInt(),
          selectedStepNo: selectedStepNo,
        );
      },
      error: (e) => DrugAssignmentError(
        message: e.message,
        previous: DrugAssignmentIdle(groups: groups, assignments: const [], cabinId: cabinId),
      ),
    );
  }

  MedicineAssignment _findAssignment({
    required int? unitId,
    required int cabinId,
    required List<MedicineAssignment> assignments,
  }) {
    if (unitId == null) {
      return MedicineAssignment.empty(cabinId: cabinId, cabinDrawerId: 0);
    }
    try {
      return assignments.firstWhere((a) => a.cabinDrawerId == unitId);
    } catch (_) {
      return MedicineAssignment.empty(cabinId: cabinId, cabinDrawerId: unitId);
    }
  }

  List<DrawerGroup> _extractGroups(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentLoading(:final groups) => groups,
    DrugAssignmentIdle(:final groups) => groups,
    DrugAssignmentDrawerSelected(:final groups) => groups,
    DrugAssignmentCellSelected(:final groups) => groups,
    DrugAssignmentSaving(:final groups) => groups,
    DrugAssignmentError(:final previous) => _extractGroups(previous),
    _ => const [],
  };

  List<MedicineAssignment> _extractAssignments(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentIdle(:final assignments) => assignments,
    DrugAssignmentDrawerSelected(:final assignments) => assignments,
    DrugAssignmentCellSelected(:final assignments) => assignments,
    DrugAssignmentSaving(:final assignments) => assignments,
    DrugAssignmentError(:final previous) => _extractAssignments(previous),
    _ => const [],
  };

  dynamic _extractCabinId(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentLoading(:final cabinId) => cabinId,
    DrugAssignmentIdle(:final cabinId) => cabinId,
    DrugAssignmentDrawerSelected(:final cabinId) => cabinId,
    DrugAssignmentCellSelected(:final cabinId) => cabinId,
    DrugAssignmentSaving(:final cabinId) => cabinId,
    DrugAssignmentError(:final previous) => _extractCabinId(previous),
    _ => '',
  };
}
