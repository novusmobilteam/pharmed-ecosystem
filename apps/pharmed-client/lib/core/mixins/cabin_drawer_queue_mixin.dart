// [SWREQ-CLI-DRAWER-QUEUE-MIXIN-001] [IEC 62304 §5.5]
// Fiziksel çekmece kuyruğunu (job listesi, aktif job/target, ilerleme,
// hata kurtarma) yöneten ortak altyapı. Katman 1 (MasterDrawerExecutionMixin)
// üzerine oturur — donanım mekaniğinden habersiz olmak yerine, onun hook'larını
// override ederek kuyruk semantiğine bağlar.
//
// FİZİKSEL KAPANIŞLA TAMAMLAMA (completesOnPhysicalClose = true, opt-in):
//   Hedef tamamlandı = kayıt yapıldı + fiziksel kapanış gerçekleşti.
//     Kübik    : gözün KAPAĞI kapandı (ac → kp) — sıradaki kapak ancak
//                bundan sonra açılır.
//     Birim doz: ÇEKMECE kapandı (her hedef zaten ayrı bir aç/kapa döngüsü).
//   İki yol aynı noktada birleşir:
//     A) "Tamamla" → kayıt → kapanış beklenir → kapandı
//     B) Tamamla'ya basılmadan kapandı → saveTargetOnPhysicalClose
//   → onTargetCompleted (örn. alımda QR dialog'u; false → kuyruk askıda)
//   → resumeAfterTargetCompleted → sıradaki kapak / hedef / job.
//   Kapak açılamazsa (LidFailed) kullanıcı skipCurrentLid ile gözü atlayabilir.
//
// Sınıf: Class B
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/master_drawer_execution_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../hardware/hardware.dart';

enum QueueFinishReason { completed, stoppedByUser, abortedAfterError }

