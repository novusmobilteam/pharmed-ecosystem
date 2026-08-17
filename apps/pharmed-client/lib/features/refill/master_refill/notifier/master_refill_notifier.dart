import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/cabin_drawer_queue_mixin.dart';

class MasterRefillNotifier extends ChangeNotifier with ApiRequestMixin, CabinDrawerQueueMixin<CabinOperationTarget> {
  MasterRefillNotifier({
    required MasterDrawerOrchestrator orchestrator,
    required GetCabinAssignmentsWithCabinUseCase getAssignments,
    required RefillMasterCabinUseCase refillCabin,
  }) : _orchestrator = orchestrator,
       _getAssignments = getAssignments,
       _refillCabin = refillCabin {
    _orchestrator.init(onStageChange: onDrawerStage);
    _orchestrator.addListener(notifyQueueListeners);
  }

  final MasterDrawerOrchestrator _orchestrator;
  final GetCabinAssignmentsWithCabinUseCase _getAssignments;
  final RefillMasterCabinUseCase _refillCabin;

  @override
  MasterDrawerOrchestrator get orchestrator => _orchestrator;

  final OperationKey fetchAssignmentOp = OperationKey.custom('fetch-assignment');
  final OperationKey submitTargetOp = OperationKey.custom('submit-target');

  @override
  void dispose() {
    _orchestrator.removeListener(notifyQueueListeners);
    markQueueDisposed();
    _orchestrator.dispose();
    super.dispose();
  }

  /// init() ile kurulan, o an üzerinde çalışılan kabinin id'si.
  int _cabinId = 0;
  int get cabinId => _cabinId;

  /// Kabindeki fiziksel çekmece/göz yerleşimi — init() ile bir kez yüklenir.
  List<DrawerGroup> _groups = [];
  List<DrawerGroup> get groups => _groups;

  /// Kabine atanmış tüm ilaç-göz eşleşmeleri.
  List<MedicineAssignment> _assignments = [];
  List<MedicineAssignment> get assignments => _assignments;

  /// Kullanıcının dolum için işaretlediği fiziksel göz (unit) id'lerinin kümesi.
  Set<int> _selectedUnitIds = {};
  Set<int> get selectedUnitIds => _selectedUnitIds;

  /// Sağ paneldeki arama kutusunun mevcut değeri.
  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  /// Arama sorgusuna göre filtrelenmiş atama listesi.
  List<MedicineAssignment> get visibleAssignments {
    final q = _searchQuery?.trim().toLowerCase();
    if (q == null || q.isEmpty) return _assignments;
    return _assignments.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  /// Seçim fazındayız (mixin'in isExecuting'i false).
  bool get isSelecting => !isExecuting;

  /// Seçim fazındayız VE gösterilen bir hata yok.
  bool get isActivelySelecting => isSelecting && errorFailure == null;

  /// Atama listesi ilk kez ya da kuyruk sonrası yeniden yükleniyor.
  bool get isFetchingAssignments => isLoading(fetchAssignmentOp);

  bool get canStart => _selectedUnitIds.isNotEmpty;

  bool get isAllSelected => _assignments.isNotEmpty && _assignments.every(isAssignmentSelected);

  List<MedicineAssignment> get selectedAssignments =>
      _assignments.where((a) => _selectedUnitIds.contains(a.cabinDrawerId)).toList();

  int? _assignedUnitId(MedicineAssignment a) => a.cabinDrawerId ?? a.drawerUnit?.id;

  bool _isUnitAssigned(int unitId) => _assignments.any((a) => _assignedUnitId(a) == unitId);

  bool isAssignmentSelected(MedicineAssignment assignment) {
    final id = _assignedUnitId(assignment);
    return id != null && _selectedUnitIds.contains(id);
  }

  @override
  Future<void> onQueueFinished() => _fetchAssignments();

  @override
  void onLidFailed(MasterDrawerFailure failure, {String? detail}) {
    MedLogger.warn(
      unit: 'MasterRefill',
      swreq: 'SWREQ-CLI-MREFILL-002',
      message: 'Kübik kapak açma reddedildi',
      context: {'failure': failure.name, 'detail': detail},
    );
  }

  @override
  void onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    if (failure == MasterDrawerFailure.unexpectedlyClosed) {
      unawaited(skipCurrentJobAndAdvance());
      return;
    }
    super.onDrawerFailed(failure, detail: detail);
  }

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _groups = data.groups;
    notifyListeners();

