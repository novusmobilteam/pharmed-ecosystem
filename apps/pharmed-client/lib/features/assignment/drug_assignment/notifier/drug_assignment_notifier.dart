import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/mixins/pagination_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class DrugAssignmentNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Medicine> {
  final GetMedicineAssignmentsUseCase _getAssignments;
  final CreateMedicineAssignmentUseCase _createAssignment;
  final UpdateMedicineAssignmentUseCase _updateAssignment;
  final DeleteMedicineAssignmentUseCase _deleteAssignment;
  final GetDrugsUseCase _getDrugs;

  DrugAssignmentNotifier({
    required GetMedicineAssignmentsUseCase getAssignments,
    required CreateMedicineAssignmentUseCase createAssignment,
    required UpdateMedicineAssignmentUseCase updateAssignment,
    required DeleteMedicineAssignmentUseCase deleteAssignment,
    required GetDrugsUseCase getDrugs,
  }) : _getAssignments = getAssignments,
       _createAssignment = createAssignment,
       _updateAssignment = updateAssignment,
       _deleteAssignment = deleteAssignment,
       _getDrugs = getDrugs;

  OperationKey fetchAssignmentOp = OperationKey.custom('fetch-assignment');
  OperationKey fetchDrugsOp = OperationKey.custom('fetch-drugs');
  OperationKey submitOp = OperationKey.submit();
  OperationKey deleteOp = OperationKey.delete();

  int _cabinId = 0;
  int get cabinId => _cabinId;

  List<DrawerGroup> _groups = [];
  List<DrawerGroup> get groups => _groups;

  List<MedicineAssignment> _assignments = [];
  List<MedicineAssignment> get assignments => _assignments;

  MedicineAssignment? _selectedAssignment;
  MedicineAssignment? get selectedAssignment => _selectedAssignment;

  DrawerUnit? _selectedUnit;
  DrawerUnit? get selectedUnit => _selectedUnit;

  Medicine? _selectedDrug;
  Medicine? get selectedDrug => _selectedDrug;

  int? _selectedStepNo;
  int? get selectedStepNo => _selectedStepNo;

  int? _minQty;
  int? get minQty => _minQty;

  int? _maxQty;
  int? get maxQty => _maxQty;

  int? _criticalQty;
  int? get criticalQty => _criticalQty;

  bool get isCellSelected => _selectedAssignment != null;
  bool get isAssigned => _selectedAssignment?.id != null;
  int? get selectedUnitId => _selectedAssignment?.cabinDrawerId;

  bool get canSave {
    final drug = _selectedDrug;
    final min = _minQty;
    final crit = _criticalQty;
    final max = _maxQty;

    if (drug == null || min == null || crit == null || max == null) return false;
    if (min <= 0 || crit <= 0 || max <= 0) return false;

    // crit ve max, min'den küçük olamaz
    if (crit < min) return false;
    if (max < min) return false;

    // crit, max'tan büyük olamaz
    if (crit > max) return false;

    return true;
  }

  void init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _groups = data.groups;
    notifyListeners();

    getAssignments();
    unawaited(fetch());
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      op: fetchDrugsOp,
      fetchMethod: (skip, take) => _getDrugs.call(GetDrugsParams(skip: skip, take: take, search: searchQuery)),
    );
  }

  Future<void> getAssignments() async {
    await execute(
      fetchAssignmentOp,
      operation: () => _getAssignments.call(cabinId),
      onData: (assignments) => _assignments = assignments,
    );
  }

  void onCellTap(DrawerUnit unit) {
    if (_selectedUnit?.id == unit.id) {
      clearSelection();
      return;
    }

    final assignment = _findAssignment(unitId: unit.id);

    _selectedUnit = unit;
    _selectedAssignment = assignment;
    _selectedDrug = assignment.medicine;
    _minQty = assignment.minQuantityFromBackend.toInt();
    _maxQty = assignment.maxQuantityFromBackend.toInt();
    _criticalQty = assignment.critQuantityFromBackend.toInt();
    notifyListeners();
  }

  /// Seçimi tamamen temizler — "Vazgeç" butonu bunu çağırır.
  /// index/unit karışıklığına bağlı değildir.
  void clearSelection() {
    _clearCellSelection();
    notifyListeners();
  }

  void _clearCellSelection() {
    _selectedAssignment = null;
    _selectedDrug = null;
    _selectedStepNo = null;
    _minQty = null;
    _maxQty = null;
    _criticalQty = null;
  }

  void onDrugSelected(Medicine? drug) {
    if (!isCellSelected) return;
    _selectedDrug = drug;
    notifyListeners();
  }

  //  Form alanları
  void onMinQtyChanged(int? value) {
    if (!isCellSelected) return;
    _minQty = value;
    notifyListeners();
  }

  void onMaxQtyChanged(int? value) {
    if (!isCellSelected) return;
    _maxQty = value;
    notifyListeners();
  }

  void onCriticalQtyChanged(int? value) {
    if (!isCellSelected) return;
    _criticalQty = value;
    notifyListeners();
  }

  Future<void> saveAssignment({required Function(String? msg) onFailed, required VoidCallback onSuccess}) async {
    final assignment = _selectedAssignment;
    if (assignment == null || !canSave) return;

    final updated = assignment.copyWith(
      medicine: _selectedDrug,
      minQuantity: _minQty,
      maxQuantity: _maxQty,
      criticalQuantity: _criticalQty,
    );

    final result = isAssigned ? _updateAssignment.call(updated) : _createAssignment.call(updated);

    await executeVoid(
      submitOp,
      operation: () => result,
      onFailed: (error) => onFailed(error.message),
      onSuccess: () {
        onSuccess.call();
        getAssignments();
        _clearCellSelection();
      },
    );
  }

  Future<void> deleteAssignment({required Function(String? msg) onFailed, required VoidCallback onSuccess}) async {
    final assignment = _selectedAssignment;
    if (assignment == null || !isAssigned) return;

    await executeVoid(
      deleteOp,
      operation: () => _deleteAssignment.call(_selectedAssignment?.cabinDrawerId ?? 0),
      onFailed: (error) => onFailed(error.message),
      onSuccess: () {
        onSuccess.call();
        getAssignments();
        _clearCellSelection();
      },
    );
  }

  MedicineAssignment _findAssignment({required int? unitId}) {
    if (unitId == null) {
      return MedicineAssignment.empty(cabinId: _cabinId, cabinDrawerId: 0);
    }
    try {
      return _assignments.firstWhere((a) => a.cabinDrawerId == unitId);
    } catch (_) {
      return MedicineAssignment.empty(cabinId: _cabinId, cabinDrawerId: unitId);
    }
  }
}
