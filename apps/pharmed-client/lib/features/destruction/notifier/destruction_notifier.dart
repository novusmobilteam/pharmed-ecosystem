// [SWREQ-CLI-MDESTRUCTION-002] [IEC 62304 §5.5]
// Kabinden seçilen ilaçların imha edildiği akışı yöneten notifier —
// refill/census/unload ile ORTAK CabinDrawerQueueMixin kullanır. Farklar:
//   - secondary alan yok (config: destructionTargetConfig, hasSecondaryField=false)
//   - complete çağrısı CabinOperationParamsMapper DEĞİL, DestructionParamsMapper
//     kullanır — backend burada donanım adresi değil CabinStock.id bekliyor.
//   - Seçim, kullanıcının imha yetkisine göre kısıtlanır (bkz. _isDestroyable).
//
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/mixins/cabin_drawer_queue_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import '../../../../core/hardware/hardware.dart';
import '../../auth/notifier/auth_notifier.dart';

class DestructionNotifier extends ChangeNotifier with ApiRequestMixin, CabinDrawerQueueMixin<CabinOperationTarget> {
  DestructionNotifier({
    required MasterDrawerOrchestrator orchestrator,
    required GetMasterDisposableMaterialsUseCase getAssignments,
    required MasterDisposeMaterialUseCase completeDispose,
    required AuthNotifier authNotifier,
  }) : _orchestrator = orchestrator,
       _getAssignments = getAssignments,
       _completeDispose = completeDispose,
       _authNotifier = authNotifier {
    _orchestrator.init(onStageChange: onDrawerStage);
    _orchestrator.addListener(notifyQueueListeners);
  }

  final MasterDrawerOrchestrator _orchestrator;
  final GetMasterDisposableMaterialsUseCase _getAssignments;
  final MasterDisposeMaterialUseCase _completeDispose;
  final AuthNotifier _authNotifier;

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

  // ── Kabin kimliği ────────────────────────────────────────────────

  int _cabinId = 0;
  int get cabinId => _cabinId;

  // ── Seçim fazı verisi ────────────────────────────────────────────

  List<MedicineAssignment> _medicines = [];
  List<MedicineAssignment> get medicines => _medicines;

  Set<int> _selectedUnitIds = {};
  Set<int> get selectedUnitIds => _selectedUnitIds;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  List<MedicineAssignment> get visibleMedicines {
    final q = _searchQuery?.trim().toLowerCase();
    if (q == null || q.isEmpty) return _medicines;
    return _medicines.where((a) {
      final name = a.medicine?.name?.toLowerCase() ?? '';
      final barcode = a.medicine?.barcode?.toLowerCase() ?? '';
      return name.contains(q) || barcode.contains(q);
    }).toList();
  }

  bool get isSelecting => !isExecuting;
  bool get isActivelySelecting => isSelecting && errorFailure == null;
  bool get isFetchingAssignments => isLoading(fetchAssignmentOp);

  bool get canStart => _selectedUnitIds.isNotEmpty;

  List<MedicineAssignment> get selectedAssignments =>
      _medicines.where((a) => _selectedUnitIds.contains(a.cabinDrawerId)).toList();

  @override
  Future<void> onQueueFinished() => _loadMedicines();

  @override
  void onLidFailed(MasterDrawerFailure failure, {String? detail}) {
    MedLogger.warn(
      unit: 'Destruction',
      swreq: 'SWREQ-CLI-MDESTRUCTION-002',
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

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    unawaited(_loadMedicines());
  }

  Future<void> _loadMedicines() async {
    await execute(
      fetchAssignmentOp,
      operation: () => _getAssignments(),
      onData: (assignments) {
        _medicines = assignments;
        _selectedUnitIds = {};
        _searchQuery = null;
        notifyListeners();
      },
    );
  }

  // ── Seçim ────────────────────────────────────────────────────────

  void onSearchChanged(String value) {
    if (!isActivelySelecting) return;
    _searchQuery = value;
    notifyListeners();
  }

  void toggleUnit(int cabinDrawerId) {
    if (!isActivelySelecting) return;
    final next = Set<int>.from(_selectedUnitIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    _selectedUnitIds = next;
    notifyListeners();
  }

  void toggleDrawer(DrawerGroup group) {
    if (!isActivelySelecting) return;

    final currentUserId = _authNotifier.currentUser?.id;
    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();

    // Sadece bu çekmecedeki VE kullanıcının imha etmeye yetkili olduğu assignment'lar
    final drawerAssignmentUnitIds = _medicines
        .where(
          (a) =>
              a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId) && _isDestroyable(a, currentUserId),
        )
        .map((a) => a.cabinDrawerId!)
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

  /// Kullanıcının bu ilacı imha etmeye yetkili olup olmadığını kontrol eder.
  /// Drug değilse (örn. MedicalConsumable) kısıt uygulanmaz.
  bool _isDestroyable(MedicineAssignment a, int? currentUserId) {
    final medicine = a.medicine;
    if (medicine is! Drug || currentUserId == null) return true;
    return medicine.destroyableUsers.any((u) => u.id == currentUserId);
  }

  // ── Seçim fazından Yürütme fazına geçiş ──────────────────────────

  Future<void> startDestruction() async {
    if (!isActivelySelecting || !canStart) return;

    final targets = selectedAssignments
        .map((a) => CabinOperationTarget.fromAssignment(a, destructionTargetConfig))
        .toList();
    final result = CabinDrawerQueueBuilder.build<CabinOperationTarget>(items: targets);

    if (result.jobs.isEmpty) {
      reportError(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'Destruction',
        swreq: 'SWREQ-CLI-DESTRUCTION-002',
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
  Future<Result<void>> submitTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return const Result.ok(null);

    final params = DestructionParamsMapper.toParamsForTarget(target);
    if (params.isEmpty) return const Result.ok(null); // stockId çözülemedi — API'ye boş istek gitmez

    return executeAsResult(submitTargetOp, operation: () => _completeDispose(params));
  }

  // Kübik/birim doz girdileri — sadece "secondary" (imha miktarı) var,
  // count/miad kullanıcı tarafından girilmiyor (destructionTargetConfig
  // hasSecondaryField=true, ama primary alan ayrıca girilmiyor).
  void onCubicSecondaryChanged(double v) => updateCurrentTarget((t) => t.withCubicSecondary(v));
  void onStepSecondaryChanged(int index, double v) => updateCurrentTarget((t) => t.withStepSecondary(index, v));
}
