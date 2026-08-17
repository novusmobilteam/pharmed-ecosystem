// [SWREQ-CLI-CABINOP-030] [IEC 62304 §5.5]
//
// Master kabin "Seçim → Kuyruk → Yürütme" akışının ORTAK donanım/kuyruk
// mekaniğini sağlayan mixin. Refill, Census, Unload, Intake, Refund
// notifier'ları bunu kullanır — her biri sadece kendi use case çağrısını
// (submitTarget), kendi Seçim fazı iş kurallarını ve kuyruk bittiğinde ne
// yapılacağını (onQueueFinished) yazar. Kuyruğun kendisini NASIL ilerlettiği
// (kübik lid / birim doz aç-kapa / manuel iade kutusu) CabinDrawerJob<T>'nin
// taşıdığı isKubik/isReturnDrawer bilgisinden tamamen mixin içinde çözülür —
// host bu ayrımı bilmek ZORUNDA DEĞİLDİR.
//
// Job/Target tipi CabinDrawerJob<T>/CabinDrawerTarget üzerinden generic'tir
// (bkz. CabinDrawerJob, CabinDrawerTarget, CabinDrawerQueueBuilder).
//
// Sınıf: Class B
import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import '../hardware/hardware.dart';

mixin CabinDrawerQueueMixin<T extends CabinDrawerTarget> on ChangeNotifier {
  // ── Host'un sağlaması gereken bağımlılık ────────────────────────

  /// Fiziksel çekmece açma/kapama donanım oturumu — host constructor'da
  /// kurar, mixin kendisi yaratmaz. Host, orchestrator.init(onStageChange:
  /// onDrawerStage) çağrısını KENDİSİ yapmalıdır (mixin bunu otomatik
  /// bağlamaz — host'un constructor sırası/timing'i üzerinde kontrolü kalsın diye).
  MasterDrawerOrchestrator get orchestrator;

  /// Bir hedefi API'ye kaydeder — host kendi use case'ini burada çağırır
  /// (RefillMasterCabinUseCase / CompleteMasterCensusUseCase /
  /// CompleteMasterUnloadUseCase / CompleteIntakeUseCase / CompleteRefundUseCase
  /// vb.). Girdisiz/boş hedefler için host kendi "hasEntry" kontrolünü
  /// yapıp erken Result.ok(null) dönebilir — mixin bunu zorlamaz.
  Future<Result<void>> submitTarget(T target);

  /// Kuyruk bittiğinde (tamamlandı ya da durduruldu) çağrılır — host kendi
  /// Seçim fazına dönüş mantığını (atamaları yeniden çekmek, hasta bağlamını
  /// sıfırlamak vb.) burada uygular.
  Future<void> onQueueFinished();

  /// Kübik bir lid'in açılması REDDEDİLDİĞİNDE (lokal hata, state'e
  /// yansıtılmaz) çağrılır — host kendi unit/swreq etiketiyle loglamak
  /// isterse override eder. Varsayılan: hiçbir şey yapmaz.
  void onLidFailed(MasterDrawerFailure failure, {String? detail}) {}

  /// Her startQueue/stopQueue/skipCurrentJobAndAdvance çağrısında artan
  /// sayaç — await sonrası "ben başladığımda geçerliydim, hâlâ geçerli
  /// miyim" kontrolü için. stopQueue() sırasında sayaç arttırılır, bu
  /// sırada devam eden başka bir async akış (örn. skipCurrentJobAndAdvance,
  /// _openJobAt) kendi yakaladığı eski nesille karşılaştırıp geç kaldığını
  /// anlar ve state'i EZMEDEN sessizce çıkar.
  int _generation = 0;

  /// submitTarget() başarısız olduğunda dolan, TEK SEFERLİK gösterim için
  /// tutulan hata. View bunu görüp snackbar gösterdikten sonra
  /// [dismissTransientSaveError] ile temizlemelidir — aksi halde aynı hata
  /// bir sonraki notifyListeners()'da tekrar "yeni" gibi algılanabilir.
  CabinApiFailure? _transientSaveError;
  CabinApiFailure? get transientSaveError => _transientSaveError;

  // ── Dispose takibi ───────────────────────────────────────────────

  /// notifyListeners()'ı dispose sonrası korumak için kullanılan bayrak.
  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  /// Host kendi dispose()'unda, super.dispose()'tan ÖNCE bunu çağırmalıdır.
  void markQueueDisposed() => _isDisposed = true;

  /// Host'un dışarıdan (örn. orchestrator.addListener) mixin'in notify
  /// mekanizmasını tetikleyebilmesi için ince bir köprü.
  void notifyQueueListeners() => _notify();

  // ── Kuyruk state'i ───────────────────────────────────────────────

  /// Seçimden üretilen fiziksel çekmece kuyruğu. null = Yürütme fazında değiliz.
  List<CabinDrawerJob<T>>? _jobs;
  List<CabinDrawerJob<T>> get jobs => _jobs ?? const [];

  /// Kuyrukta şu an işlenen job'ın index'i.
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// Aktif job içindeki aktif hedefin (kübikte lid, birim dozda port,
  /// iade kutusunda anlamsız/0) index'i.
  int _currentTargetIndex = 0;
  int get currentTargetIndex => _currentTargetIndex;

  /// Aktif hata — set edildiğinde _jobs SİLİNMEZ, sadece bu alan doldurulur.
  CabinOperationFailure? _errorFailure;
  CabinOperationFailure? get errorFailure => _errorFailure;

  /// true ise hata Yürütme/kuyruk akışından geldi — sadece bu durumda
  /// continueAfterError anlamlıdır.
  bool _isQueueError = false;
  bool get isQueueError => _isQueueError;

  // ── Türetilen göstergeler ───────────────────────────────────────

  bool get isExecuting => _jobs != null;
  bool get isActivelyExecuting => isExecuting && _errorFailure == null;

  CabinDrawerJob<T>? get currentJob {
    final j = _jobs;
    if (j == null || _currentIndex < 0 || _currentIndex >= j.length) return null;
    return j[_currentIndex];
  }

  T? get currentTarget {
    final job = currentJob;
    if (job == null) return null;
    if (_currentTargetIndex < 0 || _currentTargetIndex >= job.targets.length) return null;
    return job.targets[_currentTargetIndex];
  }

  // ── Kuyruğu başlat ───────────────────────────────────────────────

  /// Host, CabinDrawerQueueBuilder.build(...) ile ürettiği DOLU job listesini
  /// burada teslim eder — boş liste / "geçerli hedef yok" hatası HOST
  /// tarafında ele alınır (mesaj işleme göre değiştiği için: refill/census
  /// "noValidTargets", unload "noDrawerFound" gibi).
  Future<void> startQueue(List<CabinDrawerJob<T>> initialJobs) async {
    final myGen = ++_generation;
    _jobs = initialJobs;
    _currentIndex = 0;
    _currentTargetIndex = 0;
    _errorFailure = null;
    _isQueueError = false;
    _notify();
    await _openJobAt(jobIndex: 0, targetIndex: 0, generation: myGen);
  }

  Future<void> _openJobAt({required int jobIndex, required int targetIndex, required int generation}) async {
    if (generation != _generation) return; // arada stop/başka bir queue tetiklendi
    final currentJobs = _jobs;
    if (currentJobs == null) return;
    if (jobIndex < 0 || jobIndex >= currentJobs.length) return;
    final job = currentJobs[jobIndex];
    if (targetIndex < 0 || targetIndex >= job.targets.length) return;

    final next = List<CabinDrawerJob<T>>.from(currentJobs);
    next[jobIndex] = job.copyWith(status: CabinOperationJobStatus.active);
    _jobs = next;
    _currentIndex = jobIndex;
    _currentTargetIndex = targetIndex;
    _notify();

    final openAssignment = job.staysOpenAcrossTargets
        ? job.representativeAssignment
        : job.targets[targetIndex].assignment;
    if (openAssignment == null) return;

    await orchestrator.open(assignment: openAssignment, explicitTargetStep: job.requiredStepNo);
    if (_isDisposed) return;
    if (generation != _generation) return; // await sürerken durdurulmuş olabilir — burada da kontrol
  }

  // ── Donanım stage callback'i — host, orchestrator.init(onStageChange:
  // this.onDrawerStage) ile bunu bağlar ────────────────────────────

  void onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    if (_isDisposed) return;
    switch (current) {
      case MasterDrawerOpened():
        // SADECE ana çekmece yeni fiziksel olarak açıldıysa — openCubicLid'in
        // kendi ürettiği ara Opened event'lerinde DEĞİL (previous=OpeningLid
        // ile gelir, bu ayrım kritik: aksi halde "aynı lid'i sonsuza kadar
        // yeniden aç" döngüsüne girilir).
        if (previous is MasterDrawerWaitingForPull) _onDrawerOpened();
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        // Lokal hata — state'e yansıtılmaz, akış Executing'de kalır.
        onLidFailed(failure, detail: detail);
      case MasterDrawerFailed(:final failure, :final detail):
        onDrawerFailed(failure, detail: detail);
      default:
        break;
    }
  }

  Future<void> _onDrawerOpened() async {
    final job = currentJob;
    if (job == null) return;

    // İade kutusu: hiçbir lid komutu gönderilmez — kullanıcı manuel bırakır,
    // doğrudan confirmCurrent beklenir.
    if (job.isReturnDrawer) return;

    if (job.isKubik) {
      final target = currentTarget;
      final assignment = target?.assignment;
      if (assignment == null) return;
      await orchestrator.openCubicLid(assignment);
    }
    // Birim doz (hardwarePerTarget): açılan port zaten aktif hedefin kendi
    // portudur, ek bir komut gerekmez — form doğrudan kullanılabilir.
  }

  Future<void> _onCurrentDrawerClosed() async {
    final myGen = _generation;
    final job = currentJob;
    if (job == null) return;

    if (!job.staysOpenAcrossTargets) {
      final nextTarget = _currentTargetIndex + 1;
      if (nextTarget < job.targets.length) {
        // Aynı fiziksel çekmecede başka bir ilacın (portun) sırası geldi.
        await orchestrator.stop();
        if (_isDisposed) return;
        if (myGen != _generation) return; // stop() bu await sırasında araya girdi
        await _openJobAt(jobIndex: _currentIndex, targetIndex: nextTarget, generation: myGen);
        return;
      }
    }

    final currentJobs = _jobs;
    if (currentJobs == null) return;
    final completed = List<CabinDrawerJob<T>>.from(currentJobs);
    completed[_currentIndex] = job.copyWith(
      status: job.status == CabinOperationJobStatus.failed
          ? CabinOperationJobStatus.failed
          : CabinOperationJobStatus.completed,
    );
    final nextIndex = _currentIndex + 1;
    await orchestrator.stop();
    if (_isDisposed) return;
    if (myGen != _generation) return; // stopQueue bu await sırasında araya girdi

    if (nextIndex >= completed.length) {
      _jobs = null;
      _currentIndex = 0;
      _currentTargetIndex = 0;
      _notify();
      await onQueueFinished();
      return;
    }

    _jobs = completed;
    _currentIndex = nextIndex;
    _currentTargetIndex = 0;
    _notify();
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0, generation: myGen);
  }

  /// Genel bir donanım hatası oluştuğunda çağrılır. Varsayılan: _errorFailure
  /// set edilir, kullanıcı kararını bekler. Host override edip belirli
  /// failure türleri için otomatik aksiyon tetikleyebilir.
  void onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    _errorFailure = CabinMasterDrawerFailure(failure: failure, detail: detail);
    _isQueueError = true;
    _notify();
  }

  // ── Hedef onaylama — üç mod da burada tek noktadan yönetilir ─────

  /// "Tamamla" / "Sonraki". Job'ın modu ne olursa olsun (kübik lid-advance,
  /// birim doz hardware-advance, iade kutusu manuel-no-advance) çağıran taraf
  /// için TEK bir metod — mod ayrımı burada, mixin içinde çözülür.
  Future<void> confirmCurrent() async {
    if (!isActivelyExecuting) return;
    final job = currentJob;
    if (job == null) return;

    if (job.isReturnDrawer) {
      // Manuel mod: TÜM hedefler denenir — biri kaydedilemese bile diğerleri
      // korunur (hata izolasyonu), sonunda kapanış tetiklenir.
      for (final target in job.targets) {
        await _saveTarget(target);
        if (_isDisposed) return;
        if (!isActivelyExecuting) return; // stopQueue / donanım hatası araya girdi
      }
      orchestrator.confirmClose();
      return;
    }

    final target = currentTarget;
    if (target == null || !target.isValid) return;

    await _saveTarget(target);
    if (_isDisposed) return;
    if (!isActivelyExecuting) return; // await sırasında donanım hatası oluşmuş olabilir

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      orchestrator.confirmClose();
    }
  }

  /// Aktif hedefi API'ye kaydeder. BAŞARISIZLIK donanım akışını DURDURMAZ —
  /// hata izole edilip [onTargetSaveFailed] ile host'a bildirilir, kuyruk
  /// sıradaki adıma (lid / kapanış) normal şekilde devam eder. Bu, kübik
  /// gözlerde "bir gözün kaydı başarısız olursa sadece o göz etkilenir"
  /// ilkesinin (master-drawer-operation §5) doğrudan uygulamasıdır.
  Future<void> _saveTarget(T target) async {
    if (!target.hasEntry) return;

    final result = await submitTarget(target);
    if (_isDisposed) return;
    if (!isActivelyExecuting) return; // await sürerken stop/donanım hatası araya girdi

    result.when(
      ok: (_) {},
      error: (e) {
        _markCurrentJobFailed();
        onTargetSaveFailed(CabinApiFailure(message: e.message), target);
      },
    );
  }

  void _markCurrentJobFailed() {
    final currentJobs = _jobs;
    if (currentJobs == null) return;
    final job = currentJobs[_currentIndex];
    if (job.status == CabinOperationJobStatus.failed) return; // zaten işaretli
    final updated = List<CabinDrawerJob<T>>.from(currentJobs);
    updated[_currentIndex] = job.copyWith(status: CabinOperationJobStatus.failed);
    _jobs = updated;
    _notify();
  }

  Future<void> _advanceCubicLid() async {
    if (!isActivelyExecuting) return;
    final job = currentJob;
    if (job == null) return;

    final nextTarget = _currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      orchestrator.confirmClose();
      return;
    }

    _currentTargetIndex = nextTarget;
    _notify();
    final assignment = job.targets[nextTarget].assignment;
    if (assignment == null) return;
    await orchestrator.openCubicLid(assignment);
  }

  // ── Kullanıcı aksiyonları ─────────────────────────────────────────

  Future<void> stopQueue() async {
    _generation++; // devam eden tüm async işleri bu noktadan itibaren geçersiz kılar
    final wasExecuting = isExecuting;
    await orchestrator.stop();
    if (_isDisposed) return;
    if (wasExecuting) {
      _jobs = null;
      _currentIndex = 0;
      _currentTargetIndex = 0;
      _errorFailure = null;
      _isQueueError = false;
      _notify();
      await onQueueFinished();
    }
  }

  Future<void> continueAfterError() async {
    if (_errorFailure == null || !_isQueueError) return;
    final myGen = _generation;
    final j = _jobs;
    if (j == null) return;

    final markedJobs = List<CabinDrawerJob<T>>.from(j);
    markedJobs[_currentIndex] = markedJobs[_currentIndex].copyWith(status: CabinOperationJobStatus.failed);
    final nextIndex = _currentIndex + 1;
    await orchestrator.stop();
    if (_isDisposed) return;
    if (myGen != _generation) return; // stopQueue bu await sırasında araya girdi

    if (nextIndex >= markedJobs.length) {
      _jobs = null;
      _currentIndex = 0;
      _currentTargetIndex = 0;
      _errorFailure = null;
      _isQueueError = false;
      _notify();
      await onQueueFinished();
      return;
    }

    _jobs = markedJobs;
    _currentIndex = nextIndex;
    _currentTargetIndex = 0;
    _errorFailure = null;
    _isQueueError = false;
    _notify();
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0, generation: myGen);
  }

  Future<void> abortAfterError() async {
    if (_errorFailure == null) return;
    final myGen = _generation;
    final wasExecuting = _jobs != null;
    await orchestrator.stop();
    if (_isDisposed) return;
    if (myGen != _generation) return; // stopQueue bu await sırasında araya girdi

    if (wasExecuting) {
      _jobs = null;
      _currentIndex = 0;
      _currentTargetIndex = 0;
      _errorFailure = null;
      _isQueueError = false;
      _notify();
      await onQueueFinished();
    } else {
      _errorFailure = null;
      _isQueueError = false;
      _notify();
    }
  }

  void dismissError() {
    if (_errorFailure == null) return;
    _errorFailure = null;
    _isQueueError = false;
    _notify();
  }

  /// Host, kuyruk kurulmadan ÖNCE (Seçim fazında) oluşan bir hatayı
  /// (örn. "hiç geçerli hedef yok") bu tek noktadan bildirir — mixin'in
  /// _errorFailure'ı private olduğu için host'un doğrudan erişimi yok.
  /// Donanım/API kaynaklı hatalar zaten mixin'in kendi iç akışından
  /// (_onDrawerFailed, _saveTarget) geliyor; bu setter yalnızca host'un
  /// KENDİ ürettiği (queue builder sonucu, validasyon vb.) hatalar içindir.
  void reportError(CabinOperationFailure failure, {bool isQueueError = false}) {
    _errorFailure = failure;
    _isQueueError = isQueueError;
    _notify();
  }

  /// Aktif hedefin verisini günceller (örn. kullanıcı miktar/miad girdi).
  /// Sadece currentTarget üzerinde çalışır — job listesindeki ilgili target
  /// immutable olarak değiştirilip yeniden atanır.
  void updateCurrentTarget(T Function(T current) update) {
    if (!isActivelyExecuting) return;
    final job = currentJob;
    if (job == null) return;
    if (_currentTargetIndex < 0 || _currentTargetIndex >= job.targets.length) return;

    final newTargets = List<T>.from(job.targets);
    newTargets[_currentTargetIndex] = update(newTargets[_currentTargetIndex]);

    final currentJobs = _jobs;
    if (currentJobs == null) return;
    final newJobs = List<CabinDrawerJob<T>>.from(currentJobs);
    newJobs[_currentIndex] = job.copyWith(targets: newTargets);
    _jobs = newJobs;
    _notify();
  }

  /// Mevcut job'ı failed işaretleyip sıradaki job'a geçer — kullanıcı
  /// kararına bağlı değildir, host'un otomatik kurtarma senaryoları için
  /// (örn. unexpectedlyClosed). _errorFailure hiç set edilmeden çalışır.
  Future<void> skipCurrentJobAndAdvance() async {
    final myGen = _generation; // stopQueue tarafından artırılmadıysa aynı kalır
    final j = _jobs;
    if (j == null) return;

    final markedJobs = List<CabinDrawerJob<T>>.from(j);
    markedJobs[_currentIndex] = markedJobs[_currentIndex].copyWith(status: CabinOperationJobStatus.failed);
    final nextIndex = _currentIndex + 1;
    await orchestrator.stop();
    if (_isDisposed) return;
    if (myGen != _generation) return; // stop() bu await sırasında araya girdi

    if (nextIndex >= markedJobs.length) {
      _jobs = null;
      _currentIndex = 0;
      _currentTargetIndex = 0;
      _errorFailure = null;
      _isQueueError = false;
      _notify();
      await onQueueFinished();
      return;
    }

    _jobs = markedJobs;
    _currentIndex = nextIndex;
    _currentTargetIndex = 0;
    _errorFailure = null;
    _isQueueError = false;
    _notify();
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0, generation: myGen);
  }

  void dismissTransientSaveError() {
    if (_transientSaveError == null) return;
    _transientSaveError = null;
    _notify();
  }

  /// submitTarget() başarısız olduğunda çağrılır (kırmızı boyama zaten
  /// [_markCurrentJobFailed] ile yapıldı) — host burayı sadece kullanıcıya
  /// bir snackbar/toast göstermek için override edebilir.
  void onTargetSaveFailed(CabinApiFailure failure, T target) {
    _transientSaveError = failure;
    _notify();
  }
}