    unawaited(_fetchAssignments());
  }

  Future<void> _fetchAssignments() async {
    await execute(
      fetchAssignmentOp,
      operation: () => _getAssignments.call(_cabinId),
      onData: (assignments) {
        _assignments = assignments;
        _selectedUnitIds = {};
        _searchQuery = null;
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String? value) {
    if (!isActivelySelecting) return;
    _searchQuery = value;
    notifyListeners();
  }

  void _toggleUnitId(int id) {
    final next = Set<int>.from(_selectedUnitIds);
    next.contains(id) ? next.remove(id) : next.add(id);
    _selectedUnitIds = next;
    notifyListeners();
  }

  void onCellTap(DrawerUnit unit) {
    if (!isActivelySelecting) return;
    final id = unit.id;
    if (id == null || !_isUnitAssigned(id)) return;
    _toggleUnitId(id);
  }

  void onAssignmentTap(MedicineAssignment assignment) {
    if (!isActivelySelecting) return;
    final id = _assignedUnitId(assignment);
    if (id == null) return;
    _toggleUnitId(id);
  }

  void onDrawerTap(DrawerGroup group) {
    if (!isActivelySelecting) return;

    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    final drawerAssignmentUnitIds = _assignments
        .where((a) {
          final unitId = _assignedUnitId(a);
          return unitId != null && unitIdsInGroup.contains(unitId);
        })
        .map((a) => _assignedUnitId(a)!)
        .toSet();
    if (drawerAssignmentUnitIds.isEmpty) return;

    final allAlreadySelected = drawerAssignmentUnitIds.every(_selectedUnitIds.contains);
    final next = Set<int>.from(_selectedUnitIds);
    if (allAlreadySelected) {
      next.removeAll(drawerAssignmentUnitIds);
    } else {
      next.addAll(drawerAssignmentUnitIds);
    }
    _selectedUnitIds = next;
    notifyListeners();
  }

  void toggleSelectAll() {
    if (!isActivelySelecting) return;
    _selectedUnitIds = isAllSelected ? {} : _assignments.map(_assignedUnitId).whereType<int>().toSet();
    notifyListeners();
  }

  Future<void> startRefill() async {
    if (!isActivelySelecting || !canStart) return;

    final targets = selectedAssignments.map((a) => CabinOperationTarget.fromAssignment(a, refillTargetConfig)).toList();
    final result = CabinDrawerQueueBuilder.build<CabinOperationTarget>(items: targets);

    if (result.jobs.isEmpty) {
      reportError(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterRefill',
        swreq: 'SWREQ-CLI-MREFILL-002',
        message: 'Bazı seçimler fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {
          'skippedCount': result.skipped.length,
          'skippedMedicineIds': result.skipped.map((t) => t.assignment.medicine?.id).toList(),
        },
      );
    }

    await startQueue(result.jobs);
  }

  @override
  Future<Result<void>> submitTarget(CabinOperationTarget target) {
    final params = CabinOperationParamsMapper.toParamsForTarget(target, refillParamsOps);
    return executeAsResult(submitTargetOp, operation: () => _refillCabin(params));
  }

  // Kübik girdileri
  void onCubicCountChanged(double v) => updateCurrentTarget((t) => t.withCubicCount(v));
  void onCubicFillingChanged(double v) => updateCurrentTarget((t) => t.withCubicSecondary(v));
  void onCubicMiadChanged(DateTime? d) => updateCurrentTarget((t) => t.withCubicMiad(d));

  // Birim doz girdileri
  void onStepCountChanged(int index, double v) => updateCurrentTarget((t) => t.withStepCount(index, v));
  void onStepFillingChanged(int index, double v) => updateCurrentTarget((t) => t.withStepSecondary(index, v));
  void onStepMiadChanged(int index, DateTime? d) => updateCurrentTarget((t) => t.withStepMiad(index, d));
  void onSingleMiadChanged(DateTime? d) => updateCurrentTarget((t) => t.withSingleMiad(d));
}
