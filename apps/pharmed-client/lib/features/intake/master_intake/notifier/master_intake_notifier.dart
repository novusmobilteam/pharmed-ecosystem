// [SWREQ-CLI-MINTAKE-002] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM akışını yöneten notifier.
//
// FAZ 0 (NoPatient): init istasyonu çözer, hastasız NoPatient'a düşer. Hasta
//   seçimi sol panelde (PatientSelectionNotifier) yapılır; seçilince
//   selectPatient(hospitalization, intakeType) çağrılır.
// FAZ 1 (Selection): GetIntakeItemsUseCase ile alım kalemlerini çeker,
//   kullanıcının seçim / doz / şahit girişini yönetir.
// FAZ 2 (Executing): startIntake → seçili tüm kalemler için TOPLU CheckIntake
//   → dönen planlardan IntakeQueueBuilder ile çekmece kuyruğu üretir → kuyruğu
//   MasterDrawerOrchestrator üzerinden sırayla işler:
//     - currentJob'ı aç (open)
//     - Opened → (kübikse ilk gözün lid'i açılır) → kullanıcı CountType'a göre sayar
//     - confirmCurrent →
//         · kübik: aktif gözün CompleteIntake'i HEMEN atılır → sıradaki lid
//                  (son göz ise çekmece kapanışı tetiklenir)
//         · birim doz/standart: çekmece kapanışı tetiklenir, tüm hedefler
//                  Closed'da tek tek kaydedilir
//     - Closed → aktif job tamamlandı → sıradaki job açılır
//
// Aynı anda yalnızca TEK fiziksel çekmece açıktır.
//
// Hasta bağlamı (hospitalization + intakeType) Selection/Executing içinde
// taşınır; "Hastayı değiştir" → changePatient → NoPatient'a döner ve açık
// kuyruk/çekmece temizlenir.
//
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/cabin_operation/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import '../../../auth/auth.dart';
import '../../intake.dart';

final masterIntakeNotifierProvider = NotifierProvider<MasterIntakeNotifier, MasterIntakeState>(
  MasterIntakeNotifier.new,
);

class MasterIntakeNotifier extends Notifier<MasterIntakeState> {
  late final MasterDrawerOrchestrator _orchestrator;

  int _cabinId = 0;

  /// Aktif alımın tipi (ordered/orderless/urgent/free) — selectPatient'ta set.
  IntakeType _type = IntakeType.orderless;

  /// Orderlı alımda hospitalization gerekir.
  int? _hospitalizationId;

  /// Aktif seçili hasta (state geçişlerinde taşınması için tutulur).
  Hospitalization? _hospitalization;

