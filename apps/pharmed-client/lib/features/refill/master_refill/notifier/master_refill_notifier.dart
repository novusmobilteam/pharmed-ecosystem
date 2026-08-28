import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import '../../../dashboard/dashboard.dart';
import 'master_refill_state.dart';

final masterRefillNotifierProvider = NotifierProvider<MasterRefillNotifier, MasterRefillState>(
  MasterRefillNotifier.new,
);

class MasterRefillNotifier extends Notifier<MasterRefillState> {
  late final MasterDrawerOrchestrator _orchestrator;

  GetCabinAssignmentsWithCabinUseCase get _getAssignments => ref.read(getCabinAssignmentsWitCabinUseCaseProvider);
  RefillMasterCabinUseCase get _refillCabin => ref.read(refillMasterCabinUseCaseProvider);

  @override
  MasterRefillState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterRefillUninitialized();
  }

  Future<void> init(CabinRouteContext ctx) async {
    final cabinId = ctx.cabin?.id;
    if (cabinId == null) {
      return;
    }
    state = const MasterRefillLoading();

    final result = await _getAssignments.call(cabinId);
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

  void toggleUnit(int cabinDrawerId) {
    final s = state;
    if (s is! MasterRefillSelection) return;
    final next = Set<int>.from(s.selectedUnitIds);
    next.contains(cabinDrawerId) ? next.remove(cabinDrawerId) : next.add(cabinDrawerId);
    state = s.copyWith(selectedUnitIds: next);
  }

  void toggleDrawer(DrawerGroup group) {
    final s = state;
    if (s is! MasterRefillSelection) return;

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

  /// Kullanıcının FAZ 1'de seçtiği ilaç/göz kombinasyonlarından fiziksel
  /// çekmece kuyruğunu üretir ve yürütmeyi (FAZ 2) başlatır.
  ///
  /// Akış:
  ///   1. Sadece Selection state'inde VE en az bir seçim varken çalışır.
  ///   2. CabinOperationQueueBuilder, seçilen atamaları FİZİKSEL ÇEKMECE
  ///      bazında gruplar; eksik/bozuk ilişkisel veri yüzünden hiçbir
  ///      çekmeceye bağlanamayan atamalar `skipped` olarak ayrıca döner.
  ///   3a. Hiç job üretilemezse (tüm seçim skipped'e düştü) kullanıcıya
  ///       CabinValidationFailure(noValidTargets) ile AÇIK bir hata gösterilir
  ///       — artık sessiz no-op YOK.
  ///   3b. Kısmen skip varsa (bazı job'lar üretildi ama bazı seçimler atlandı)
  ///       akış DURDURULMAZ (kullanıcının geçerli seçimleri kaybolmasın), ama
  ///       durum loglanır — ileride bir toast/banner ile kullanıcıya "N ilaç
  ///       eksik veri nedeniyle kuyruğa alınamadı" bilgisi eklenebilir
  ///       (şimdilik sadece log, UI'da gösterilmiyor — bkz. not).
  ///   4. Executing state'e geçilir (currentIndex=0) ve ilk job açılır.
  Future<void> startAutoRefill() async {
    final s = state;
    if (s is! MasterRefillSelection || !s.canStart) return;

    final result = CabinOperationQueueBuilder.build(
      selectedAssignments: s.selectedAssignments,
      config: refillTargetConfig,
    );

    if (result.jobs.isEmpty) {
      state = MasterRefillError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
        previousState: s,
      );
      return;
    }

    if (result.skipped.isNotEmpty) {
      MedLogger.warn(
        unit: 'MasterRefill',
        swreq: 'SWREQ-CLI-MREFILL-002',
        message: 'Bazı seçimler fiziksel çekmece kimliği çözülemediği için kuyruğa alınamadı',
        context: {
          'skippedCount': result.skipped.length,
          'skippedMedicineIds': result.skipped.map((a) => a.medicine?.id).toList(),
        },
      );
    }

    state = MasterRefillExecuting(cabinId: s.cabinId, jobs: result.jobs, currentIndex: 0);
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  /// Bir job'ın (ya da job'un belirli bir hedefinin) fiziksel oturumunu AÇAR.
  ///
  /// Kübikte her zaman ana çekmece (representativeAssignment) açılır — hangi
  /// lid'in gösterileceği openCubicLid ile ayrıca yönetilir, [targetIndex]
  /// burada sadece "hangi göz aktif" bilgisini state'e yazmak için kullanılır,
  /// açma komutunun hedefini ETKİLEMEZ. Birim dozda ise [targetIndex]'teki
  /// hedefin KENDİ assignment'ı (kendi fiziksel portu) açılır.
  ///
  /// DİKKAT — `await _orchestrator.open(...)` burada çekmecenin FİZİKSEL
  /// olarak açıldığını beklemez; sadece MasterDrawerSessionNotifier'ın yeni
  /// stream'i dinlemeye BAŞLADIĞINI bekler (bkz. session notifier'ın start()
  /// metodu: stream.listen(...) senkron kurulur, tamamlanmasını beklemez).
  /// Gerçek fiziksel açılış asenkron olarak _onDrawerStage callback'i
  /// üzerinden (Opened/Failed) haber verilir — bu fonksiyon o bildirimi
  /// beklemez, sadece süreci başlatır.
  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) return;
    final job = s.jobs[jobIndex];

    // Savunmacı sınır kontrolü: şu anki tüm çağıranlar (startAutoRefill,
    // _onCurrentDrawerClosed, continueAfterError) targetIndex'i zaten kendi
    // tarafında sınırlıyor, ama bu fonksiyon PUBLIC bir iç API gibi
    // davrandığından (jobIndex/targetIndex serbestçe verilebiliyor) burada da
    // kontrol etmek, ileride eklenecek yanlış bir çağrının RangeError ile
    // sessizce (yakalanmamış Future hatası olarak) çökmesini önler.
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

  /// "Dolumu tamamla" / "Sonraki":
  ///   - Kübik: aktif LID'in API'si hemen atılır, sonra yazılımsal olarak
  ///     sıradaki lid açılır ya da (son lid ise) ana çekmece kapanışı
  ///     tetiklenir.
  ///   - Birim doz: aktif HEDEFİN (bu portun) API'si atılır, sonra fiziksel
  ///     kapanış (confirmClose) tetiklenir — sıradaki hedef varsa
  ///     _onCurrentDrawerClosed'da yeni bir open() ile açılır.
  ///
  /// BİLİNEN KABUL EDİLMİŞ RİSK: [job] değişkeni `await _saveTarget` öncesi
  /// yakalanır ve sonrasında hâlâ o referans kullanılır. Kullanıcı "tamamla"
  /// dedikten SONRA, backend kaydı beklenirken (isSaving=true) donanımı
  /// erken/spontane kapatırsa, bu bekleme sırasında _onDrawerStage üzerinden
  /// tetiklenecek bir olay teorik olarak state'i bu fonksiyonun beklemediği
  /// bir noktaya ilerletebilir. Kullanıcı eğitimi ve UI'ın "işlem bitince
  /// çekmeceyi kapatın" yönlendirmesi bu senaryoyu pratikte imkansıza yakın
  /// kılıyor; bu yüzden şimdilik `saved.currentJob` ile yeniden okuma gibi bir
  /// sertleştirme YAPILMADI — bilinçli bir kapsam dışı bırakma kararı.
  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    state = s.copyWith(isSaving: true);
    await _saveTarget(target);
    final saved = state;
    // _saveTarget başarısız olduğunda (ok == false) state'i zaten
    // MasterRefillError'a çeviriyor - bu tek kontrol ikisini de kapsıyor,
    // ayrı bir `if (!ok)` kontrolüne gerek yok.
    if (saved is! MasterRefillExecuting) return;

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      // Birim doz: bu portu fiziksel olarak kapat — sıradaki hedef (varsa)
      // _onCurrentDrawerClosed'da yeni bir open() ile açılacak.
      state = saved.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  /// Tek bir hedefin (kübik lid ya da birim doz portu) API çağrısını atar.
  /// Boş hedef optimizasyonu: girdi yoksa API'ye hiç gidilmez, başarılı sayılır.
  Future<void> _saveTarget(CabinOperationTarget target) async {
    if (!target.hasEntry) return;

    final params = CabinOperationParamsMapper.toParamsForTarget(target, refillParamsOps);
    final result = await _refillCabin(params);
    final saved = state;

    if (saved is! MasterRefillExecuting) {
      // await sürerken state Executing olmaktan çıktı (örn. donanım hatası
      // eşzamanlı tetiklendi ya da kuyruk durduruldu). API çağrısı zaten
      // backend'e gitti - sonucunu (başarı/hata) burada göstereceğimiz bir
      // UI kalmadı, ama en azından iz bırakıyoruz.
      result.when(
        ok: (_) {},
        error: (e) => MedLogger.warn(
          unit: 'MasterRefill',
          swreq: 'SWREQ-CLI-MREFILL-002',
          message: 'Kayıt sonucu geldi ama session artık Executing değildi, sonuç gösterilemedi',
          context: {'error': e.message},
        ),
      );
      return;
    }

    result.when(
      ok: (_) {},
      error: (e) => state = MasterRefillError(
        failure: CabinApiFailure(message: e.message),
        previousState: saved.copyWith(isSaving: false),
        //isQueueError: true,
      ),
    );
  }

  /// Kübik job içinde sıradaki lid'e YAZILIMSAL geçer (fiziksel kapanma
  /// beklenmez); son lid ise ana çekmece kapanışını başlatır.
  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
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
        // SADECE ana çekmece yeni fiziksel olarak açıldıysa ilk kapağı
        // otomatik aç. openCubicLid'in kendi başarı sonrası ürettiği
        // Opened event'i previous=OpeningLid ile gelir - bunu burada
        // TEKRAR işlemek sonsuz "aynı kapağı yeniden aç" döngüsüne yol
        // açar (2026 kübik akış tasarımı sırasında bulunan kritik bug).
        if (previous is MasterDrawerWaitingForPull) {
          _onDrawerOpened();
        }
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        // Feature state bilerek DEĞİŞTİRİLMİYOR (Executing kalır) - UI,
        // session stage'ini masterDrawerSessionProvider üzerinden doğrudan
        // okuyup hata görünümünü gösteriyor (bkz. CabinOperationExecutionLayout
        // + retryCurrentLid). Burada sadece izlenebilirlik için logluyoruz.
        MedLogger.warn(
          unit: 'MasterRefill',
          swreq: 'SWREQ-CLI-MREFILL-002',
          message: 'Kübik kapak açma reddedildi',
          context: {'failure': failure.name, 'detail': detail},
        );
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail: detail);
      default:
        break;
    }
  }

  /// Ana çekmece/port açıldı. Kübikse aktif hedefin lid'ini aç — birim dozda
  /// hiçbir ek aksiyon gerekmez, açılan port zaten aktif hedefin kendi
  /// portudur, form direkt kullanılabilir.
  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik) return;
    if (job.targets.isEmpty) return;

    final firstCell = job.targets[s.currentTargetIndex].assignment;
    await _orchestrator.openCubicLid(firstCell);
  }

  /// Fiziksel çekmece/port kapandı.
  ///   - Kübik: kayıt zaten lid bazlı yapıldı, burada ek kayıt yok — job
  ///     tamamlandı, sıradaki job'a geç.
  ///   - Birim doz: bu hedefin kaydı zaten confirmCurrent'ta yapıldı.
  ///     Job'da başka hedef (başka port) varsa YENİ bir open() ile onu aç;
  ///     yoksa job tamamlandı, sıradaki job'a geç.
  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      final nextTarget = s.currentTargetIndex + 1;
      if (nextTarget < job.targets.length) {
        // Aynı fiziksel çekmecede başka bir ilacın (portun) sırası geldi.
        await _orchestrator.stop();
        await _openJobAt(jobIndex: s.currentIndex, targetIndex: nextTarget);
        return;
      }
    }

    // Job'ın tüm hedefleri bitti (kübik: tüm lid'ler; birim doz: tüm portlar).
    final completedJobs = _withStatus(s.jobs, s.currentIndex, CabinOperationJobStatus.completed);
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
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
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

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is MasterRefillExecuting) {
      await _reloadSelectionAfterQueue(s.cabinId);
    }
  }

  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterRefillError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! MasterRefillExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CabinOperationJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue(prev.cabinId);
      return;
    }

    state = MasterRefillExecuting(cabinId: prev.cabinId, jobs: markedJobs, currentIndex: nextIndex, isSaving: false);
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

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

  Future<void> _reloadSelectionAfterQueue(int cabinId) async {
    state = const MasterRefillLoading();
    final result = await _getAssignments.call(cabinId);
    result.when(
      ok: (assignments) => state = MasterRefillSelection(cabinId: cabinId, medicines: assignments),
      error: (e) => state = MasterRefillError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterRefillSelection(cabinId: cabinId, medicines: const []),
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

  // Kübik çekmece
  void onCubicCountChanged(int targetIndex, double value) => _updateTarget(targetIndex, (t) => t.withCubicCount(value));

  void onCubicFillingChanged(int targetIndex, double value) =>
      _updateTarget(targetIndex, (t) => t.withCubicSecondary(value));

  void onCubicMiadChanged(int targetIndex, DateTime? date) => _updateTarget(targetIndex, (t) => t.withCubicMiad(date));

  // Birim doz çekmece
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
    if (s is! MasterRefillExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<CabinOperationTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<CabinOperationDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }
}
