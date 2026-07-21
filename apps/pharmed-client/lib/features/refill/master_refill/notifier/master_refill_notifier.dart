// [SWREQ-CLI-MREFILL-002] [IEC 62304 §5.5]
// İlaç-merkezli master kabin dolum akışını yöneten notifier.
//
// FAZ 1 (Selection): GetCabinAssignmentsUseCase ile atanmış ilaçları çeker,
//   kullanıcının ilaç/göz seçimini yönetir.
// FAZ 2 (Executing): RefillQueueBuilder ile çekmece kuyruğu üretir, kuyruğu
//   MasterDrawerOrchestrator üzerinden sırayla işler:
//     - currentJob'ı aç (open)
//     - Opened → kullanıcı gözleri doldurur
//     - confirmClose → çekmece kapanır (WaitingForClose → Closed)
//     - Closed → aktif job kaydedilir, sıradaki job açılır
//
// Aynı anda yalnızca TEK fiziksel çekmece açıktır.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import 'master_refill_state.dart';

final masterRefillNotifierProvider = NotifierProvider<MasterRefillNotifier, MasterRefillState>(
  MasterRefillNotifier.new,
);

class MasterRefillNotifier extends Notifier<MasterRefillState> {
  late final MasterDrawerOrchestrator _orchestrator;

  GetCabinAssignmentsUseCase get _getAssignments => ref.read(getCabinAssignmentsUseCaseProvider);
  RefillMasterCabinUseCase get _refillCabin => ref.read(refillMasterCabinUseCaseProvider);

