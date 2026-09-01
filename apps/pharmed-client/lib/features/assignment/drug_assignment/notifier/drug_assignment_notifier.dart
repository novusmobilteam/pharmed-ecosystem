import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';
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
  GetEquivalentMedicinesUseCase get _getEquivalentMedicines => ref.read(getEquivalentMedicinesUseCaseProvider);

  static const _medicinePageSize = 15;
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

  Future<void> init(CabinRouteContext ctx) async {
    final cabinId = ctx.cabin?.id;
    final groups = ctx.cabinData?.groups;
    if (cabinId == null || groups == null) {
      return;
    }

    state = DrugAssignmentLoading();

    final result = await _getAssignments.call(cabinId);

    state = result.when(
      ok: (assignments) => DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId),
      error: (e) => DrugAssignmentError(
        message: e.message,
        previous: DrugAssignmentIdle(groups: groups, assignments: const [], cabinId: cabinId),
      ),
    );
  }

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
    final hasExistingAssignment = assignment.id != null;

    final medicinePage = _cachedMedicinePage ?? const MedicinePageState(pageSize: _medicinePageSize, isLoading: true);

    // Boş gözde muadil kavramı anlamsız (referans ilaç yok) — doğrudan Tüm İlaçlar.
    // Atanmış gözde varsayılan sekme Muadil İlaçlar.
    final initialMode = hasExistingAssignment ? MedicineListMode.equivalent : MedicineListMode.all;

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
      equivalentMedicinePage: const MedicinePageState(pageSize: _medicinePageSize),
      listMode: initialMode,
    );

    if (initialMode == MedicineListMode.equivalent) {
      unawaited(_fetchEquivalentPage(page: 0, search: ''));
    } else if (_cachedMedicinePage == null) {
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

  void onListModeChanged(int index) {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;

    final mode = MedicineListMode.values[index];
    if (mode == current.listMode) return;

    state = current.copyWith(listMode: mode);

    // Bu sekmeye ilk kez geçiliyorsa (henüz veri çekilmemiş) lazy fetch.
    if (mode == MedicineListMode.all) {
      _fetchMedicinePage(page: 0, search: '');
    } else if (mode == MedicineListMode.equivalent) {
      _fetchEquivalentPage(page: 0, search: '');
    }
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

  Future<void> _fetchEquivalentPage({required int page, String? search}) async {
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;

    final medicineId = current.assignment.medicine?.id;
    if (medicineId == null) return;

    state = current.copyWith(
      equivalentMedicinePage: current.equivalentMedicinePage.copyWith(isLoading: true, error: null),
    );

    final result = await _getEquivalentMedicines.execute(
      medicineId,
      params: PagedQueryParams(
        skip: page * _medicinePageSize,
        take: _medicinePageSize,
        searchQuery: (search?.isEmpty ?? false) ? null : search,
      ),
    );

    final latest = state;
    if (latest is! DrugAssignmentCellSelected) return;

    state = result.when(
      ok: (response) => latest.copyWith(
        equivalentMedicinePage: latest.equivalentMedicinePage.copyWith(
          items: response.data ?? [],
          page: page,
          totalCount: response.totalCount ?? 0,
          search: search,
          isLoading: false,
        ),
      ),
      error: (e) => latest.copyWith(
        equivalentMedicinePage: latest.equivalentMedicinePage.copyWith(isLoading: false, error: e.message),
      ),
    );
  }

  void onSearchChanged(String? query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      final current = state;
      if (current is! DrugAssignmentCellSelected) return;
      if (current.listMode == MedicineListMode.equivalent) {
        unawaited(_fetchEquivalentPage(page: 0, search: query));
      } else {
        unawaited(_fetchMedicinePage(page: 0, search: query));
      }
    });
  }

  void onNextPage() {
    _searchDebounceTimer?.cancel();
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    final page = current.selectedPage;
    if (!page.hasNextPage) return;
    current.listMode == MedicineListMode.equivalent
        ? unawaited(_fetchEquivalentPage(page: page.page + 1, search: page.search))
        : unawaited(_fetchMedicinePage(page: page.page + 1, search: page.search));
  }

  void onPreviousPage() {
    _searchDebounceTimer?.cancel();
    final current = state;
    if (current is! DrugAssignmentCellSelected) return;
    final page = current.selectedPage;
    if (!page.hasPreviousPage) return;
    current.listMode == MedicineListMode.equivalent
        ? unawaited(_fetchEquivalentPage(page: page.page - 1, search: page.search))
        : unawaited(_fetchMedicinePage(page: page.page - 1, search: page.search));
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
    DrugAssignmentIdle(:final cabinId) => cabinId,
    DrugAssignmentCellSelected(:final cabinId) => cabinId,
    DrugAssignmentSaving(:final cabinId) => cabinId,
    DrugAssignmentError(:final previous) => _extractCabinId(previous),
    _ => 0,
  };
}
