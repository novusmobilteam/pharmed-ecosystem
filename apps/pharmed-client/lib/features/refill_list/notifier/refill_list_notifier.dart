import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';

import '../../dashboard/dashboard.dart';
import 'refill_list_state.dart';

final refillListNotifierProvider = NotifierProvider<RefillListNotifier, RefillListState>(RefillListNotifier.new);

class RefillListNotifier extends Notifier<RefillListState> {
  late final MasterDrawerOrchestrator _orchestrator;
  late int _stationId;

  GetRefillListsUseCase get _getLists => ref.read(getRefillListsUseCaseProvider);
  GetRefillListFillDetailUseCase get _getDetail => ref.read(getRefillListFillDetailUseCaseProvider);
  RefillListRefillUseCase get _refillCabin => ref.read(refillListRefillUseCaseProvider);

  @override
  RefillListState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const RefillListUninitialized();
  }

  Future<void> init(StationCabinsContext ctx) async {
    final stationId = ctx.station?.id;
    if (stationId == null) return;

    state = const RefillListLoading();
    final result = await _getLists(stationId);
    result.when(
      ok: (lists) => state = RefillListSelection(stationId: stationId, lists: lists),
      error: (e) => state = RefillListError(
        failure: CabinApiFailure(message: e.message),
        previousState: RefillListSelection(stationId: stationId, lists: const []),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! RefillListSelection) return;
    state = s.copyWith(search: value);
  }

  /// Sol panelden bir liste seçildiğinde: sağ panele o listenin detayını
  /// yükler. Önceki seçim (varsa) sıfırlanır — farklı bir listeye geçince
  /// işaretli satırlar taşınmaz.
  Future<void> selectList(RefillList list) async {
    final s = state;
    if (s is! RefillListSelection) return;
    final listId = list.id;
    if (listId == null) return;

    state = s.copyWith(selectedList: list, isDetailLoading: true, rows: const [], selectedDrawerIds: const {});

    final result = await _getDetail(listId);
    final current = state;
    if (current is! RefillListSelection || current.selectedList?.id != listId) {
      // Kullanıcı yükleme sürerken başka bir listeye tıkladı — bu sonucu ATLA.
      return;
    }

    result.when(
      ok: (rows) => state = current.copyWith(rows: rows, isDetailLoading: false),
      error: (e) => state = RefillListError(
        failure: CabinApiFailure(message: e.message),
        previousState: current.copyWith(isDetailLoading: false),
      ),
    );
  }

  void toggleDrawer(int cabinDrawerId) {
    final s = state;
    if (s is! RefillListSelection) return;
    final next = Set<int>.from(s.selectedDrawerIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    state = s.copyWith(selectedDrawerIds: next);
  }

  Future<void> startFilling() async {
    final s = state;
    if (s is! RefillListSelection || !s.canStart || s.selectedList?.id == null) return;

    final result = RefillListJobMapper.build(rows: s.selectedRows, config: refillTargetConfig);

    if (result.jobs.isEmpty) {
      state = RefillListError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
        previousState: s,
      );
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'RefillList',
        swreq: 'SWREQ-CLI-RFLIST-001',
        message: 'Bazı işaretli satırlar fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {'skippedCount': result.skipped.length, 'fillingListId': s.selectedList!.id},
      );
    }

    state = RefillListExecuting(
      stationId: s.stationId,
      fillingListId: s.selectedList!.id!,
      jobs: result.jobs,
      currentIndex: 0,
      skippedCount: result.skipped.length,
    );
    _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! RefillListExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) return;
    final job = s.jobs[jobIndex];
    if (targetIndex < 0 || targetIndex >= job.targets.length) return;

    state = s.copyWith(
      jobs: _withStatus(s.jobs, jobIndex, CabinOperationJobStatus.active),
      currentIndex: jobIndex,
      currentTargetIndex: targetIndex,
      isSaving: false,
    );

    final openAssignment = job.isKubik ? job.representativeAssignment : job.targets[targetIndex].assignment;
    await _orchestrator.open(assignment: openAssignment);
  }

  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! RefillListExecuting) return;
    final job = s.currentJob;
    if (job == null) return;
    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    state = s.copyWith(isSaving: true);
    await _saveTarget(target);
    final saved = state;
    if (saved is! RefillListExecuting) return;

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      state = saved.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  Future<void> _saveTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return;
    final params = RefillListParamsMapper.toParamsForTarget(target, refillParamsOps);
    final result = await _refillCabin(params);
    final saved = state;
    if (saved is! RefillListExecuting) {
      result.when(
        ok: (_) {},
        error: (e) => MedLogger.warn(
          unit: 'RefillList',
          swreq: 'SWREQ-CLI-RFLIST-001',
          message: 'Kayıt sonucu geldi ama session artık Executing değildi',
          context: {'error': e.message},
        ),
      );
      return;
    }
    result.when(
      ok: (_) {},
      error: (e) => state = RefillListError(
        failure: CabinApiFailure(message: e.message),
        previousState: saved.copyWith(isSaving: false),
      ),
    );
  }

  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! RefillListExecuting) return;
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
        if (previous is MasterDrawerWaitingForPull) _onDrawerOpened();
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        MedLogger.warn(
          unit: 'RefillList',
          swreq: 'SWREQ-CLI-RFLIST-001',
          message: 'Kübik kapak açma reddedildi',
          context: {'failure': failure.name, 'detail': detail},
        );
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail: detail);
      default:
        break;
    }
  }

  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! RefillListExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik || job.targets.isEmpty) return;
    await _orchestrator.openCubicLid(job.targets[s.currentTargetIndex].assignment);
  }

  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! RefillListExecuting) return;
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
      await _returnToSelection(s.stationId, reselectListId: s.fillingListId);
      return;
    }

    state = RefillListExecuting(
      stationId: s.stationId,
      fillingListId: s.fillingListId,
      jobs: completedJobs,
      currentIndex: nextIndex,
      skippedCount: s.skippedCount,
    );
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  void _onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    final s = state;
    if (s is RefillListExecuting) {
      state = RefillListError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is RefillListExecuting) await _returnToSelection(s.stationId, reselectListId: s.fillingListId);
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! RefillListError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! RefillListExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CabinOperationJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _returnToSelection(prev.stationId, reselectListId: prev.fillingListId);
      return;
    }
    state = RefillListExecuting(
      stationId: prev.stationId,
      fillingListId: prev.fillingListId,
      jobs: markedJobs,
      currentIndex: nextIndex,
      skippedCount: prev.skippedCount,
    );
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> abortAfterError() async {
    final s = state;
    if (s is! RefillListError) return;
    final prev = s.previousState;
    await _orchestrator.stop();
    if (prev is RefillListExecuting) {
      await _returnToSelection(prev.stationId, reselectListId: prev.fillingListId);
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is RefillListError) state = s.previousState;
  }

  /// Kuyruk bitti/durdu — liste listesini VE (varsa) az önce doldurulan
  /// listenin güncel detayını (fillingQuantity artık dolu satırlar için
  /// güncellenmiş) yeniden çeker.
  Future<void> _returnToSelection(int stationId, {int? reselectListId}) async {
    state = const RefillListLoading();
    final listsResult = await _getLists(stationId);

    listsResult.when(
      error: (e) => state = RefillListError(
        failure: CabinApiFailure(message: e.message),
        previousState: RefillListSelection(stationId: stationId, lists: const []),
      ),
      ok: (lists) async {
        if (reselectListId == null) {
          state = RefillListSelection(stationId: stationId, lists: lists);
          return;
        }

        final match = lists.firstWhereOrNull((l) => l.id == reselectListId);
        state = RefillListSelection(
          stationId: stationId,
          lists: lists,
          selectedList: match,
          isDetailLoading: match != null,
        );
        if (match == null) return;

        final detailResult = await _getDetail(reselectListId);
        final current = state;
        if (current is! RefillListSelection) return;

        detailResult.when(
          ok: (rows) => state = current.copyWith(rows: rows, isDetailLoading: false),
          error: (e) => state = RefillListError(
            failure: CabinApiFailure(message: e.message),
            previousState: current.copyWith(isDetailLoading: false),
          ),
        );
      },
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

  void onCubicCountChanged(int targetIndex, double value) => _updateTarget(targetIndex, (t) => t.withCubicCount(value));
  void onCubicFillingChanged(int targetIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withCubicSecondary(value));
  void onCubicMiadChanged(int targetIndex, DateTime? date) => _updateTarget(targetIndex, (t) => t.withCubicMiad(date));
  void onStepCountChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepCount(stepIndex, value));
  void onStepFillingChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepSecondary(stepIndex, value));
  void onStepMiadChanged(int targetIndex, int stepIndex, DateTime? date) =>
      _updateTarget(targetIndex, (t) => t.withStepMiad(stepIndex, date));
  void onSingleMiadChanged(int targetIndex, DateTime? date) =>
      _updateTarget(targetIndex, (t) => t.withSingleMiad(date));

  void _updateTarget(int targetIndex, CabinOperationTarget Function(CabinOperationTarget) update) {
    final s = state;
    if (s is! RefillListExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<CabinOperationTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<CabinOperationDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }
}
