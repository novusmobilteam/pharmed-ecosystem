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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import '../../assignment.dart';

final drugAssignmentNotifierProvider = NotifierProvider<DrugAssignmentNotifier, DrugAssignmentUiState>(
  DrugAssignmentNotifier.new,
);

class DrugAssignmentNotifier extends Notifier<DrugAssignmentUiState> {
  GetMedicineAssignmentsUseCase get _getAssignments => ref.read(getMedicineAssignmentsUseCaseProvider);
  CreateMedicineAssignmentUseCase get _createAssignment => ref.read(createAssignmentUseCaseProvider);
  UpdateMedicineAssignmentUseCase get _updateAssignment => ref.read(updateMedicineAssignmentUseCaseProvider);
  DeleteMedicineAssignmentUseCase get _deleteAssignment => ref.read(deleteAssignmentUseCaseProvider);
  GetMedicinesUseCase get _getMedicines => ref.read(getMedicinesUseCaseProvider);

  static const _medicinePageSize = 10;
  static const _searchDebounce = Duration(milliseconds: 400);

  /// Son çekilen ilaç sayfası — göz değiştirildiğinde YENİDEN ÇEKİLMEZ,
  /// aynen reuse edilir. Sadece kullanıcı arama yaptığında ya da sayfa
  /// değiştirdiğinde güncellenir. init() ile yeni bir kabine geçilince
  /// sıfırlanır (bkz. init()).
  MedicinePageState? _cachedMedicinePage;
  Timer? _searchDebounceTimer;

  @override
  DrugAssignmentUiState build() {
    ref.onDispose(() => _searchDebounceTimer?.cancel());
    return const DrugAssignmentUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    _cachedMedicinePage = null;
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

  // ── Göz seçimi ──────────────────────────────────────────────────

  /// Sol panelden bir göze dokunulduğunda çağrılır (boş ya da dolu fark
  /// etmez). Aynı göze tekrar dokunulursa Idle'a döner (toggle).
  void onCellTap(DrawerUnit unit, int? stepNo) {
    final current = state;
    if (current is! DrugAssignmentIdle && current is! DrugAssignmentCellSelected) return;

    final groups = _extractGroups(current);
    final assignments = _extractAssignments(current);
    final cabinId = _extractCabinId(current);

    if (current is DrugAssignmentCellSelected &&
        current.assignment.cabinDrawerId == unit.id &&
        current.selectedStepNo == stepNo) {
      state = DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId);
      return;
    }

    final selectedGroup = _findGroupForUnit(unit.id, groups);
    if (selectedGroup == null) return;

    _enterEditing(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      unitId: unit.id,
      selectedStepNo: stepNo,
    );
  }

  void onAssignmentSearchChanged(String? value) {
    final s = state;
    if (s is! DrugAssignmentIdle) return;
    state = s.copyWith(searchQuery: value);
  }

  /// "MEVCUT ATAMALAR" tablosundaki "Düzenle" linkinden çağrılır.
  void editAssignment(int unitId) {
    final current = state;
    if (current is! DrugAssignmentIdle) return;

    final selectedGroup = _findGroupForUnit(unitId, current.groups);
    if (selectedGroup == null) return;

    _enterEditing(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: selectedGroup,
      unitId: unitId,
      selectedStepNo: null,
    );
  }

  void _enterEditing({
    required List<DrawerGroup> groups,
    required List<MedicineAssignment> assignments,
    required int cabinId,
    required DrawerGroup selectedGroup,
    required int? unitId,
    required int? selectedStepNo,
  }) {
    _searchDebounceTimer?.cancel();

    final assignment = _findAssignment(unitId: unitId, cabinId: cabinId, assignments: assignments);

    // Daha önce bir ilaç listesi çekilmişse (başka bir göz düzenlenirken)
    // onu aynen kullan — kabin/göz değişimi ilaç listesini etkilemez.
    final medicinePage = _cachedMedicinePage ?? const MedicinePageState(pageSize: _medicinePageSize, isLoading: true);

    state = DrugAssignmentCellSelected(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      assignment: assignment,
      selectedStepNo: selectedStepNo,
      selectedDrug: assignment.medicine,
      minQty: assignment.minQuantityFromBackend.toInt(),
      maxQty: assignment.maxQuantityFromBackend.toInt(),
      criticalQty: assignment.critQuantityFromBackend.toInt(),
      medicinePage: medicinePage,
    );

    // Sadece hiç çekilmemişse (ekrana ilk giriş) fetch et.
    if (_cachedMedicinePage == null) {
      unawaited(_fetchMedicinePage(page: 0, search: ''));
    }
  }

  /// "Vazgeç" — kaydedilmemiş değişiklikler atılır, tabloya dönülür.
  void cancelEditing() {
    _searchDebounceTimer?.cancel();
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    state = DrugAssignmentIdle(groups: current.groups, assignments: current.assignments, cabinId: current.cabinId);
  }

  DrawerGroup? _findGroupForUnit(int? unitId, List<DrawerGroup> groups) {
    if (unitId == null) return null;
    for (final group in groups) {
      if (group.units.any((u) => u.id == unitId)) return group;
    }
    return null;
  }

  // ── İlaç listesi (sayfalı) ───────────────────────────────────────