  GetIntakeItemsUseCase get _getItems => ref.read(getIntakeItemsUseCaseProvider);
  CheckIntakeUseCase get _checkIntake => ref.read(checkIntakeUseCaseProvider);
  CompleteIntakeUseCase get _completeIntake => ref.read(completeIntakeUseCaseProvider);
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);

  Station? _currentStation;

  /// needsWitness kararı için çözülmüş kullanıcı istasyonu (init'te bir kez set edilir).
  Station? get currentStation => _currentStation;

  @override
  MasterIntakeState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);
    return const MasterIntakeUninitialized();
  }

  // ── FAZ 0: Init & Hasta seçimi ──────────────────────────────────────────

  /// Ekran açılışında çağrılır — istasyonu çözer, hastasız NoPatient'a düşer.
  ///
  /// Artık tip/hasta init parametresi DEĞİLDİR; bunlar hasta seçildiğinde
  /// (selectPatient) belirlenir.
  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    _hospitalization = null;
    _hospitalizationId = null;
    state = const MasterIntakeLoading();

    // Önceki açık kuyruk/çekmece kalmışsa temizle.
    await _orchestrator.stop();

    // İstasyon (şahit gerekliliği kararı için) — hata olsa da akış devam eder.
    final stationResult = await _getStation.call();
    stationResult.when(ok: (s) => _currentStation = s, error: (_) => _currentStation = null);

    state = MasterIntakeNoPatient(cabinId: _cabinId);
  }

  /// Sol panelde hasta seçildiğinde çağrılır. Tip, hasta seçim modundan
  /// (orderless/ordered) türetilip dışarıdan geçirilir (patient-gateway kuralı).
  Future<void> selectPatient(Hospitalization hospitalization, IntakeType type) async {
    _type = type;
    _hospitalization = hospitalization;
    _hospitalizationId = hospitalization.id;

    // Hasta değişiminde önceki açık kuyruk/çekmece kalmışsa temizle.
    await _orchestrator.stop();

    state = const MasterIntakeLoading();
    await _loadItems();
  }

  /// "Hastayı değiştir" → açık kuyruğu kapat, NoPatient'a dön.
  Future<void> changePatient() async {
    _hospitalization = null;
    _hospitalizationId = null;
    await _orchestrator.stop();
    state = MasterIntakeNoPatient(cabinId: _cabinId);
  }

  Future<void> _loadItems({bool refreshAssignments = false}) async {
    final hospitalization = _hospitalization;
    if (hospitalization == null) {
      state = MasterIntakeNoPatient(cabinId: _cabinId);
      return;
    }

    final result = await _getItems.call(
      GetIntakeItemsParams(type: _type, hospitalizationId: _hospitalizationId, refreshAssignments: refreshAssignments),
    );
    result.when(
      ok: (items) => state = MasterIntakeSelection(
        cabinId: _cabinId,
        hospitalization: hospitalization,
        intakeType: _type,
        items: items,
      ),
      error: (e) => state = MasterIntakeError(
        message: e.message,
        previousState: MasterIntakeSelection(
          cabinId: _cabinId,
          hospitalization: hospitalization,
          intakeType: _type,
          items: const [],
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterIntakeSelection || s.isChecking) return;
    state = s.copyWith(search: value);
  }

  /// Bir kalemi seçer/çıkarır. Seçimde doz 0/null ise 1'e çekilir.
  void toggleItem(int itemId) {
    final s = state;
    if (s is! MasterIntakeSelection || s.isChecking) return;

    final next = Set<int>.from(s.selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
      state = s.copyWith(selectedItemIds: next);
      return;
    }

    next.add(itemId);
    // dosePiece 0/null ise 1 yap.
    final items = s.items.map((it) {
      if (it.id != itemId) return it;
      final dose = it.dosePiece;
      return (dose == null || dose == 0) ? it.copyWith(dosePiece: 1) : it;
    }).toList();
    state = s.copyWith(items: items, selectedItemIds: next);
  }

  /// Bir kalemin alım dozunu günceller (limit validasyonu ile).
  ///
  /// Eski `WithdrawNotifier.updateWithdrawAmount` limit mantığı birebir taşındı:
  ///
  /// [MedicalConsumable] için:
  /// - Miktar 1'in altına düşemez.
  /// - Kabindeki fiziksel stok miktarını aşamaz.
  ///
  /// [Drug] için:
  /// - Reçeteli alımda canLower false ise miktar reçete dozundan aşağı düşemez.
  /// - Üst limit; reçete dozu, fiziksel stok ve günlük maks. kullanımın
  ///   en küçüğü olarak hesaplanır.
  void updateDose(int itemId, double dose) {
    final s = state;
    if (s is! MasterIntakeSelection || s.isChecking) return;

    final item = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final medicine = item.medicine;
    double validatedAmount = dose;

    if (medicine is MedicalConsumable) {
      final stockLimit = item.assignment?.toDisplayQuantity(item.assignment?.totalQuantity ?? 0) ?? 0.0;
      if (validatedAmount < 1) validatedAmount = 1;
      if (validatedAmount > stockLimit) validatedAmount = stockLimit;
    } else if (medicine is Drug) {
      final bool isOrdered = _type == IntakeType.ordered;
      final bool canLower = medicine.isCanLowerDose;
      final double upperLimitFromOrder = item.prescriptionDose ?? 0.0;

      final double minLimit = (isOrdered && !canLower) ? upperLimitFromOrder : 1.0;

      final double physicalLimit = item.assignment?.toDisplayQuantity(item.assignment?.totalQuantity ?? 0) ?? 0.0;
      final double dailyMax = (medicine.dailyMaxUsage ?? 0) > 0 ? medicine.dailyMaxUsage!.toDouble() : physicalLimit;
      final double safetyLimit = physicalLimit < dailyMax ? physicalLimit : dailyMax;
      final double finalUpperLimit = isOrdered
          ? (upperLimitFromOrder < safetyLimit ? upperLimitFromOrder : safetyLimit)
          : safetyLimit;

      if (validatedAmount < minLimit) validatedAmount = minLimit;
      if (validatedAmount > finalUpperLimit) validatedAmount = finalUpperLimit;
    }

    final items = s.items.map((it) => it.id == itemId ? it.copyWith(dosePiece: validatedAmount) : it).toList();
    state = s.copyWith(items: items);
  }

  /// Bir kaleme şahit atar ve aynı şahidin uygun olduğu DİĞER seçili kalemlere
  /// de otomatik yayar (aynı şahit için tekrar tekrar giriş istenmez).
  ///
  /// Kurallar:
  ///   - Aktif (login) kullanıcı şahit OLAMAZ — sessizce reddedilir.
  ///   - Bir kalem için şahit uygunluğu: o kalemin witnesses listesi boşsa
  ///     (herkes şahit olabilir) VEYA user o kalemin witnesses listesindeyse.
  ///   - Hedef kaleme her durumda atanır (zaten dialog o kalem için açıldı);
  ///     diğer kalemlere yalnızca uygunsa ve henüz şahidi yoksa atanır.
  void addWitness(int itemId, User user) {
    final s = state;
    if (s is! MasterIntakeSelection) return;

    // Aktif kullanıcı kendi işlemine şahit olamaz.
    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;
    if (currentUserId != null && user.id == currentUserId) return;

    final selectedItem = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (selectedItem == null) return;

    final items = s.items.map((item) {
      // Hedef kalem → doğrudan ata.
      if (item.id == itemId) return item.copyWith(witness: user);

      // Sadece seçili ve henüz şahidi olmayan kalemlere yay.
      final isSelected = s.selectedItemIds.contains(item.id);
      if (!isSelected || item.witness != null) return item;

      // user bu kaleme şahit olabilir mi?
      final canWitness = item.witnesses.isEmpty || item.witnesses.any((w) => w.id == user.id);
      if (canWitness) return item.copyWith(witness: user);

      return item;
    }).toList();

    state = s.copyWith(items: items);
  }

  /// [itemId] kalemi için zaten uygun bir şahit atanmış mı? (Dialog açmadan önce
  /// view bunu kontrol eder; uygunsa tekrar giriş istemeden o şahidi kullanır.)
  ///
  /// "Uygun" = seçili kalemlerden birine atanmış, aktif kullanıcı olmayan ve bu
  /// kaleme de şahit olabilen bir kullanıcı.
  User? resolveExistingWitness(int itemId) {
    final s = state;
    if (s is! MasterIntakeSelection) return null;
    final target = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (target == null) return null;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;

    // Hâlihazırda seçili kalemlere atanmış tüm şahitler arasında ara.
    for (final item in s.items) {
      if (!s.selectedItemIds.contains(item.id)) continue;
      final w = item.witness;
      if (w == null) continue;
      if (currentUserId != null && w.id == currentUserId) continue;

      final canWitness = target.witnesses.isEmpty || target.witnesses.any((x) => x.id == w.id);
      if (canWitness) return w;
    }
    return null;
  }

  // ── FAZ 2: Toplu Check → Kuyruk ─────────────────────────────────────────

  /// "Alıma Başla" — seçili kalemleri toplu check eder, kuyruğu kurar, ilk
  /// çekmeceyi açar. Şahit gereken ama şahidi olmayan kalem varsa engellenir.
  Future<void> startIntake() async {
    final s = state;
    if (s is! MasterIntakeSelection || !s.canStart) return;

    final selected = s.selectedItems;

    // 1. Şahit kontrolü.
    final missingWitness = selected.firstWhereOrNull(
      (it) => it.needsWitness(currentStation: _currentStation) && it.witness == null,
    );
    if (missingWitness != null) {
      state = MasterIntakeError(message: 'Şahit girişi yapılması gerekmektedir.', previousState: s);
      return;
    }

    // 2. Toplu check — UI kilitlenir.
    state = s.copyWith(isChecking: true);
    final userId = ref.read(authNotifierProvider.notifier).currentUser?.id ?? 0;

    final targets = <IntakeTarget>[];
    final statuses = Map<int, IntakeCheckStatus>.from(s.checkStatuses);

    for (final item in selected) {
      statuses[item.id] = const CheckLoading();
      state = s.copyWith(isChecking: true, checkStatuses: statuses);

      final result = await _checkIntake.call(
        CheckIntakeParams(
          type: _type,
          userId: userId,
          hospitalizationId: _hospitalizationId,
          prescriptionDetailId: item.prescriptionItem?.id,
          assignment: item.assignment ?? MedicineAssignment(),
          dosePiece: item.dosePiece ?? 0,
        ),
      );

      var failed = false;
      String? failMsg;
      result.when(
        ok: (details) {
          statuses[item.id] = const CheckSuccess();
          targets.add(IntakeTarget(item: item, details: _prepareCounting(item, details)));
        },
        error: (e) {
          failed = true;
          failMsg = e.message;
          statuses[item.id] = CheckFailed(message: e.message);
        },
      );

      // Bir kalem check'te düşerse: o kalemi seçimden çıkar, diğerleriyle devam et.
      if (failed) {
        MedLogger.error(
          unit: 'MasterIntakeNotifier',
          swreq: 'SWREQ-CLI-MINTAKE-002',
          message: 'Kalem check başarısız, kuyruğa alınmadı',
          context: {'itemId': item.id, 'error': failMsg},
        );
      }
    }

    // Hiç geçerli hedef yoksa hata göster, Selection'a dön.
    if (targets.isEmpty) {
      state = MasterIntakeError(
        message: 'Seçilen ilaçlar için alım yapılamadı.',
        previousState: s.copyWith(isChecking: false, checkStatuses: statuses),
      );
      return;
    }

    // 3. Kuyruğu kur.
    final jobs = IntakeQueueBuilder.build(targets);
    if (jobs.isEmpty) {
      state = MasterIntakeError(
        message: 'Alınacak çekmece bulunamadı.',
        previousState: s.copyWith(isChecking: false, checkStatuses: statuses),
      );
      return;
    }

    state = MasterIntakeExecuting(
      cabinId: s.cabinId,
      hospitalization: s.hospitalization,
      intakeType: s.intakeType,
      jobs: jobs,
      currentIndex: 0,
    );
    await _openCurrentJob();
  }

  /// CountType'a göre IntakeDetail başlangıç sayım değerlerini belirler.
  /// (Eski WithdrawNotifier._prepareCounting birebir taşındı.)
  List<IntakeDetail> _prepareCounting(IntakeItem item, List<IntakeDetail> details) {
    final drug = item.medicine as Drug?;
    final countType = drug?.countType;

    for (final detail in details) {
      if (countType == CountType.normalCount) {
        final rawStock =
            item.assignment?.stocks?.firstWhereOrNull((s) => s.id == detail.stockId)?.quantity?.toDouble() ?? 0.0;
        detail.censusQuantity = item.assignment?.toDisplayQuantity(rawStock) ?? rawStock;
      } else {
        // noCount + blindCount: boş başlar.
        detail.censusQuantity = null;
      }
    }
    return details;
  }

  Future<void> _openCurrentJob() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    state = s.copyWith(jobs: _withStatus(s.jobs, s.currentIndex, RefillJobStatus.active), currentTargetIndex: 0);
    await _orchestrator.open(assignment: job.representativeAssignment);
  }

  // ── Sayım güncelleme (aktif job içinde) ──────────────────────────────────

  /// Kübik: aktif gözün belirli detayının sayımını günceller.
  void onCubicCountChanged(int detailIndex, double? value) =>
      _updateTarget(state is MasterIntakeExecuting ? (state as MasterIntakeExecuting).currentTargetIndex : 0, (t) {
        return t.withCountAt(detailIndex, value);
      });

  /// Birim doz/standart: targetIndex'teki hedefin belirli detayının sayımı.
  void onStepCountChanged(int targetIndex, int detailIndex, double? value) =>
      _updateTarget(targetIndex, (t) => t.withCountAt(detailIndex, value));

  void _updateTarget(int targetIndex, IntakeTarget Function(IntakeTarget) update) {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null || targetIndex < 0 || targetIndex >= job.targets.length) return;

    final newTargets = List<IntakeTarget>.from(job.targets);
    newTargets[targetIndex] = update(newTargets[targetIndex]);

    final newJobs = List<IntakeDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

  // ── Alımı tamamla ────────────────────────────────────────────────────────

  /// "Alımı tamamla" / "Sonraki göz":
  ///   - Kübik: aktif gözün CompleteIntake'i HEMEN atılır; başarılıysa sıradaki
  ///     lid açılır, son göz ise çekmece kapanışı tetiklenir.
  ///   - Birim doz/standart: çekmece kapanışı tetiklenir; kayıt Closed'da yapılır.
  Future<void> confirmCurrent() async {
    final s = state;
    MedLogger.error(
      unit: 'MasterIntakeNotifier',
      swreq: 'SWREQ-CLI-MINTAKE-002',
      message: 'confirmCurrent çağrıldı',
      context: {'stateType': s.runtimeType.toString()},
    );
    if (s is! MasterIntakeExecuting) {
      MedLogger.error(
        unit: 'MasterIntakeNotifier',
        swreq: 'SWREQ-CLI-MINTAKE-002',
        message: 'GUARD: state Executing değil → çıkıldı',
        context: {'stateType': s.runtimeType.toString()},
      );
      return;
    }
    final job = s.currentJob;
    if (job == null) {
      MedLogger.error(
        unit: 'MasterIntakeNotifier',
        swreq: 'SWREQ-CLI-MINTAKE-002',
        message: 'GUARD: currentJob null → çıkıldı',
        context: {'currentIndex': s.currentIndex, 'jobsLen': s.jobs.length},
      );
      return;
    }

    MedLogger.error(
      unit: 'MasterIntakeNotifier',
      swreq: 'SWREQ-CLI-MINTAKE-002',
      message: 'confirmCurrent: job çözüldü',
      context: {
        'isKubik': job.isKubik,
        'currentTargetIndex': s.currentTargetIndex,
        'targetsLen': job.targets.length,
        'canComplete': job.canComplete,
      },
    );

    if (!job.isKubik) {
      if (!job.canComplete) {
        MedLogger.error(
          unit: 'MasterIntakeNotifier',
          swreq: 'SWREQ-CLI-MINTAKE-002',
          message: 'GUARD: birim doz job.canComplete false → çıkıldı',
          context: {
            'targetsValid': job.targets.map((t) => t.isValid).toList(),
            'needsCount': job.targets.map((t) => t.needsCount).toList(),
          },
        );
        return;
      }
      MedLogger.error(
        unit: 'MasterIntakeNotifier',
        swreq: 'SWREQ-CLI-MINTAKE-002',
        message: 'birim doz: confirmClose çağrılıyor (kayıt Closed\'da)',
        context: const {},
      );
      _orchestrator.confirmClose();
      return;
    }

    // Kübik — aktif gözü kaydet.
    final target = s.currentTarget;
    if (target == null || !target.isValid) {
      MedLogger.error(
        unit: 'MasterIntakeNotifier',
        swreq: 'SWREQ-CLI-MINTAKE-002',
        message: 'GUARD: kübik target null/invalid → çıkıldı',
        context: {
          'targetNull': target == null,
          'isValid': target?.isValid,
          'needsCount': target?.needsCount,
          'detailsLen': target?.details.length,
        },
      );
      return;
    }

    MedLogger.error(
      unit: 'MasterIntakeNotifier',
      swreq: 'SWREQ-CLI-MINTAKE-002',
      message: 'kübik: _saveTarget çağrılıyor',
      context: {'detailsLen': target.details.length, 'prescriptionDetailId': target.item.prescriptionItem?.id},
    );

    state = s.copyWith(isSaving: true);
    final ok = await _saveTarget(target);
    final saved = state;
    if (saved is! MasterIntakeExecuting) return; // hata → MasterIntakeError'a geçti
    if (!ok) return;

    await _advanceCubicLid();
  }

  /// Tek bir hedefin CompleteIntake isteğini atar. Hata olursa state'i
  /// MasterIntakeError(isQueueError) yapar ve false döner.
  Future<bool> _saveTarget(IntakeTarget target) async {
    final item = target.item;
    MedLogger.error(
      unit: 'MasterIntakeNotifier',
      swreq: 'SWREQ-CLI-MINTAKE-002',
      message: '_saveTarget: completeIntake.call ÖNCESİ',
      context: {
        'type': _type.toString(),
        'prescriptionDetailId': item.prescriptionItem?.id,
        'hospitalizationId': _hospitalizationId,
        'witnessUserId': item.witness?.id,
        'detailsLen': target.details.length,
        'details': target.details
            .map((d) => {'stockId': d.stockId, 'dose': d.dosePiece, 'census': d.censusQuantity})
            .toList(),
      },
    );
    final result = await _completeIntake.call(
      IntakeParams(
        type: _type,
        prescriptionDetailId: item.prescriptionItem?.id,
        hospitalizationId: _hospitalizationId,
        userId: item.witness?.id,
        details: target.details,
      ),
    );

    var ok = true;
    result.when(
      ok: (_) {
        MedLogger.error(
          unit: 'MasterIntakeNotifier',
          swreq: 'SWREQ-CLI-MINTAKE-002',
          message: '_saveTarget: completeIntake OK',
          context: const {},
        );
      },
      error: (e) {
        ok = false;
        MedLogger.error(
          unit: 'MasterIntakeNotifier',
          swreq: 'SWREQ-CLI-MINTAKE-002',
          message: '_saveTarget: completeIntake HATA',
          context: {'error': e.message},
        );
        final s = state;
        if (s is MasterIntakeExecuting) {
          state = MasterIntakeError(message: e.message, previousState: s.copyWith(isSaving: false), isQueueError: true);
        }
      },
    );
    return ok;
  }

  /// Kübik job içinde sıradaki lid'e geçer; son lid ise çekmece kapanışını başlatır.
  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final nextTarget = s.currentTargetIndex + 1;
    if (nextTarget >= job.targets.length) {
      // Tüm gözler bitti → çekmeceyi kapatmaya geç.
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
      return;
    }

    state = s.copyWith(currentTargetIndex: nextTarget, isSaving: false);
    final cellAssignment = job.targets[nextTarget].assignment;
    if (cellAssignment != null) await _orchestrator.openCubicLid(cellAssignment);
  }

  // ── Orchestrator stage geçişleri ──────────────────────────────────────────

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerOpened():
        _onDrawerOpened();
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerFailed(:final message):
        _onDrawerFailed(message);
      default:
        break;
    }
  }

  /// Ana çekmece açıldı. Kübikse ilk hedef gözün lid'ini aç.
  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik || job.targets.isEmpty) return;

    final firstCell = job.targets[s.currentTargetIndex].assignment;
    if (firstCell != null) await _orchestrator.openCubicLid(firstCell);
  }

  /// Aktif çekmece fiziksel olarak kapandı.
  ///   - Birim doz/standart: tüm hedefleri şimdi kaydet (her biri ayrı istek).
  ///   - Kübik: kayıt zaten lid bazlı yapıldı → doğrudan sıradaki job.
  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      state = s.copyWith(isSaving: true);
      for (final target in job.targets) {
        final ok = await _saveTarget(target);
        if (!ok) return; // hata → MasterIntakeError(isQueueError)
      }
    }

    // Job'ı completed işaretle, orchestrator'ı sıfırla, sıradaki job'a geç.
    final completedJobs = _withStatus(s.jobs, s.currentIndex, RefillJobStatus.completed);
    final nextIndex = s.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= s.jobs.length) {
      await _reloadSelectionAfterQueue();
      return;
    }

    state = MasterIntakeExecuting(
      cabinId: s.cabinId,
      hospitalization: s.hospitalization,
      intakeType: s.intakeType,
      jobs: completedJobs,
      currentIndex: nextIndex,
      currentTargetIndex: 0,
      isSaving: false,
    );
    await _openCurrentJob();
  }

  void _onDrawerFailed(String message) {
    final s = state;
    if (s is MasterIntakeExecuting) {
      state = MasterIntakeError(message: message, previousState: s.copyWith(isSaving: false), isQueueError: true);
    }
  }

  // ── Durdur / Hata kurtarma ────────────────────────────────────────────────

  Future<void> stopQueue() async {
    final s = state;
    await _orchestrator.stop();
    if (s is MasterIntakeExecuting) {
      await _reloadSelectionAfterQueue();
    }
  }

  /// Kuyruk hatası sonrası "Devam": hatalı çekmeceyi failed işaretle, sıradakine geç.
  Future<void> continueAfterError() async {
    final s = state;
    if (s is! MasterIntakeError || !s.isQueueError) return;
    final prev = s.previousState;
    if (prev is! MasterIntakeExecuting) return;

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, RefillJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue();
      return;
    }

    state = MasterIntakeExecuting(
      cabinId: prev.cabinId,
      hospitalization: prev.hospitalization,
      intakeType: prev.intakeType,
      jobs: markedJobs,
      currentIndex: nextIndex,
      isSaving: false,
    );
    await _openCurrentJob();
  }

  /// Kuyruk hatası sonrası "Sonlandır": kuyruğu bitir (tamamlananlar korunur).
  Future<void> abortAfterError() async {
    final s = state;
    if (s is! MasterIntakeError) return;
    final prev = s.previousState;
    await _orchestrator.stop();

    if (prev is MasterIntakeExecuting) {
      await _reloadSelectionAfterQueue();
    } else {
      state = prev;
    }
  }

  void dismissError() {
    final s = state;
    if (s is! MasterIntakeError) return;
    // Selection'a dönerken check loading bayrağını temizle.
    final prev = s.previousState;
    if (prev is MasterIntakeSelection) {
      state = prev.copyWith(isChecking: false);
    } else {
      state = prev;
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  /// Kuyruk bittiğinde: alım kalemlerini yeniden çek (stoklar değişti) ve temiz
  /// Selection fazına dön. Ayrı "başarılı" ekranı yoktur. Hasta yoksa NoPatient.
  Future<void> _reloadSelectionAfterQueue() async {
    if (_hospitalization == null) {
      state = MasterIntakeNoPatient(cabinId: _cabinId);
      return;
    }
    state = const MasterIntakeLoading();
    await _loadItems(refreshAssignments: false);
  }

  List<IntakeDrawerJob> _withStatus(List<IntakeDrawerJob> jobs, int index, RefillJobStatus status) {
    final next = List<IntakeDrawerJob>.from(jobs);
    next[index] = next[index].copyWith(status: status);
    return next;
  }
}
