// [SWREQ-CLI-DRAWER-QUEUE-MIXIN-001] [IEC 62304 §5.5]
// Fiziksel çekmece kuyruğunu (job listesi, aktif job/target, ilerleme,
// hata kurtarma) yöneten ortak altyapı. Katman 1 (MasterDrawerExecutionMixin)
// üzerine oturur — donanım mekaniğinden habersiz olmak yerine, onun hook'larını
// override ederek kuyruk semantiğine bağlar.
//
// Sınıf: Class B
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/master_drawer_execution_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../hardware/hardware.dart';

mixin CabinDrawerQueueMixin<TJob extends DrawerJob<TTarget>, TTarget extends DrawerJobTarget>
    on ChangeNotifier, MasterDrawerExecutionMixin {
  List<TJob> _jobs = const [];
  List<TJob> get jobs => _jobs;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _currentTargetIndex = 0;
  int get currentTargetIndex => _currentTargetIndex;
  @protected
  void setCurrentTargetIndexForSameCell(int index) {
    _currentTargetIndex = index;
    notifyListeners();
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;
  @protected
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  bool get isExecuting => _jobs.isNotEmpty;

  TJob? get currentJob => (_currentIndex >= 0 && _currentIndex < _jobs.length) ? _jobs[_currentIndex] : null;

  TTarget? get currentTarget {
    final job = currentJob;
    if (job == null || _currentTargetIndex < 0 || _currentTargetIndex >= job.targets.length) return null;
    return job.targets[_currentTargetIndex];
  }

  CabinOperationFailure? _failure;
  CabinOperationFailure? get failure => _failure;

  bool _isQueueError = false;
  bool get isQueueError => _isQueueError;
  @protected
  void setQueueFailure(CabinOperationFailure failure, {bool isQueueError = false}) {
    _failure = failure;
    _isQueueError = isQueueError;
    _isSaving = false;
    notifyListeners();
  }

  /// Kuyruktaki ilerleme oranı (0.0–1.0). currentIndex henüz tamamlanmamış
  /// job'u gösterdiği için +1 YOK — orijinal MasterRefundExecuting.progress
  /// ile birebir aynı hesap.
  double get progress => _jobs.isEmpty ? 0 : _currentIndex / _jobs.length;

  bool _stopRequested = false;
  bool _closeRequestedForStop = false;

  /// Kullanıcı durdurmayı onayladı, çekmecenin kapanması bekleniyor.
  bool get isStopping => _stopRequested;

  void dismissQueueError() {
    _failure = null;
    _isQueueError = false;
    notifyListeners();
  }

  @protected
  void replaceCurrentJobTargets(List<TTarget> newTargets) {
    final job = currentJob;
    if (job == null) return;
    final next = List<TJob>.from(_jobs);
    next[_currentIndex] = job.copyWithTargets(newTargets) as TJob;
    _jobs = next;
    notifyListeners();
  }

  Future<void> startQueue(List<TJob> jobs) async {
    if (jobs.isEmpty) {
      setQueueFailure(const CabinValidationFailure(reason: CabinValidationReason.noValidTargets));
      return;
    }
    _jobs = jobs;
    _currentIndex = 0;
    _currentTargetIndex = 0;
    _isSaving = false;
    _failure = null;
    notifyListeners();
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    if (jobIndex < 0 || jobIndex >= _jobs.length) {
      _finishQueue();
      return;
    }
    final job = _jobs[jobIndex];
    if (targetIndex < 0 || targetIndex >= job.targets.length) return;

    _jobs = _withStatus(jobIndex, CabinOperationJobStatus.active);
    _currentIndex = jobIndex;
    _currentTargetIndex = targetIndex;
    _isSaving = false;
    notifyListeners();

    final openAssignment = job.staysOpenAcrossTargets
        ? job.representativeAssignment
        : job.targets[targetIndex].assignment;

    // staysOpenAcrossTargets (kübik) her zaman tam açılır — kısmi açma
    // kavramı orada yok, sadece birim-doz hedefler kendi derinliğini taşır.
    final explicitStep = job.staysOpenAcrossTargets ? null : job.targets[targetIndex].explicitTargetStep;

    await openDrawer(assignment: openAssignment, explicitTargetStep: explicitStep);
  }

  @override
  void onDrawerOpened() {
    final job = currentJob;
    if (job == null || !job.isKubik) return;
    openCubicLid(job.targets[_currentTargetIndex].assignment);
  }

  /// Fiziksel kapanış GERÇEKLEŞTİKTEN SONRA, kuyruk ilerlemeden HEMEN ÖNCE
  /// çağrılır. Varsayılan no-op — "kaydet, sonra kapat" deseninde (Census/
  /// Refill/Unload/Refund) kayıt zaten confirmCurrent'ta önceden yapılmış
  /// olur. "Kapat, sonra kaydet" isteyen bir akış (bkz. bir önceki
  /// mesajdaki senaryo) bunu override edip burada saveTarget çağırır;
  /// false dönerse kuyruk İLERLEMEZ — hook kendi hata state'ini
  /// setQueueFailure ile set etmiş olmalı.
  Future<bool> onBeforeAdvanceAfterClose(TTarget? target) async => true;

  Future<void> _advanceAfterClose() async {
    final job = currentJob;
    if (job == null) return;

    final ok = await onBeforeAdvanceAfterClose(currentTarget);
    if (!ok) return;

    if (!job.staysOpenAcrossTargets) {
      final nextTarget = _currentTargetIndex + 1;
      if (nextTarget < job.targets.length) {
        await stopDrawer();
        await _openJobAt(jobIndex: _currentIndex, targetIndex: nextTarget);
        return;
      }
    }

    await _completeCurrentJobAndAdvance();
  }

  Future<void> _completeCurrentJobAndAdvance() async {
    _jobs = _withStatus(_currentIndex, CabinOperationJobStatus.completed);
    await stopDrawer();

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _jobs.length) {
      _finishQueue();
      return;
    }
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  // ── "Kaydet, sonra kapat" deseni için hazır yardımcı ──
  // Census/Refill/Unload'ın confirmCurrent'ı birebir buydu. Refund bunu
  // KULLANMAZ — 3 dallı kendi confirmCurrent'ını Katman 1 primitifleriyle
  // (openCubicLid/confirmDrawerClose/stopDrawer) yazmaya devam eder.

  Future<void> confirmSingleTarget({required Future<bool> Function(TTarget target) saveTarget}) async {
    final job = currentJob;
    final target = currentTarget;
    if (job == null || target == null) return;

    isSaving = true;
    final ok = await saveTarget(target); // hata olursa saveTarget kendi setQueueFailure'ını çağırır
    if (!isExecuting || !ok) return;

    if (job.isKubik) {
      await advanceCubicLid();
    } else {
      isSaving = false;
      confirmDrawerClose();
    }
  }

  Future<void> advanceCubicLid() async {
    final job = currentJob;
    if (job == null) return;

    final nextTarget = _currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      isSaving = false;
      confirmDrawerClose();
      return;
    }
    _currentTargetIndex = nextTarget;
    isSaving = false;
    notifyListeners();
    await openCubicLid(job.targets[nextTarget].assignment);
  }

  Future<void> continueAfterError() async {
    if (!_isQueueError) return;
    _jobs = _withStatus(_currentIndex, CabinOperationJobStatus.failed);
    _failure = null;
    _isQueueError = false;
    await stopDrawer();

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _jobs.length) {
      _finishQueue();
      return;
    }
    _currentIndex = nextIndex;
    _currentTargetIndex = 0;
    _isSaving = false;
    notifyListeners();
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> stopQueue() => _stopDrawerThenFinish(reason: 'stopQueue');

  Future<void> abortAfterError() => _stopDrawerThenFinish(reason: 'abortAfterError');

  /// Donanım durdurma başarısız olsa ya da hata fırlatsa bile kuyruk
  /// SONLANDIRILIR — kullanıcının durdurma kararı donanımın cevabına bağlı
  /// kalmamalı. Hata loglanır; oturum bir sonraki işlemde yeniden başlatılır.
  Future<void> _stopDrawerThenFinish({required String reason}) async {
    try {
      await stopDrawer();
    } catch (e) {
      MedLogger.warn(
        unit: 'CabinDrawerQueue',
        swreq: 'SWREQ-CLI-DRAWER-QUEUE-MIXIN-001',
        message: 'Çekmece durdurulamadı, kuyruk yine de sonlandırıldı',
        context: {'reason': reason, 'error': e.toString(), 'stage': drawerStage.toString()},
      );
    } finally {
      _finishQueue();
    }
  }

  List<TJob> _withStatus(int index, CabinOperationJobStatus status) {
    final next = List<TJob>.from(_jobs);
    next[index] = next[index].copyWithStatus(status) as TJob;
    return next;
  }

  /// `buildCabinExecutionLocationItems`'ın (mevcut, job-tipinden bağımsız
  /// generic yardımcı) ince sarmalayıcısı — jobs/currentIndex/
  /// currentTargetIndex/status/targets/assignment gibi ORTAK alanları
  /// burada bir kere doldurur, sadece cabinDrawerId/stockId/isReturnDrawer
  /// gibi job'a özgü çıkarımları çağırana bırakır.
  // CabinDrawerQueueMixin içinde:
  List<DrawerQueueItem> locationItemsUsing({
    required List<DrawerGroup> allGroups,
    required int Function(TJob job) cabinDrawerIdOf,
    required int? Function(TJob job, int targetIndex) stockIdAt,
    List<int> Function(TJob job, int targetIndex)? stockIdsAt,
    bool Function(TJob job)? isReturnDrawerTargetOf,
  }) => buildCabinExecutionLocationItems(
    allGroups: allGroups,
    jobs: _jobs,
    currentIndex: _currentIndex,
    currentTargetIndex: _currentTargetIndex,
    cabinDrawerIdOf: cabinDrawerIdOf,
    statusOf: (job) => job.status,
    targetCountOf: (job) => job.targets.length,
    assignmentAt: (job, i) => job.targets[i].assignment,
    stockIdAt: stockIdAt,
    stockIdsAt: stockIdsAt,
    isReturnDrawerTargetOf: isReturnDrawerTargetOf ?? (_) => false,
  );

  /// Kuyruk bittiğinde (son job tamamlandığında YA DA stopQueue/
  /// abortAfterError ile durdurulduğunda) TAM O ANDA çağrılır — View'ın
  /// "isExecuting az önce false oldu mu" diye reaktif izleme yapmasına
  /// gerek bırakmaz. View initState'te atar, dispose'ta temizler.
  VoidCallback? onQueueFinished;

  void _finishQueue() {
    _stopRequested = false;
    _closeRequestedForStop = false;
    _jobs = const [];
    _currentIndex = 0;
    _currentTargetIndex = 0;
    _isSaving = false;
    _failure = null;
    _isQueueError = false;
    notifyListeners(); // önce UI'ı "boş kuyruk" durumuna getir
    onQueueFinished?.call(); // sonra dışarıya haber ver
  }

  /// onBeforeAdvanceAfterClose false döndüğünde (kuyruk askıya alındığında —
  /// örn. QR kod dialog'u açıkken) engel ortadan kalkınca kuyruğu elle devam
  /// ettirmek için. onBeforeAdvanceAfterClose TEKRAR çağrılmaz — çağıran taraf
  /// ilerlemeye izin verildiğini garanti eder.
  Future<void> resumeAfterBlockedAdvance() => _completeCurrentJobAndAdvance();

  /// Footer'ın "Durdur" onayından sonra çağrılır. Çekmece kapalıysa hemen
  /// durdurur; açıksa önce kapanışı resmi olarak ister (confirmDrawerClose),
  /// kapanınca durdurur. stop() açık çekmecede kapanışı beklediği için
  /// doğrudan çağrılmaz.
  Future<void> requestStop() async {
    if (!isExecuting || _stopRequested) return;

    final stage = drawerStage;
    if (!stage.isActive || stage is MasterDrawerLidFailed) {
      await stopQueue();
      return;
    }

    _stopRequested = true;
    notifyListeners();
    _requestCloseForStop(stage);
  }

  /// Stage Opened olur olmaz kapanışı TEK SEFER ister. Durdurma açılma/kapak
  /// geçişi sırasında istendiyse burada no-op kalır, Opened'a ulaşınca
  /// onStageChanged tekrar dener.
  void _requestCloseForStop(MasterDrawerStage stage) {
    if (_closeRequestedForStop || stage is! MasterDrawerOpened) return;
    _closeRequestedForStop = true;
    confirmDrawerClose();
  }

  @override
  void onStageChanged(MasterDrawerStage? previous, MasterDrawerStage current) {
    if (!_stopRequested) return;
    _requestCloseForStop(current);

    // Çekmece artık aktif değil (kapandı / boşta / hata) → gerçek durdurma.
    if (!current.isActive) {
      _stopRequested = false; // tekrar tetiklenmesin
      unawaited(stopQueue());
    }
  }

  @override
  void onDrawerClosed() {
    if (_stopRequested) return; // durdurma onStageChanged'de ele alınıyor
    unawaited(_advanceAfterClose());
  }

  @override
  void onDrawerFailed(MasterDrawerFailure failure, String? detail) {
    if (!isExecuting || _stopRequested) return; // durdururken hata dialog'u açılmasın
    setQueueFailure(CabinMasterDrawerFailure(failure: failure, detail: detail), isQueueError: true);
  }
}
