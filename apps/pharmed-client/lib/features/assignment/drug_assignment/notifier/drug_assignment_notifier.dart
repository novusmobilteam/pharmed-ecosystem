import 'dart:async';

import 'package:collection/collection.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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

  /// İstasyon geneli kabin kapsamı — kabin seçim adımı yok; sol panelde
  /// hangi kabinin iç yerleşiminin gösterileceği burada tutulur. State'teki
  /// [groups]/[assignments] istasyondaki TÜM işlem yapılabilir kabinleri
  /// kapsar (göz kimlikleri istasyon genelinde tekil).
  final StationCabinScope scope = StationCabinScope();

  @override
  DrugAssignmentUiState build() {
    ref.onDispose(() => _searchDebounceTimer?.cancel());
    return const DrugAssignmentUninitialized();
  }

  Future<void> init(StationCabinsContext ctx) async {
    scope.attach(ctx);
    if (!scope.hasCabins) return;

    state = DrugAssignmentLoading();
    state = await _loadIdle();
  }

  /// Her kabinin atamaları kabin bazlı uç noktadan (paralel) çekilip
  /// birleştirilir — düzenleme akışının beklediği atama şekli korunur.
  Future<DrugAssignmentUiState> _loadIdle() async {
    final groups = scope.allGroups;
    final cabinId = scope.viewedCabinId ?? 0;
    final results = await Future.wait([for (final id in scope.cabinOrder) _getAssignments.call(id)]);

    final assignments = <MedicineAssignment>[];
    String? errorMessage;
    for (final result in results) {
      final message = result.when<String?>(
        ok: (list) {
          assignments.addAll(list);
          return null;
        },
        error: (e) => e.message,
      );
      errorMessage ??= message;
    }

    final idle = DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId);
    final failure = errorMessage;
    return failure == null ? idle : DrugAssignmentError(message: failure, previous: idle);
  }

  /// Kabin şeridinden kabin değiştirildiğinde: düzenleme sürüyorsa iptal
  /// edilir (göz başka kabinde kalırdı), tabloya dönülür.
  void viewCabin(int cabinId) {
    final current = state;
    if (current is DrugAssignmentSaving) return;
    if (!scope.view(cabinId)) return;
    _searchDebounceTimer?.cancel();
    switch (current) {
      case DrugAssignmentIdle s:
        state = s.copyWith();
      case DrugAssignmentCellSelected s:
        state = DrugAssignmentIdle(groups: s.groups, assignments: s.assignments, cabinId: cabinId);
      default:
        break;
    }
  }

  /// Sağ tablonun kabin filtresi.
  void setCabinFilter(int? cabinId) {
    final current = state;
    if (!scope.setFilter(cabinId)) return;
    if (current is DrugAssignmentIdle) state = current.copyWith();
  }

  /// Sol panelden bir göze dokunulduğunda çağrılır (boş ya da dolu fark
  /// etmez). Aynı göze tekrar dokunulursa Idle'a döner (toggle).
  void onCellTap(DrawerUnit unit, int? stepNo) {
    final current = state;
    if (current is! DrugAssignmentIdle && current is! DrugAssignmentCellSelected) return;

    final groups = _extractGroups(current);
    final assignments = _extractAssignments(current);
    final cabinId = _extractCabinId(current);

    final unitId = unit.id;
    if (unitId == null) return;
    final target = AssignmentTarget(unitId: unitId);

    if (current is DrugAssignmentCellSelected && current.target == target && current.selectedStepNo == stepNo) {
      state = DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId);
      return;
    }

    final selectedGroup = _findGroupForUnit(unitId, groups);
    if (selectedGroup == null) return;

    _enterEditing(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      target: target,
      selectedStepNo: stepNo,
    );
  }

  /// Serum kabininde bir avadanlığa dokunulduğunda çağrılır. [shelf] rafın
  /// DrawerUnit'i, [tray] avadanlık (DrawerCell). Aynı avadanlığa tekrar
  /// dokunulursa Idle'a döner.
  ///
  /// Açık Raf'ta [existing] verilirse o atama düzenlenir, verilmezse rafa yeni
  /// ilaç eklenir (view, rafın ilaç listesinden seçtirir).
  void onSerumTrayTap(DrawerUnit shelf, SerumTray tray, {MedicineAssignment? existing}) {
    final current = state;
    if (current is! DrugAssignmentIdle && current is! DrugAssignmentCellSelected) return;

    final unitId = shelf.id;
    final cellId = tray.id;
    if (unitId == null || cellId == null) return;
    final isOpenShelf = tray.size.isOpenShelf;
    final target = AssignmentTarget(
      unitId: unitId,
      cellId: cellId,
      isOpenShelf: isOpenShelf,
      assignmentId: isOpenShelf ? existing?.id : null,
    );

    final groups = _extractGroups(current);
    final assignments = _extractAssignments(current);
    final cabinId = _extractCabinId(current);

    if (current is DrugAssignmentCellSelected && current.target == target) {
      state = DrugAssignmentIdle(groups: groups, assignments: assignments, cabinId: cabinId);
      return;
    }

    final selectedGroup = _findGroupForUnit(unitId, groups);
    if (selectedGroup == null) return;

    _enterEditing(
      groups: groups,
      assignments: assignments,
      cabinId: cabinId,
      selectedGroup: selectedGroup,
      target: target,
      selectedStepNo: null,
    );
  }

  void onAssignmentSearchChanged(String? value) {
    final s = state;
    if (s is! DrugAssignmentIdle) return;
    state = s.copyWith(searchQuery: value);
  }

  /// "MEVCUT ATAMALAR" tablosundaki "Düzenle" linkinden çağrılır.
  void editAssignment(MedicineAssignment assignment) {
    final current = state;
    if (current is! DrugAssignmentIdle) return;

    // Serumda atama avadanlığa aittir; raf id'si cevapta boş gelebileceği
    // için raf, avadanlığın bulunduğu raftan çözülür.
    final serumCellId = assignment.cabinDrawerDetailId ?? assignment.cabinDrawerDetail?.firstOrNull?.id;
    final serumShelfId = serumCellId == null ? null : _findSerumShelfIdForCell(serumCellId, current.groups);

    final cellId = serumShelfId != null ? serumCellId : null;
    final unitId = serumShelfId ?? assignment.cabinDrawerId;
    final selectedGroup = _findGroupForUnit(unitId, current.groups);
    if (unitId == null || selectedGroup == null) return;
    final isOpenShelf = cellId != null && _isOpenShelfCell(cellId, current.groups);

    // Tablodan başka bir kabinin ataması düzenlenince iç yerleşim o kabine geçer.
    scope.view(scope.cabinIdOfSlot(selectedGroup.slot.id) ?? scope.cabinIdOf(assignment));

    _enterEditing(
      groups: current.groups,
      assignments: current.assignments,
      cabinId: current.cabinId,
      selectedGroup: selectedGroup,
      target: AssignmentTarget(
        unitId: unitId,
        cellId: cellId,
        isOpenShelf: isOpenShelf,
        assignmentId: isOpenShelf ? assignment.id : null,
      ),
      selectedStepNo: null,
    );
  }

  void _enterEditing({
    required List<DrawerGroup> groups,
    required List<MedicineAssignment> assignments,
    required int cabinId,
    required DrawerGroup selectedGroup,
    required AssignmentTarget target,
    required int? selectedStepNo,
  }) {
    _searchDebounceTimer?.cancel();

    final assignment = _findAssignment(target: target, assignments: assignments);
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
      target: target,
      assignment: assignment,
      selectedStepNo: selectedStepNo,
      selectedDrug: assignment.medicine,
      minQty: assignment.minQuantity.toInt(),
      maxQty: assignment.maxQuantity.toInt(),
      criticalQty: assignment.criticalQuantity.toInt(),
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

  /// [cellId] avadanlığı bir Açık Raf mı (kabin görselindeki serum yerleşiminden).
  bool _isOpenShelfCell(int cellId, List<DrawerGroup> groups) {
    for (final group in groups.where((g) => g.isSerum)) {
      for (final shelf in group.serumShelves ?? const <SerumShelfLayout>[]) {
        for (final tray in shelf.trays) {
          if (tray.id == cellId) return tray.size.isOpenShelf;
        }
      }
    }
    return false;
  }

  /// Avadanlığın (DrawerCell) bulunduğu serum rafının DrawerUnit id'si.
  int? _findSerumShelfIdForCell(int cellId, List<DrawerGroup> groups) {
    for (final group in groups.where((g) => g.isSerum)) {
      for (final shelf in group.serumShelves ?? const <SerumShelfLayout>[]) {
        if (shelf.trays.any((t) => t.id == cellId)) return shelf.id;
      }
    }
    return null;
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
    return state.assignments.any((a) => a.medicine?.id == medicine.id && !state.target.matches(a));
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
      // Serumda avadanlık hem yeni kayıtta hem güncellemede gönderilir.
      cabinDrawerDetailId: current.target.cellId,
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
    if (!current.canDelete) return;

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

    // Serumda yalnızca seçili avadanlığın ataması silinir (raf bazlı silme
    // raftaki diğer avadanlık atamalarını da silerdi).
    final cellId = current.target.cellId;
    // [#207/#215] Açık Raf'ta birden fazla ilaç varsa avadanlık bazlı silme
    // hepsini siler; atama kendi kimliğiyle (DELETE /CabinDrawrQuantity/{id})
    // silinir. Servisin yalnız bu atamayı silip silmediği sonradan doğrulanır.
    final othersOnShelf = cellId == null
        ? const <MedicineAssignment>[]
        : AssignmentSelection.serumAssignments(
            cellId,
            current.assignments,
          ).where((a) => a.id != current.assignment.id).toList();
    final openShelfShared = current.target.isOpenShelf && othersOnShelf.isNotEmpty;
    final assignmentId = current.assignment.id;
    final result = openShelfShared && assignmentId != null
        ? await _deleteAssignment.byId(assignmentId)
        : cellId != null
        ? await _deleteAssignment.serumTray(cellId)
        : await _deleteAssignment.call(current.assignment.cabinDrawerId ?? 0);

    if (result.isError) {
      final e = result.when(ok: (_) => const UnexpectedException(), error: (e) => e);
      if (openShelfShared) {
        MedLogger.warn(
          unit: 'SW-UNIT-ASSIGNMENT',
          swreq: 'SWREQ-CLI-ASSIGN-OPEN-SHELF',
          message: 'Açık raf tekil atama silme servisten reddedildi',
          context: {'assignmentId': current.assignment.id, 'cabinDrawerId': current.assignment.cabinDrawerId},
        );
      }
      state = DrugAssignmentError(message: e.message, previous: current);
      return;
    }

    final next = await _loadIdle();
    final removedOthers = openShelfShared ? _missingAfterDelete(othersOnShelf, next) : 0;
    if (removedOthers > 0 && next is DrugAssignmentIdle) {
      state = DrugAssignmentError(
        message: contextlessL10n().cabinOperation_openShelfDeleteRemovedOthersWarning(removedOthers),
        previous: next,
      );
      return;
    }
    state = next;
  }

  /// [#207] Silmeden sonra açık raftaki diğer atamalardan kaç tanesi kayboldu?
  /// > 0 → servis tekil silme yapmıyor; backend'den yeni servis gerekir.
  int _missingAfterDelete(List<MedicineAssignment> others, DrugAssignmentUiState next) {
    final remaining = _extractAssignments(next).map((a) => a.id).toSet();
    final missing = others.where((a) => !remaining.contains(a.id)).length;
    if (missing > 0) {
      MedLogger.ruleRejected(
        unit: 'SW-UNIT-ASSIGNMENT',
        swreq: 'SWREQ-CLI-ASSIGN-OPEN-SHELF',
        rule: 'OPEN_SHELF_DELETE_REMOVED_OTHERS',
        message: 'Açık raf silme diğer ilaçların atamalarını da sildi',
        context: {'silinenDiger': missing, 'digerIdler': others.map((a) => a.id).toList()},
      );
    }
    return missing;
  }

  /// Kayıt/silme sonrası atamaları yeniler ve Idle'a (tabloya) döner —
  /// artık aynı gözde kalınmıyor, "Atamalar Tamamla" butonu olmadığı
  /// için işlem bitince ekranın kendisi terk edilmiş sayılır.
  Future<void> _refreshAndReturnToIdle({required int cabinId, required List<DrawerGroup> groups}) async {
    state = await _loadIdle();
  }

  void dismissError() {
    final current = state;
    if (current is! DrugAssignmentError) return;
    state = current.previous;
  }

  // ── Extraction helpers ──────────────────────────────────────────

  MedicineAssignment _findAssignment({required AssignmentTarget target, required List<MedicineAssignment> assignments}) {
    return assignments.firstWhereOrNull(target.matches) ??
        MedicineAssignment.empty(cabinDrawerId: target.unitId, cabinDrawerDetailId: target.cellId);
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