  @override
  MasterRefillState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterRefillUninitialized();
  }

  /// Ekran açılışında çağrılır — kabine atanmış ilaçları yükler.
  Future<void> init(CabinVisualizerData data) async {
    final cabinId = data.cabinId;
    state = const MasterRefillLoading();

    final result = await _getAssignments();
    result.when(
      ok: (assignments) {
        state = MasterRefillSelection(cabinId: cabinId, medicines: assignments);
      },
      error: (e) {
        state = MasterRefillError(
          failure: CabinApiFailure(message: e.message),
          previousState: MasterRefillSelection(cabinId: cabinId, medicines: const []),
        );
      },
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterRefillSelection) return;
    state = s.copyWith(search: value);
  }

  /// Bir gözü (cabinDrawerId) seçer/çıkarır.
  void toggleUnit(int cabinDrawerId) {
    final s = state;
    if (s is! MasterRefillSelection) return;
    final next = Set<int>.from(s.selectedUnitIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    state = s.copyWith(selectedUnitIds: next);
  }

  /// Bir ilacın tüm gözlerini topluca seçer/çıkarır.
  void toggleMedicine(int medicineId) {
    final s = state;
    if (s is! MasterRefillSelection) return;
    final unitIds = s.medicines
        .where((a) => a.medicine?.id == medicineId)
        .map((a) => a.cabinDrawerId)
        .whereType<int>()
        .toSet();
    final next = Set<int>.from(s.selectedUnitIds);
    final allSelected = unitIds.every(next.contains);
    allSelected ? next.removeAll(unitIds) : next.addAll(unitIds);
    state = s.copyWith(selectedUnitIds: next);
  }

  /// "Otomatik Dolum Başlat" — seçimlerden kuyruk üretir, ilk çekmeceyi açar.
  Future<void> startAutoRefill() async {
    final s = state;
    if (s is! MasterRefillSelection || !s.canStart) return;

    final jobs = RefillQueueBuilder.build(s.selectedAssignments);
    if (jobs.isEmpty) return;

    state = MasterRefillExecuting(cabinId: s.cabinId, jobs: jobs, currentIndex: 0);
    await _openCurrentJob();
  }

  Future<void> _openCurrentJob() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    // Aktif job'ı işaretle, lid alt-kuyruğunu başa al.
    state = s.copyWith(jobs: _withStatus(s.jobs, s.currentIndex, RefillJobStatus.active), currentTargetIndex: 0);

    await _orchestrator.open(assignment: job.representativeAssignment);
  }

  // Kübik çekmece (target tek değer taşır)
  void onCubicCountChanged(int targetIndex, double value) => _updateTarget(targetIndex, (t) => t.withCubicCount(value));

  void onCubicFillingChanged(int targetIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withCubicFilling(value));

  void onCubicMiadChanged(int targetIndex, DateTime? date) => _updateTarget(targetIndex, (t) => t.withCubicMiad(date));

  // Birim doz çekmece (target içinde step bazlı)
  void onStepCountChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepCount(stepIndex, value));

  void onStepFillingChanged(int targetIndex, int stepIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withStepFilling(stepIndex, value));

  void onStepMiadChanged(int targetIndex, int stepIndex, DateTime? date) =>
      _updateTarget(targetIndex, (t) => t.withStepMiad(stepIndex, date));

  /// isPerCellMiad=false birim doz çekmecede tüm gözlere uygulanan tek miad.
  void onSingleMiadChanged(int targetIndex, DateTime? date) =>
      _updateTarget(targetIndex, (t) => t.withSingleMiad(date));

  void _updateTarget(int targetIndex, RefillFillTarget Function(RefillFillTarget) update) {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<RefillFillTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<RefillDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  /// "Dolumu tamamla":
  ///   - Birim doz/standart: tüm gözler tek formda → çekmece kapanmasını tetikle,
  ///     kayıt çekmece kapandığında (Closed) yapılır.
  ///   - Kübik: aktif gözün API'si HEMEN atılır; başarılıysa sıradaki lid açılır,
  ///     son göz ise çekmece kapanması tetiklenir.
  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      // Birim doz/standart — tüm gözler geçerli olmalı.
      if (!job.canComplete) return;
      _orchestrator.confirmClose();
      return;
    }

    // Kübik — aktif gözü kaydet.
    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    // Dolum girilmemişse kayıt atlanır, direkt sıradaki lid'e geçilir.
    if (target.hasFilling) {
      state = s.copyWith(isSaving: true);
      final params = RefillJobParamsMapper.toParamsForTarget(target);
      final result = await _refillCabin(params);
      final saved = state;
      if (saved is! MasterRefillExecuting) return;

      bool failed = false;
      result.when(
        ok: (_) {},
        error: (e) {
          failed = true;
          state = MasterRefillError(
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

  /// Kübik job içinde sıradaki lid'e geçer; son lid ise çekmece kapanışını başlatır.
  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextTarget = s.currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      // Tüm gözler bitti → çekmeceyi kapatmaya geç.
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
      return;
    }

    // Sıradaki gözün lid'ini aç.
    state = s.copyWith(currentTargetIndex: nextTarget, isSaving: false);
    final cellAssignment = job.targets[nextTarget].assignment;
    await _orchestrator.openCubicLid(cellAssignment);
  }

  // ── Orchestrator stage geçişleri ──────────────────────────────────────────

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

  /// Ana çekmece açıldı. Kübikse ilk hedef gözün lid'ini aç.
  /// Birim doz/standart çekmecede kullanıcı zaten tüm formu görüyor — lid yok.
  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik) return;
    if (job.targets.isEmpty) return;

    final firstCell = job.targets[s.currentTargetIndex].assignment;
    await _orchestrator.openCubicLid(firstCell);
  }

  /// Aktif çekmece fiziksel olarak kapandı.
  ///   - Birim doz/standart: tüm gözleri şimdi kaydet → sıradaki job.
  ///   - Kübik: kayıt zaten lid bazlı yapıldı → doğrudan sıradaki job.
  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    // Birim doz/standart: çekmece kapanınca tüm gözleri tek istekte kaydet.
    if (!job.isKubik && job.hasAnyFilling) {
      state = s.copyWith(isSaving: true);
      final params = RefillJobParamsMapper.toParams(job);
      final result = await _refillCabin(params);
      final saved = state;
      if (saved is! MasterRefillExecuting) return;

      bool failed = false;
      result.when(
        ok: (_) {},
        error: (e) {
          failed = true;
          // Çekmece zaten fiziksel kapandı ama kayıt başarısız — kullanıcı
          // ilaçları geri almalı. Kuyruk hatası olarak işaretle.
          state = MasterRefillError(
            failure: CabinApiFailure(message: e.message),
            previousState: saved.copyWith(isSaving: false),
            isQueueError: true,
          );
        },
      );
      if (failed) return;
    }

    // Job'ı completed işaretle, orchestrator'ı sıfırla, sıradaki job'a geç.
    final completedJobs = _withStatus(s.jobs, s.currentIndex, RefillJobStatus.completed);
    final nextIndex = s.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= s.jobs.length) {
      await _reloadSelectionAfterQueue(s.cabinId);
      return;
    }

    state = MasterRefillExecuting(
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
    if (s is MasterRefillExecuting) {
      state = MasterRefillError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

  /// Kuyruğu tamamen durdurur, seçim fazına döner.
  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is MasterRefillExecuting) {
      await _reloadSelectionAfterQueue(s.cabinId);
    }
  }

  // ── Kuyruk hatası sonrası kurtarma ────────────────────────────────────────

  /// Kuyruk hatası sonrası kullanıcı "Devam"ı onayladı: hatalı çekmeceyi
  /// failed işaretle, orchestrator'ı sıfırla, sıradaki çekmeceye geç.
  /// Sıradaki yoksa kuyruğu tamamlanmış say.
  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterRefillError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! MasterRefillExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, RefillJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue(prev.cabinId);
      return;
    }

    state = MasterRefillExecuting(cabinId: prev.cabinId, jobs: markedJobs, currentIndex: nextIndex, isSaving: false);
    await _openCurrentJob();
  }

  /// Kuyruk hatası sonrası kullanıcı "Sonlandır"ı seçti: orchestrator'ı kapat,
  /// kuyruğu bitir (tamamlanan dolumlar korunur).
  Future<void> abortAfterError() async {
    final s = state;
    if (s is! MasterRefillError) return;
    final prev = s.previousState;
    await _orchestrator.stop();

    if (prev is MasterRefillExecuting) {
      await _reloadSelectionAfterQueue(prev.cabinId);
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is MasterRefillError) state = s.previousState;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  /// Kuyruk bittiğinde çağrılır: ilaç listesini yeniden çeker (stoklar değişti)
  /// ve temiz (seçimsiz) Selection fazına döner. Ayrı "başarılı" ekranı yoktur.
  Future<void> _reloadSelectionAfterQueue(int cabinId) async {
    state = const MasterRefillLoading();
    final result = await _getAssignments();
    result.when(
      ok: (assignments) => state = MasterRefillSelection(cabinId: cabinId, medicines: assignments),
      error: (e) => state = MasterRefillError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterRefillSelection(cabinId: cabinId, medicines: const []),
      ),
    );
  }

  List<RefillDrawerJob> _withStatus(List<RefillDrawerJob> jobs, int index, RefillJobStatus status) {
    final next = List<RefillDrawerJob>.from(jobs);
    next[index] = next[index].copyWith(status: status);
    return next;
  }
}
