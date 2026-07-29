// [SWREQ-CLI-MUNLOAD-003] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import 'master_unload_state.dart';

final masterUnloadNotifierProvider = NotifierProvider<MasterUnloadNotifier, MasterUnloadState>(
  MasterUnloadNotifier.new,
);

class MasterUnloadNotifier extends Notifier<MasterUnloadState> {
  late final MasterDrawerOrchestrator _orchestrator;
  int _cabinId = 0;

  GetCabinAssignmentsUseCase get _getAssignments => ref.read(getCabinAssignmentsUseCaseProvider);
  CompleteMasterUnloadUseCase get _completeUnload => ref.read(completeMasterUnloadUseCaseProvider);

  @override
  MasterUnloadState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterUnloadUninitialized();
  }

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    state = const MasterUnloadLoading();
    await _orchestrator.stop();
    await _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final result = await _getAssignments.call();
    result.when(
      ok: (assignments) => state = MasterUnloadSelection(cabinId: _cabinId, medicines: assignments),
      error: (e) => state = MasterUnloadError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterUnloadSelection(cabinId: _cabinId, medicines: const []),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterUnloadSelection) return;
    state = s.copyWith(search: value);
  }

  void toggleUnit(int cabinDrawerId) {
    final s = state;
    if (s is! MasterUnloadSelection) return;

    // Stoğu 0 (veya altı) olan bir ilaç boşaltma için seçilemez — seçili
    // değilken tıklanırsa no-op, zaten seçiliyse (ör. reload sonrası stok
    // 0'a düştüyse) kaldırmaya izin ver.
    final next = Set<int>.from(s.selectedUnitIds);
    final alreadySelected = next.contains(cabinDrawerId);

    if (!alreadySelected) {
      final assignment = s.medicines.firstWhereOrNull((a) => a.cabinDrawerId == cabinDrawerId);
      final hasStock = (assignment?.totalQuantity ?? 0) > 0;
      if (!hasStock) return;
      next.add(cabinDrawerId);
    } else {
      next.remove(cabinDrawerId);
    }

    state = s.copyWith(selectedUnitIds: next);
  }

  /// Bir çekmecenin TÜM ilaçlarını toggle eder — sol taraftaki
  /// CabinDrawerSelectionGuide'a dokunma.
  void toggleDrawer(DrawerGroup group) {
    final s = state;
    if (s is! MasterUnloadSelection) return;

    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    final drawerAssignments = s.medicines.where(
      (a) => a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId),
    );

    // Stoğu 0 olan ilaçlar boşaltma için seçilemez (bkz. toggleUnit) — toplu
    // seçimde de aynı kural: yalnızca stoklu ilaçlar "seçilebilir" kümeye girer.
    final selectableUnitIds = drawerAssignments
        .where((a) => (a.totalQuantity) > 0)
        .map((a) => a.cabinDrawerId!)
        .toSet();
    if (selectableUnitIds.isEmpty) return;

    final allAlreadySelected = selectableUnitIds.every(s.selectedUnitIds.contains);
    final next = Set<int>.from(s.selectedUnitIds);
    if (allAlreadySelected) {
      next.removeAll(selectableUnitIds);
    } else {
      next.addAll(selectableUnitIds);
    }
    state = s.copyWith(selectedUnitIds: next);
  }

  // ── Kuyruk kurulumu ──────────────────────────────────────────────────────

  Future<void> startUnload() async {
    final s = state;
    if (s is! MasterUnloadSelection || !s.canStart) return;

    final jobs = CabinOperationQueueBuilder.build(
      selectedAssignments: s.selectedAssignments,
      config: unloadTargetConfig,
    );
    if (jobs.isEmpty) {
      state = MasterUnloadError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noDrawerFound),
        previousState: s,
      );
      return;
    }

    state = MasterUnloadExecuting(cabinId: s.cabinId, jobs: jobs, currentIndex: 0);
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
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

  //
  // Kübik: currentTargetIndex'teki hedefe yazılır (lid-by-lid — intake/refill
  // ile aynı desen). Birim doz: targetIndex/stepIndex ile herhangi bir
  // hedefin herhangi bir gözüne doğrudan yazılır.

  void onCubicCountChanged(double? value) => _updateCurrentCubicTarget((t) => t.withCubicCount(value ?? 0));
  void onCubicUnloadChanged(double? value) => _updateCurrentCubicTarget((t) => t.withCubicSecondary(value ?? 0));
  void onCubicMiadChanged(DateTime? value) => _updateCurrentCubicTarget((t) => t.withCubicMiad(value));

  void _updateCurrentCubicTarget(CabinOperationTarget Function(CabinOperationTarget) update) {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
    final job = s.currentJob;
    if (job == null) return;
    final ti = s.currentTargetIndex;
    if (ti < 0 || ti >= job.targets.length) return;

    final newTargets = List<CabinOperationTarget>.from(job.targets);
    newTargets[ti] = update(newTargets[ti]);

    final newJobs = List<CabinOperationDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  void onStepCountChanged(int targetIndex, int stepIndex, double? value) =>
      _updateTarget(targetIndex, (t) => t.withStepCount(stepIndex, value ?? 0));

  void onStepUnloadChanged(int targetIndex, int stepIndex, double? value) =>
      _updateTarget(targetIndex, (t) => t.withStepSecondary(stepIndex, value ?? 0));

  void onStepMiadChanged(int targetIndex, int stepIndex, DateTime? value) =>
      _updateTarget(targetIndex, (t) => t.withStepMiad(stepIndex, value));

  void _updateTarget(int targetIndex, CabinOperationTarget Function(CabinOperationTarget) update) {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<CabinOperationTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<CabinOperationDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  // ── Boşaltmayı tamamla ───────────────────────────────────────────────────

  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    state = s.copyWith(isSaving: true);
    final ok = await _saveTarget(target);
    if (state is! MasterUnloadExecuting || !ok) return;

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      final saved = state as MasterUnloadExecuting;
      state = saved.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  /// Tek bir hedefin (kübik göz) params'ını atar. toParamsForTarget kübikte
  /// en fazla 1 elemanlı liste döner.
  Future<bool> _saveTarget(CabinOperationTarget target) async {
    final params = CabinOperationParamsMapper.toParamsForTarget(target, unloadParamsOps);
    if (params.isEmpty) return true; // boş göz — confirmCurrent zaten bu duruma girmeden önce eliyor

    final result = await _completeUnload.call(params);
    var ok = true;
    result.when(
      ok: (_) {},
      error: (e) {
        ok = false;
        final s = state;
        if (s is MasterUnloadExecuting) {
          state = MasterUnloadError(
            failure: CabinApiFailure(message: e.message),
            previousState: s.copyWith(isSaving: false),
            isQueueError: true,
          );
        }
      },
    );
    return ok;
  }

  /// Kübik job içinde sıradaki gözün lid'ine geçer; son gözse çekmece
  /// kapanışını başlatır.
  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextTarget = s.currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
      return;
    }

    state = s.copyWith(currentTargetIndex: nextTarget, isSaving: false);
    await _orchestrator.openCubicLid(job.targets[nextTarget].assignment);
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
    if (s is! MasterUnloadExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik || job.targets.isEmpty) return;
    await _orchestrator.openCubicLid(job.targets[s.currentTargetIndex].assignment);
  }

  /// Aktif çekmece fiziksel olarak kapandı.
  ///   - Birim doz: tüm hedefleri (tüm gözleri) şimdi toplu kaydet.
  ///   - Kübik: kayıt zaten lid bazlı yapıldı → doğrudan sıradaki job.
  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterUnloadExecuting) return;
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
      await _reloadSelectionAfterQueue();
      return;
    }

    state = MasterUnloadExecuting(
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
    if (s is MasterUnloadExecuting) {
      state = MasterUnloadError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is MasterUnloadExecuting) await _reloadSelectionAfterQueue();
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterUnloadError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! MasterUnloadExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CabinOperationJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue();
      return;
    }

    state = MasterUnloadExecuting(cabinId: prev.cabinId, jobs: markedJobs, currentIndex: nextIndex, isSaving: false);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! MasterUnloadError) return;
    final prev = s.previousState;
    await _orchestrator.stop();
    if (prev is MasterUnloadExecuting) {
      await _reloadSelectionAfterQueue();
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is! MasterUnloadError) return;
    state = s.previousState;
  }

  Future<void> _reloadSelectionAfterQueue() async {
    state = const MasterUnloadLoading();
    await _loadMedicines();
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