mixin CabinDrawerQueueMixin<TJob extends DrawerJob<TTarget>, TTarget extends DrawerJobTarget>
    on ChangeNotifier, MasterDrawerExecutionMixin {
  List<TJob> _jobs = const [];
  List<TJob> get jobs => _jobs;

  bool _disposed = false;

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

  // onQueueStarting sürüyor (ör. kamera bağlanıyor) — çekmece henüz açılmadı.
  bool _isPreparing = false;
  bool get isPreparing => _isPreparing;

  /// Kuyruk kurulduktan sonra, ilk çekmece açılmadan HEMEN önce await edilir.
  @protected
  Future<void> onQueueStarting() async {}

  /// Kuyruk sonlanırken, state temizlenmeden ÖNCE çağrılır.
  @protected
  void onQueueFinishing(QueueFinishReason reason) {}

  /// Kuyruktaki ilerleme oranı (0.0–1.0). currentIndex henüz tamamlanmamış
  /// job'u gösterdiği için +1 YOK — orijinal MasterRefundExecuting.progress
  /// ile birebir aynı hesap.
  double get progress => _jobs.isEmpty ? 0 : _currentIndex / _jobs.length;

  bool _stopRequested = false;
  bool _closeRequestedForStop = false;

  /// Kullanıcı durdurmayı onayladı, çekmecenin kapanması bekleniyor.
  bool get isStopping => _stopRequested;

  // ── Fiziksel kapanışla tamamlama ──────────────────────────────────────────

  /// true ise:
  ///  - kübikte sıradaki kapak, önceki kapak fiziksel kapanmadan açılmaz;
  ///  - kapak (kübik) / çekmece (birim doz) kapanışı "Tamamla" yerine geçer.
  /// Varsayılan false — girdisi kullanıcıya bağlı işlemlerde (dolum/sayım)
  /// kapanışta otomatik kayıt yapılamayacağı için bilinçli olarak açılır.
  bool get completesOnPhysicalClose => false;

  /// Aktif hedefin kaydı yapıldı mı — A/B yollarından hangisinin kayıt
  /// yapacağını belirler. Yeni hedef/göz açılırken sıfırlanır.
  bool _currentTargetSaved = false;

  /// onTargetCompleted false döndüğünde askıya alınan devam adımı.
  Future<void> Function()? _blockedResume;

  /// Kapağı açılamadığı için atlanan gözler — (jobIndex, targetIndex).
  Set<(int, int)> _skippedTargets = const {};
  Set<(int, int)> get skippedTargets => _skippedTargets;

  bool isTargetSkipped(int jobIndex, int targetIndex) => _skippedTargets.contains((jobIndex, targetIndex));

  /// Kullanıcı "Tamamla"ya basmadan kapak/çekmece kapandığında aktif hedefin
  /// kaydı. [completesOnPhysicalClose] true olan feature'lar bunu override
  /// etmek ZORUNDADIR (varsayılan kayıt yapmaz). false dönerse kuyruk
  /// ilerlemez — hata setQueueFailure ile set edilmiş olmalı.
  @protected
  Future<bool> saveTargetOnPhysicalClose(TTarget target) async => true;

  /// Hedef tamamlandı (kayıt + fiziksel kapanış), kuyruk ilerlemeden HEMEN
  /// önce. false dönerse kuyruk askıya alınır — engel kalkınca
  /// [resumeAfterTargetCompleted] çağrılmalıdır. Alım: QR dialog'u.
  @protected
  Future<bool> onTargetCompleted(TTarget target) async => true;

  /// [SWREQ-PRN-092] Hedefin kaydı (API) BAŞARIYLA yapıldığında, her hedef için
  /// tam bir kez çağrılır — "Tamamla" (A) ve fiziksel kapanış (B) yolları ortak.
  /// Kayıt başarısızsa çağrılmaz. Fiş gibi "yapılan işlemi raporlayan"
  /// katmanlar bunu dinler; kuyruk akışını etkilememelidir.
  @protected
  void onTargetSaved(TTarget target) {}

  /// [onTargetCompleted] false döndüğünde, engel kalkınca kuyruğu devam
  /// ettirir. Hook TEKRAR çağrılmaz.
  Future<void> resumeAfterTargetCompleted() async {
    final resume = _blockedResume;
    _blockedResume = null;
    if (resume != null) await resume();
  }

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
    _skippedTargets = const {};
    _blockedResume = null;
    notifyListeners();
    await onQueueStarting();
    if (_disposed) return;
    _isPreparing = false;
    // Hazırlık sırasında durduruldu.
    if (!isExecuting) return;
    notifyListeners();
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    if (jobIndex < 0 || jobIndex >= _jobs.length) {
      _finishQueue(reason: QueueFinishReason.abortedAfterError);
      return;
    }
    final job = _jobs[jobIndex];
    if (targetIndex < 0 || targetIndex >= job.targets.length) return;

    _jobs = _withStatus(jobIndex, CabinOperationJobStatus.active);
    _currentIndex = jobIndex;
    _currentTargetIndex = targetIndex;
    _currentTargetSaved = false;
    _isSaving = false;
    notifyListeners();

    final openAssignment = job.staysOpenAcrossTargets
        ? job.representativeAssignment
        : job.targets[targetIndex].assignment;

    // staysOpenAcrossTargets (kübik) her zaman tam açılır — kısmi açma
    // kavramı orada yok, sadece birim-doz hedefler kendi derinliğini taşır.
    final explicitStep = job.staysOpenAcrossTargets ? null : job.targets[targetIndex].explicitTargetStep;

    // Kübikte tamamlama kapak seviyesinde — çekmecenin onaysız kapanması
    // hâlâ beklenmedik kapanıştır. Birim dozda çekmece kapanışı = tamamlama.
    await openDrawer(
      assignment: openAssignment,
      explicitTargetStep: explicitStep,
      closeCompletes: completesOnPhysicalClose && !job.staysOpenAcrossTargets,
    );
  }

  /// Kübik gözün kapağını, kuyruğun politikasına göre açar.
  Future<void> _openLid(MedicineAssignment cellAssignment) {
    _currentTargetSaved = false;
    return openCubicLid(cellAssignment, awaitLidClose: completesOnPhysicalClose);
  }

  @override
  void onDrawerOpened() {
    final job = currentJob;
    if (job == null || !job.isKubik) return;
    unawaited(_openLid(job.targets[_currentTargetIndex].assignment));
  }

  /// Fiziksel kapanış GERÇEKLEŞTİKTEN SONRA, kuyruk ilerlemeden HEMEN ÖNCE
  /// çağrılır. Varsayılan no-op — "kaydet, sonra kapat" deseninde (Census/
  /// Refill/Unload/Refund) kayıt zaten confirmCurrent'ta önceden yapılmış
  /// olur. false dönerse kuyruk İLERLEMEZ — hook kendi hata state'ini
  /// setQueueFailure ile set etmiş olmalı.
  ///
  /// NOT: [completesOnPhysicalClose] kullanan feature'lar bunun yerine
  /// [saveTargetOnPhysicalClose] / [onTargetCompleted] kullanır.
  Future<bool> onBeforeAdvanceAfterClose(TTarget? target) async => true;

  Future<void> _advanceAfterClose() async {
    final job = currentJob;
    if (job == null) return;

    final ok = await onBeforeAdvanceAfterClose(currentTarget);
    if (!ok) return;

    // Birim doz + fiziksel kapanışla tamamlama: hedef burada tamamlanır.
    if (completesOnPhysicalClose && !job.staysOpenAcrossTargets) {
      final target = currentTarget;
      if (target == null) return;
      final completed = await _completeTargetAfterPhysicalClose(target, then: _advanceFromClosedDrawer);
      if (!completed) return;
    }

    await _advanceFromClosedDrawer();
  }

  /// Kapalı çekmeceden sonraki adım: birim dozda aynı job'un sıradaki hedefi,
  /// yoksa sıradaki job.
  Future<void> _advanceFromClosedDrawer() async {
    final job = currentJob;
    if (job == null) return;

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
      _finishQueue(reason: QueueFinishReason.abortedAfterError);
      return;
    }
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  /// Fiziksel kapanış sonrası ortak tamamlama: (B yolu ise) kayıt →
  /// onTargetCompleted. true → çağıran hemen ilerleyebilir; false → ya kayıt
  /// başarısız oldu (hata set edildi) ya da kuyruk askıya alındı ([then]
  /// resumeAfterTargetCompleted ile çalıştırılacak).
  Future<bool> _completeTargetAfterPhysicalClose(TTarget target, {required Future<void> Function() then}) async {
    if (!_currentTargetSaved) {
      isSaving = true;
      final ok = await saveTargetOnPhysicalClose(target);
      if (!isExecuting || !ok) return false; // hata saveTargetOnPhysicalClose içinde set edildi
      _currentTargetSaved = true;
      onTargetSaved(target);
      isSaving = false;
    }

    _blockedResume = then;
    final proceed = await onTargetCompleted(target);
    if (!proceed) return false; // askıda — resumeAfterTargetCompleted

    _blockedResume = null;
    return true;
  }

  // ── "Kaydet, sonra kapat" deseni için hazır yardımcı ──
  // Census/Refill/Unload/Intake'in confirmCurrent'ı. Refund bunu KULLANMAZ —
  // 3 dallı kendi confirmCurrent'ını Katman 1 primitifleriyle yazar.

  Future<void> confirmSingleTarget({required Future<bool> Function(TTarget target) saveTarget}) async {
    final job = currentJob;
    final target = currentTarget;
    if (job == null || target == null) return;

    isSaving = true;
    final ok = await saveTarget(target); // hata olursa saveTarget kendi setQueueFailure'ını çağırır
    if (!isExecuting || !ok) return;
    onTargetSaved(target);

    await advanceAfterTargetSaved();
  }

  /// "Tamamla" yolunda (A) hedefin kaydı BAŞARIYLA yapıldıktan sonra
  /// çağrılır. Kendi confirmCurrent'ını yazan feature'lar da kayıttan
  /// sonra bunu çağırmalıdır.
  ///
  ///  - [completesOnPhysicalClose] false: eski davranış (kübik → sıradaki
  ///    kapak, birim doz → çekmece kapanışı istenir).
  ///  - Kayıt sürerken kapak/çekmece zaten kapandıysa: kapanış hook'u
  ///    bilerek beklemiştir (isSaving guard'ı) — tamamlama burada yapılır.
  ///  - Aksi halde: fiziksel kapanış beklenir; kapanınca hook devam ettirir.
  @protected
  Future<void> advanceAfterTargetSaved() async {
    final job = currentJob;
    final target = currentTarget;
    if (job == null || target == null) return;

    if (!completesOnPhysicalClose) {
      if (job.isKubik) {
        await advanceCubicLid();
      } else {
        isSaving = false;
        confirmDrawerClose();
      }
      return;
    }

    _currentTargetSaved = true;
    isSaving = false;

    final stage = drawerStage;
    if (job.isKubik) {
      if (stage is MasterDrawerLidClosed) {
        await _continueAfterLidClosed(target);
      } else {
        confirmLidClose();
      }
    } else {
      if (stage is MasterDrawerClosed) {
        await _advanceAfterClose();
      } else {
        confirmDrawerClose();
      }
    }
  }

  @override
  void onLidClosed() {
    if (!completesOnPhysicalClose || !isExecuting || _stopRequested) return;

    // "Tamamla" yolunun kaydı sürüyor — bitince advanceAfterTargetSaved
    // stage'e bakıp devam eder. Burada ikinci bir kayıt BAŞLATILMAMALI.
    if (_isSaving) return;

    final target = currentTarget;
    if (target == null) return;
    unawaited(_continueAfterLidClosed(target));
  }

  Future<void> _continueAfterLidClosed(TTarget target) async {
    final completed = await _completeTargetAfterPhysicalClose(target, then: advanceCubicLid);
    if (!completed) return;
    await advanceCubicLid();
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
    await _openLid(job.targets[nextTarget].assignment);
  }

  /// LidFailed durumunda aktif gözü kayıt yapmadan atlar ve sıradaki göze
  /// geçer (son gözse çekmece kapanışı istenir). Kapak açıldıktan sonra
  /// sensörü kopan gözde (lidSensorLost) KULLANILAMAZ — orada kapak açılmış
  /// ve ilaç alınmış olabilir; kullanıcı acknowledgeLidClosedManually ile
  /// devam eder.
  Future<void> skipCurrentLid() async {
    final stage = drawerStage;
    if (!isExecuting || stage is! MasterDrawerLidFailed) return;
    if (stage.failure == MasterDrawerFailure.lidSensorLost) return;

    _skippedTargets = {..._skippedTargets, (_currentIndex, _currentTargetIndex)};
    MedLogger.warn(
      unit: 'CabinDrawerQueue',
      swreq: 'SWREQ-CLI-DRAWER-QUEUE-MIXIN-001',
      message: 'Kübik göz kullanıcı tarafından atlandı (kapak açılamadı)',
      context: {
        'jobIndex': _currentIndex,
        'targetIndex': _currentTargetIndex,
        'failure': stage.failure.name,
        'detail': stage.detail,
      },
    );
    await advanceCubicLid();
  }

  Future<void> continueAfterError() async {
    if (!_isQueueError) return;
    _jobs = _withStatus(_currentIndex, CabinOperationJobStatus.failed);
    _failure = null;
    _isQueueError = false;
    _blockedResume = null;
    await stopDrawer();

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _jobs.length) {
      _finishQueue(reason: QueueFinishReason.abortedAfterError);
      return;
    }
    _currentIndex = nextIndex;
    _currentTargetIndex = 0;
    _isSaving = false;
    notifyListeners();
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  Future<void> stopQueue() => _stopDrawerThenFinish(reason: QueueFinishReason.stoppedByUser);

  Future<void> abortAfterError() => _stopDrawerThenFinish(reason: QueueFinishReason.abortedAfterError);

  /// Donanım durdurma başarısız olsa ya da hata fırlatsa bile kuyruk
  /// SONLANDIRILIR — kullanıcının durdurma kararı donanımın cevabına bağlı
  /// kalmamalı. Hata loglanır; oturum bir sonraki işlemde yeniden başlatılır.
  Future<void> _stopDrawerThenFinish({required QueueFinishReason reason}) async {
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
      _finishQueue(reason: QueueFinishReason.abortedAfterError);
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
  List<DrawerQueueItem> locationItemsUsing({
    required List<DrawerGroup> allGroups,
    required int Function(TJob job) cabinDrawerIdOf,
    required int? Function(TJob job, int targetIndex) stockIdAt,
    List<int> Function(TJob job, int targetIndex)? stockIdsAt,
    bool Function(TJob job)? isReturnDrawerTargetOf,
    Set<int> Function(TJob job, int targetIndex)? activeStepsAt,
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
    activeStepsAt: activeStepsAt,
  );

  /// Kuyruk bittiğinde (son job tamamlandığında YA DA stopQueue/
  /// abortAfterError ile durdurulduğunda) TAM O ANDA çağrılır — View'ın
  /// "isExecuting az önce false oldu mu" diye reaktif izleme yapmasına
  /// gerek bırakmaz. View initState'te atar, dispose'ta temizler.
  VoidCallback? onQueueFinished;

  void _finishQueue({required QueueFinishReason reason}) {
    onQueueFinishing(reason);
    _isPreparing = false;
    _stopRequested = false;
    _closeRequestedForStop = false;
    _jobs = const [];
    _currentIndex = 0;
    _currentTargetIndex = 0;
    _currentTargetSaved = false;
    _blockedResume = null;
    _isSaving = false;
    _failure = null;
    _isQueueError = false;
    // _skippedTargets BİLEREK temizlenmez — onQueueFinished içinde özet
    // göstermek isteyen View okuyabilsin; startQueue sıfırlar.
    notifyListeners(); // önce UI'ı "boş kuyruk" durumuna getir
    onQueueFinished?.call(); // sonra dışarıya haber ver
  }

  /// onBeforeAdvanceAfterClose false döndüğünde (kuyruk askıya alındığında)
  /// engel ortadan kalkınca kuyruğu elle devam ettirmek için.
  /// onBeforeAdvanceAfterClose TEKRAR çağrılmaz.
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

  /// Çekmece kapanışını TEK SEFER ister. Opened'da (kapak açık ya da kapak
  /// izlenmiyor) veya LidClosed'da (kapak kapandı, çekmece hâlâ açık) istenir.
  /// Açılma/kapak geçişi ya da WaitingForLidClose sırasında no-op kalır —
  /// uygun stage'e ulaşınca onStageChanged tekrar dener.
  void _requestCloseForStop(MasterDrawerStage stage) {
    if (_closeRequestedForStop) return;
    if (stage is! MasterDrawerOpened && stage is! MasterDrawerLidClosed) return;
    _closeRequestedForStop = true;
    confirmDrawerClose();
  }

  @override
  void onStageChanged(MasterDrawerStage? previous, MasterDrawerStage current) {
    if (!_stopRequested) return;

    // Durdurma kapak açılırken istendi ve kapak açılamadı — beklenecek bir
    // kapanış yok, doğrudan durdur.
    if (current is MasterDrawerLidFailed) {
      _stopRequested = false;
      unawaited(stopQueue());
      return;
    }

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

    // Birim doz: "Tamamla" kaydı sürerken çekmece kapandı — kayıt bitince
    // advanceAfterTargetSaved stage'e bakıp devam eder, ikinci kayıt yok.
    if (completesOnPhysicalClose && _isSaving) return;

    unawaited(_advanceAfterClose());
  }

  @override
  void onDrawerFailed(MasterDrawerFailure failure, String? detail) {
    if (!isExecuting || _stopRequested) return; // durdururken hata dialog'u açılmasın
    setQueueFailure(CabinMasterDrawerFailure(failure: failure, detail: detail), isQueueError: true);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
