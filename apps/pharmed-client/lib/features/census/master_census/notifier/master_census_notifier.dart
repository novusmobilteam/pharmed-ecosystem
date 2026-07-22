// [SWREQ-CLI-MCENSUS-002] [IEC 62304 §5.5]
// Sayım akışını yöneten notifier — MasterRefillNotifier ile BİREBİR AYNI
// donanım sıralaması (çekmece aç → gözleri say → kapat → sıradaki çekmece).
// Farklar sadece: fillingQuantity yok, tek SKT (singleMiad) toggle'ı yok
// (sayımda SKT her zaman per-cell).
//
// CensusQueueBuilder ve MasterCensusParams/CompleteMasterCensusUseCase artık
// gerçek kaynaklara göre bağlandı.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';

import 'master_census_state.dart';

final masterCensusNotifierProvider = NotifierProvider<MasterCensusNotifier, MasterCensusState>(
  MasterCensusNotifier.new,
);

class MasterCensusNotifier extends Notifier<MasterCensusState> {
  late final MasterDrawerOrchestrator _orchestrator;

  GetCabinAssignmentsUseCase get _getAssignments => ref.read(getCabinAssignmentsUseCaseProvider);
  CompleteMasterCensusUseCase get _completeCensus => ref.read(completeMasterCensusUseCaseProvider);

