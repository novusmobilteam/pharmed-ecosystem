// [SWREQ-CLI-MDESTRUCTION-002] [IEC 62304 §5.5]
// Kabinden seçilen ilaçların imha edildiği akışı yöneten notifier —
// MasterCensusNotifier ile BİREBİR AYNI donanım sıralaması ve target/job
// yapısı (çekmece aç → gözleri say → kapat → sıradaki çekmece). Farklar:
//   - secondary alan yok (config: censusTargetConfig, hasSecondaryField=false)
//   - complete çağrısı CabinOperationParamsMapper DEĞİL, DestructionParamsMapper
//     kullanır — backend burada donanım adresi değil CabinStock.id bekliyor
//     (bkz. DestructionParamsMapper).
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import '../../auth/auth.dart';
import 'destruction_state.dart';

final destructionNotifierProvider = NotifierProvider<DestructionNotifier, DestructionState>(DestructionNotifier.new);

class DestructionNotifier extends Notifier<DestructionState> {
  late final MasterDrawerOrchestrator _orchestrator;

  GetMasterDisposableMaterialsUseCase get _getAssignments => ref.read(getMasterDisposableMaterialsUseCaseProvider);
  MasterDisposeMaterialUseCase get _completeDispose => ref.read(masterDisposeMaterialUseCaseProvider);

  @override
  DestructionState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const DestructionUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    final cabinId = data.cabinId;
    state = const DestructionLoading();