  Future<void> _fetchMedicinePage({required int page, String? search}) async {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;

    state = current.copyWith(medicinePage: current.medicinePage.copyWith(isLoading: true, error: null));

    final result = await _getMedicines.call(
      PagedQueryParams(
        skip: page * _medicinePageSize,
        take: _medicinePageSize,
        searchQuery: (search?.isEmpty ?? false) ? null : search,
      ),
    );

    // Kullanıcı bu arada Vazgeç dedi ya da başka göze geçti — sonucu at.
    final latest = state;
    if (latest is! DrugAssignmentCellSelected) return;

    state = result.when(
      ok: (response) {
        final updated = latest.medicinePage.copyWith(
          items: response.data ?? [],
          page: page,
          totalCount: response.totalCount ?? 0,
          search: search,
          isLoading: false,
        );
        _cachedMedicinePage = updated; // sonraki göz seçimlerinde reuse edilecek
        return latest.copyWith(medicinePage: updated);
      },
      error: (e) => latest.copyWith(medicinePage: latest.medicinePage.copyWith(isLoading: false, error: e.message)),
    );
  }

  void onMedicineSearchChanged(String? query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      unawaited(_fetchMedicinePage(page: 0, search: query));
    });
  }

  void onMedicineNextPage() {
    _searchDebounceTimer?.cancel();
    final current = state;
    if (current is! DrugAssignmentCellSelected || !current.medicinePage.hasNextPage) return;
    unawaited(_fetchMedicinePage(page: current.medicinePage.page + 1, search: current.medicinePage.search));
  }

  void onMedicinePreviousPage() {
    _searchDebounceTimer?.cancel();
    final current = state;
    if (current is! DrugAssignmentCellSelected || !current.medicinePage.hasPreviousPage) return;
    unawaited(_fetchMedicinePage(page: current.medicinePage.page - 1, search: current.medicinePage.search));
  }

  /// Bu ilaç kabinde (başka bir gözde) zaten atanmış mı — "KABİNDE VAR" rozeti.
  bool isMedicineAlreadyInCabin(DrugAssignmentCellSelected state, Medicine medicine) {
    return state.assignments.any((a) => a.medicine?.id == medicine.id && a.cabinDrawerId != state.selectedUnitId);
  }

  void onDrugSelected(Medicine? drug) {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    state = current.copyWith(selectedDrug: drug);
  }

  // ── Form alanları ────────────────────────────────────────────────

  void onMinQtyChanged(int? value) => _updateFormField(minQty: value);
  void onMaxQtyChanged(int? value) => _updateFormField(maxQty: value);
  void onCriticalQtyChanged(int? value) => _updateFormField(criticalQty: value);

  void _updateFormField({int? minQty, int? maxQty, int? criticalQty}) {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    state = current.copyWith(
      minQty: minQty ?? current.minQty,
      maxQty: maxQty ?? current.maxQty,
      criticalQty: criticalQty ?? current.criticalQty,
    );
  }

  // ── Kaydet / Sil ─────────────────────────────────────────────────

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
      ok: (_) => _refreshAndReturnToIdle(cabinId: current.cabinId, groups: current.groups),
      error: (e) => state = DrugAssignmentError(message: e.message, previous: current),
    );
  }

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
      ok: (_) => _refreshAndReturnToIdle(cabinId: current.cabinId, groups: current.groups),
      error: (e) => state = DrugAssignmentError(message: e.message, previous: current),
    );
  }

  /// Kayıt/silme sonrası atamaları yeniler ve Idle'a (tabloya) döner —
  /// artık aynı gözde kalınmıyor, "Atamalar Tamamla" butonu olmadığı
  /// için işlem bitince ekranın kendisi terk edilmiş sayılır.
  Future<void> _refreshAndReturnToIdle({required int cabinId, required List<DrawerGroup> groups}) async {
    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId),
      error: (e) => DrugAssignmentError(
        message: e.message,
        previous: DrugAssignmentIdle(groups: groups, assignments: const [], cabinId: cabinId),
      ),
    );
  }

  void dismissError() {
    final current = state;
    if (current is! DrugAssignmentError) return;
    state = current.previous;
  }

  // ── Extraction helpers ──────────────────────────────────────────

  MedicineAssignment _findAssignment({
    required int? unitId,
    required int cabinId,
    required List<MedicineAssignment> assignments,
  }) {
    if (unitId == null) return MedicineAssignment.empty(cabinId: cabinId, cabinDrawerId: 0);
    try {
      return assignments.firstWhere((a) => a.cabinDrawerId == unitId);
    } catch (_) {
      return MedicineAssignment.empty(cabinId: cabinId, cabinDrawerId: unitId);
    }
  }

  List<DrawerGroup> _extractGroups(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentLoading(:final groups) => groups,
    DrugAssignmentIdle(:final groups) => groups,
    DrugAssignmentCellSelected(:final groups) => groups,
    DrugAssignmentSaving(:final groups) => groups,
    DrugAssignmentError(:final previous) => _extractGroups(previous),
    _ => const [],
  };

  List<MedicineAssignment> _extractAssignments(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentIdle(:final assignments) => assignments,
    DrugAssignmentCellSelected(:final assignments) => assignments,
    DrugAssignmentSaving(:final assignments) => assignments,
    DrugAssignmentError(:final previous) => _extractAssignments(previous),
    _ => const [],
  };

  int _extractCabinId(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentLoading(:final cabinId) => cabinId,
    DrugAssignmentIdle(:final cabinId) => cabinId,
    DrugAssignmentCellSelected(:final cabinId) => cabinId,
    DrugAssignmentSaving(:final cabinId) => cabinId,
    DrugAssignmentError(:final previous) => _extractCabinId(previous),
    _ => 0,
  };
}