  @override
  MasterCensusState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterCensusUninitialized();
  }

  /// Ekran açılışında view tarafından çağrılır (initState + addPostFrameCallback).
  Future<void> init(CabinVisualizerData data) async {
    final cabinId = data.cabinId;
    state = const MasterCensusLoading();

    final result = await _getAssignments();
    result.when(
      ok: (assignments) {
        final allUnitIds = assignments.map((a) => a.cabinDrawerId).whereType<int>().toSet();
        state = MasterCensusSelection(
          cabinId: cabinId,
          medicines: assignments,
          // Varsayılan: hepsi seçili (tüm kabin sayımı) — refill'in aksine.
          selectedUnitIds: allUnitIds,
        );
      },
      error: (e) {
        state = MasterCensusError(
          failure: CabinApiFailure(message: e.message),
          previousState: MasterCensusSelection(cabinId: cabinId, medicines: const [], selectedUnitIds: const {}),
        );
      },
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterCensusSelection) return;
    state = s.copyWith(search: value);
  }

  /// Tek bir ilacı (unit'i) toggle eder — CabinSelectionGridCard'a dokunma.
  void toggleUnit(int cabinDrawerId) {
    final s = state;
    if (s is! MasterCensusSelection) return;
    final next = Set<int>.from(s.selectedUnitIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    state = s.copyWith(selectedUnitIds: next);
  }

  /// Bir çekmecenin TÜM ilaçlarını toggle eder — sol taraftaki
  /// CabinDrawerSelectionGuide'a dokunma.
  void toggleDrawer(DrawerGroup group) {
    final s = state;
    if (s is! MasterCensusSelection) return;

    final unitIdsInGroup = group.units.map((u) => u.id).whereType<int>().toSet();
    final drawerAssignmentUnitIds = s.medicines
        .where((a) => a.cabinDrawerId != null && unitIdsInGroup.contains(a.cabinDrawerId))
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

  /// "Sayımı Başlat" — seçimlerden kuyruk üretir, ilk çekmeceyi açar.
  Future<void> startCensus() async {
    final s = state;
    if (s is! MasterCensusSelection || !s.canStart) return;

    final jobs = CensusQueueBuilder.build(s.selectedAssignments);
    if (jobs.isEmpty) return;

    state = MasterCensusExecuting(cabinId: s.cabinId, jobs: jobs, currentIndex: 0);
    await _openCurrentJob();
  }

  Future<void> _openCurrentJob() async {
    final s = state;
    if (s is! MasterCensusExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    state = s.copyWith(jobs: _withStatus(s.jobs, s.currentIndex, CensusJobStatus.active), currentTargetIndex: 0);

    await _orchestrator.open(assignment: job.representativeAssignment);
  }

  // Kübik çekmece
  void onCubicCountChanged(int targetIndex, double value) => _updateTarget(targetIndex, (t) => t.withCubicCount(value));

  void onCubicMiadChanged(int targetIndex, DateTime? date) => _updateTarget(targetIndex, (t) => t.withCubicMiad(date));

  // Birim doz çekmece
  void onStepCountChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepCount(stepIndex, value));

  void onStepMiadChanged(int targetIndex, int stepIndex, DateTime? date) =>
      _updateTarget(targetIndex, (t) => t.withStepMiad(stepIndex, date));

  void _updateTarget(int targetIndex, CensusTarget Function(CensusTarget) update) {
    final s = state;
    if (s is! MasterCensusExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<CensusTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<CensusDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  /// "Sayımı tamamla" — RefillNotifier.confirmCurrent ile birebir aynı akış.
  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterCensusExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      if (!job.canComplete) return;
      _orchestrator.confirmClose();
      return;
    }

    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    if (target.hasEntry) {
      state = s.copyWith(isSaving: true);
      final params = CensusJobParamsMapper.toParamsForTarget(target);
      final result = await _completeCensus(params);
      final saved = state;
      if (saved is! MasterCensusExecuting) return;

      bool failed = false;
      result.when(
        ok: (_) {},
        error: (e) {
          failed = true;
          state = MasterCensusError(
            failure: CabinApiFailure(message: e.message),
            previousState: saved.copyWith(isSaving: false),
            isQueueError: true,
          );
        },
      );
      if (failed) return;
    }

    await _advanceCubicLid();
  }

  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterCensusExecuting) return;
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

  // ── Orchestrator stage geçişleri (RefillNotifier ile birebir aynı) ────────

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
    if (s is! MasterCensusExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik) return;
    if (job.targets.isEmpty) return;

    final firstCell = job.targets[s.currentTargetIndex].assignment;
    await _orchestrator.openCubicLid(firstCell);
  }

  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterCensusExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik && job.hasAnyEntry) {
      state = s.copyWith(isSaving: true);
      final params = CensusJobParamsMapper.toParams(job);
      final result = await _completeCensus(params);
      final saved = state;
      if (saved is! MasterCensusExecuting) return;

      bool failed = false;
      result.when(
        ok: (_) {},
        error: (e) {
          failed = true;
          state = MasterCensusError(
            failure: CabinApiFailure(message: e.message),
            previousState: saved.copyWith(isSaving: false),
            isQueueError: true,
          );
        },
      );
      if (failed) return;
    }

    final completedJobs = _withStatus(s.jobs, s.currentIndex, CensusJobStatus.completed);
    final nextIndex = s.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= s.jobs.length) {
      await _reloadSelectionAfterQueue(s.cabinId);
      return;
    }

    state = MasterCensusExecuting(
      cabinId: s.cabinId,
      jobs: completedJobs,
      currentIndex: nextIndex,
      currentTargetIndex: 0,
      isSaving: false,
    );
    await _openCurrentJob();
  }

  void _onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    final s = state;
    if (s is MasterCensusExecuting) {
      state = MasterCensusError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is MasterCensusExecuting) {
      await _reloadSelectionAfterQueue(s.cabinId);
    }
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterCensusError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! MasterCensusExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CensusJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue(prev.cabinId);
      return;
    }

    state = MasterCensusExecuting(cabinId: prev.cabinId, jobs: markedJobs, currentIndex: nextIndex, isSaving: false);
    await _openCurrentJob();
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! MasterCensusError) return;
    final prev = s.previousState;
    await _orchestrator.stop();

    if (prev is MasterCensusExecuting) {
      await _reloadSelectionAfterQueue(prev.cabinId);
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is MasterCensusError) state = s.previousState;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  /// Kuyruk bittiğinde çağrılır: ilaç listesini yeniden çeker (stoklar
  /// değişti) ve temiz (hepsi-seçili) Selection fazına döner. allGroups'a
  /// hiç ihtiyaç yok artık — View zaten widget.data.groups'u panel'lere
  /// sabit olarak geçiriyor, state'in taşımasına gerek kalmadı.
  Future<void> _reloadSelectionAfterQueue(int cabinId) async {
    state = const MasterCensusLoading();
    final result = await _getAssignments();
    result.when(
      ok: (assignments) => state = MasterCensusSelection(
        cabinId: cabinId,
        medicines: assignments,
        selectedUnitIds: assignments.map((a) => a.cabinDrawerId).whereType<int>().toSet(),
      ),
      error: (e) => state = MasterCensusError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterCensusSelection(cabinId: cabinId, medicines: const [], selectedUnitIds: const {}),
      ),
    );
  }

  List<CensusDrawerJob> _withStatus(List<CensusDrawerJob> jobs, int index, CensusJobStatus status) {
    final next = List<CensusDrawerJob>.from(jobs);
    next[index] = next[index].copyWith(status: status);
    return next;
  }
}