    final result = await _getAssignments();
    result.when(
      ok: (assignments) {
        state = DestructionSelection(cabinId: cabinId, medicines: assignments);
      },
      error: (e) {
        state = DestructionError(
          failure: CabinApiFailure(message: e.message),
          previousState: DestructionSelection(cabinId: cabinId, medicines: const [], selectedUnitIds: const {}),
        );
      },
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! DestructionSelection) return;
    state = s.copyWith(search: value);
  }

  void toggleUnit(int cabinDrawerId) {
    final s = state;
    if (s is! DestructionSelection) return;
    final next = Set<int>.from(s.selectedUnitIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    state = s.copyWith(selectedUnitIds: next);
  }

  void toggleDrawer(DrawerGroup group) {
    final s = state;
    if (s is! DestructionSelection) return;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;

    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();

    // Sadece bu çekmecedeki VE kullanıcının imha etmeye yetkili olduğu assignment'lar
    final drawerAssignmentUnitIds = s.medicines
        .where(
          (a) =>
              a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId) && _isDestroyable(a, currentUserId),
        )
        .map((a) => a.cabinDrawerId!)
        .toSet();
    if (drawerAssignmentUnitIds.isEmpty) return;

    final allAlreadySelected = drawerAssignmentUnitIds.every(s.selectedUnitIds.contains);
    final next = Set<int>.from(s.selectedUnitIds);
    if (allAlreadySelected) {
      next.removeAll(drawerAssignmentUnitIds);
    } else {
      next.addAll(drawerAssignmentUnitIds);
    }
    state = s.copyWith(selectedUnitIds: next);
  }

  /// Kullanıcının bu ilacı imha etmeye yetkili olup olmadığını kontrol eder.
  /// Drug değilse (örn. MedicalConsumable) kısıt uygulanmaz.
  bool _isDestroyable(MedicineAssignment a, int? currentUserId) {
    final medicine = a.medicine;
    if (medicine is! Drug || currentUserId == null) return true;
    return medicine.destroyableUsers.any((u) => u.id == currentUserId);
  }

  Future<void> startDestruction() async {
    final s = state;
    if (s is! DestructionSelection || !s.canStart) return;

    final jobs = CabinOperationQueueBuilder.build(
      selectedAssignments: s.selectedAssignments,
      config: destructionTargetConfig,
    );
    if (jobs.isEmpty) return;

    state = DestructionExecuting(cabinId: s.cabinId, jobs: jobs, currentIndex: 0);
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! DestructionExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) return;
    final job = s.jobs[jobIndex];

    state = s.copyWith(
      jobs: _withStatus(s.jobs, jobIndex, CabinOperationJobStatus.active),
      currentIndex: jobIndex,
      currentTargetIndex: targetIndex,
      isSaving: false,
    );

    final openAssignment = job.isKubik ? job.representativeAssignment : job.targets[targetIndex].assignment;
    await _orchestrator.open(assignment: openAssignment);
  }

  void onCubicSecondaryChanged(int targetIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withCubicSecondary(value));

  void onStepSecondaryChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepSecondary(stepIndex, value));

  void _updateTarget(int targetIndex, CabinOperationTarget Function(CabinOperationTarget) update) {
    final s = state;
    if (s is! DestructionExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<CabinOperationTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<CabinOperationDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! DestructionExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    state = s.copyWith(isSaving: true);
    final ok = await _saveTarget(target);
    final saved = state;
    if (saved is! DestructionExecuting) return;
    if (!ok) return;

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      state = saved.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  Future<bool> _saveTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return true;

    final params = DestructionParamsMapper.toParamsForTarget(target);
    if (params.isEmpty) return true; // stockId çözülemedi — API'ye boş istek gitmez

    final result = await _completeDispose(params);
    final saved = state;
    if (saved is! DestructionExecuting) return false;

    var ok = true;
    result.when(
      ok: (_) {},
      error: (e) {
        ok = false;
        state = DestructionError(
          failure: CabinApiFailure(message: e.message),
          previousState: saved.copyWith(isSaving: false),
          isQueueError: true,
        );
      },
    );
    return ok;
  }

  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! DestructionExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextTarget = s.currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
      return;
    }

    state = s.copyWith(currentTargetIndex: nextTarget, isSaving: false);
    final cellAssignment = job.targets[nextTarget].assignment;
    await _orchestrator.openCubicLid(cellAssignment);
  }

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerOpened():
        _onDrawerOpened();
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail: detail);
      default:
        break;
    }
  }

  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! DestructionExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik) return;
    if (job.targets.isEmpty) return;

    final firstCell = job.targets[s.currentTargetIndex].assignment;
    await _orchestrator.openCubicLid(firstCell);
  }

  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! DestructionExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      final nextTarget = s.currentTargetIndex + 1;
      if (nextTarget < job.targets.length) {
        await _orchestrator.stop();
        await _openJobAt(jobIndex: s.currentIndex, targetIndex: nextTarget);
        return;
      }
    }

    final completedJobs = _withStatus(s.jobs, s.currentIndex, CabinOperationJobStatus.completed);
    final nextIndex = s.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= s.jobs.length) {
      await _reloadSelectionAfterQueue(s.cabinId);
      return;
    }

    state = DestructionExecuting(
      cabinId: s.cabinId,
      jobs: completedJobs,
      currentIndex: nextIndex,
      currentTargetIndex: 0,
      isSaving: false,
    );
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  void _onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    final s = state;
    if (s is DestructionExecuting) {
      state = DestructionError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is DestructionExecuting) {
      await _reloadSelectionAfterQueue(s.cabinId);
    }
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! DestructionError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! DestructionExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CabinOperationJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue(prev.cabinId);
      return;
    }

    state = DestructionExecuting(cabinId: prev.cabinId, jobs: markedJobs, currentIndex: nextIndex, isSaving: false);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! DestructionError) return;
    final prev = s.previousState;
    await _orchestrator.stop();

    if (prev is DestructionExecuting) {
      await _reloadSelectionAfterQueue(prev.cabinId);
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is DestructionError) state = s.previousState;
  }

  Future<void> _reloadSelectionAfterQueue(int cabinId) async {
    state = const DestructionLoading();
    final result = await _getAssignments();
    result.when(
      ok: (assignments) => state = DestructionSelection(
        cabinId: cabinId,
        medicines: assignments,
        //selectedUnitIds: assignments.map((a) => a.cabinDrawerId).whereType<int>().toSet(),
      ),
      error: (e) => state = DestructionError(
        failure: CabinApiFailure(message: e.message),
        previousState: DestructionSelection(cabinId: cabinId, medicines: const [], selectedUnitIds: const {}),
      ),
    );
  }

  List<CabinOperationDrawerJob> _withStatus(
    List<CabinOperationDrawerJob> jobs,
    int index,
    CabinOperationJobStatus status,
  ) {
    final next = List<CabinOperationDrawerJob>.from(jobs);
    next[index] = next[index].copyWith(status: status);
    return next;
  }
}
