// [SWREQ-CLI-MINTAKE-002] [IEC 62304 §5.5]

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator.dart';
import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../auth/auth.dart';
import '../../intake.dart';
import 'redirected_intake_orders_notifier.dart';

final masterIntakeNotifierProvider = NotifierProvider<MasterIntakeNotifier, MasterIntakeState>(
  MasterIntakeNotifier.new,
);

class MasterIntakeNotifier extends Notifier<MasterIntakeState> {
  late final MasterDrawerOrchestrator _orchestrator;

  /// Aktif alımın tipi (ordered/orderless/urgent/free) — selectPatient'ta set.
  IntakeType _type = IntakeType.orderless;

  /// Orderlı alımda hospitalization gerekir.
  int? _hospitalizationId;

  /// Aktif seçili hasta (state geçişlerinde taşınması için tutulur).
  Hospitalization? _hospitalization;

  bool _isRedirectedQueue = false;

  GetIntakeItemsUseCase get _getItems => ref.read(getIntakeItemsUseCaseProvider);
  CheckIntakeUseCase get _checkIntake => ref.read(checkIntakeUseCaseProvider);
  CompleteIntakeUseCase get _completeIntake => ref.read(completeIntakeUseCaseProvider);
  GetEquivalentIntakesUseCase get _getEquivalents => ref.read(getEquivalentIntakesUseCaseProvider);
  CheckEquivalentIntakeUseCase get _checkEquivalentIntake => ref.read(checkEquivalentIntakeUseCaseProvider);
  CompleteEquivalentIntakeUseCase get _completeEquivalentIntake => ref.read(completeEquivalentIntakeUseCaseProvider);
  GetOtherStationMedicinesUseCase get _getOtherStations => ref.read(getOtherStationMedicinesUseCaseProvider);
  RedirectIntakeUseCase get _redirectIntake => ref.read(redirectIntakeUseCaseProvider);
  GetPrescriptionDetailUseCase get _getPrescriptionDetail => ref.read(getPrescriptionDetailUseCaseProvider);
  CheckRedirectedIntakeUseCase get _checkRedirectedIntake => ref.read(checkRedirectedIntakeUseCaseProvider);
  CompleteRedirectedIntakeUseCase get _completeRedirectedIntake => ref.read(completeRedirectedIntakeUseCaseProvider);
  GetStationAssignmentsUseCase get _getAssignments => ref.read(getStationAssignmentsUseCaseProvider);

  Station? _currentStation;

  /// needsWitness kararı için çözülmüş kullanıcı istasyonu (init'te bir kez set edilir).
  Station? get currentStation => _currentStation;

  @override
  MasterIntakeState build() {
    _orchestrator = MasterDrawerOrchestrator(ref: ref);
    _orchestrator.init(onStageChange: _onDrawerStage);
    ref.onDispose(_orchestrator.dispose);

    // Hasta seçim notifier'ındaki filtre veya görünüm tipi değişince (sadece
    // MedicineSelection fazındayken, hasta zaten seçiliyken) tepki veririz.
    // İlk boot senkronizasyonu BURADA DEĞİL, init()'te — bkz. aşağı.
    ref.listen(patientSelectionNotifierProvider, (previous, next) {
      final prev = previous is PatientSelectionReady ? previous : null;
      final nxt = next is PatientSelectionReady ? next : null;
      if (prev == null || nxt == null) return;

      final s = state;
      if (s is! MasterIntakeMedicineSelection) return;

      if (prev.createdUrgentPatient != null && nxt.createdUrgentPatient == null) {
        _hospitalization = null;
        _hospitalizationId = null;
        unawaited(_orchestrator.stop());
        state = const MasterIntakePatientSelection();
        return;
      }

      if (prev.intakeMode != nxt.intakeMode) {
        _type = switch (nxt.intakeMode) {
          PatientIntakeMode.ordered => IntakeType.ordered,
          PatientIntakeMode.orderless => IntakeType.orderless,
          PatientIntakeMode.free => IntakeType.free,
        };
        unawaited(_loadItems());
        return;
      }

      if (prev.filter != nxt.filter) {
        unawaited(_loadItems());
        return;
      }

      if ((prev.viewType != nxt.viewType)) {
        _hospitalization = null;
        _hospitalizationId = null;
        unawaited(_orchestrator.stop());
        state = const MasterIntakePatientSelection();
      }
    });

    return const MasterIntakeUninitialized();
  }

  Future<void> init(StationCabinsContext ctx) async {
    _hospitalization = null;
    _hospitalizationId = null;
    _currentStation = ctx.station;

    await _orchestrator.stop();

    await ref.read(patientSelectionNotifierProvider.notifier).init(PatientSelectionConfig.intake, _currentStation!);

    if (state is MasterIntakeUninitialized) {
      state = const MasterIntakePatientSelection();
    }
  }

  /// `CabinPatientPickerPanel` üzerinden hasta seçildiğinde çağrılır. Tip,
  /// hasta seçim modundan (orderless/ordered) türetilip dışarıdan geçirilir.
  Future<void> selectPatient(Hospitalization hospitalization, IntakeType type) async {
    _type = type;
    _hospitalization = hospitalization;
    _hospitalizationId = hospitalization.id;

    await _orchestrator.stop();

    state = const MasterIntakeLoading();
    await _loadItems();
  }

  Future<void> _loadItems({bool refreshAssignments = false}) async {
    final hospitalization = _hospitalization;
    if (hospitalization == null) {
      state = MasterIntakePatientSelection();
      return;
    }

    final cur = state;
    if (cur is MasterIntakeMedicineSelection) {
      state = cur.copyWith(isFetching: true);
    }

    final patientState = ref.read(patientSelectionNotifierProvider);
    final filter = patientState is PatientSelectionReady ? patientState.filter : PatientFilterType.all;

    final result = await _getItems.call(
      GetIntakeItemsParams(
        type: _type,
        hospitalizationId: _hospitalizationId,
        refreshAssignments: refreshAssignments,
        filter: filter,
      ),
    );
    result.when(
      ok: (items) {
        // Filtre "Order Saati Gelenler" (ordersDue) ise, alınabilir tüm
        // kalemler OTOMATİK seçili gelir — kullanıcı tek tek işaretlemek
        // zorunda kalmaz. Diğer filtrelerde (all/upcoming/overdue/...) hiç
        // otomatik seçim yapılmaz; o kalemler zaten UI'da seçilemez hale
        // getirilir (bkz. RxOrdersContent onTap koşulu).
        final bool autoSelectAll = _type == IntakeType.ordered && filter == PatientFilterType.ordersDue;

        final autoSelectedIds = autoSelectAll
            ? items
                  .where((it) => !it.hasNoStock && !it.isRedirected && !it.inCaseOfNecessity)
                  .map((it) => it.id)
                  .toSet()
            : const <int>{};

        state = MasterIntakeMedicineSelection(
          hospitalization: hospitalization,
          intakeType: _type,
          items: items,
          selectedItemIds: autoSelectedIds,
        );
      },
      error: (e) => state = MasterIntakeError(
        failure: CabinApiFailure(message: e.message),
        previousState: MasterIntakeMedicineSelection(
          hospitalization: hospitalization,
          intakeType: _type,
          items: const [],
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! MasterIntakeMedicineSelection || s.isChecking) return;
    state = s.copyWith(search: value);
  }

  /// Bir kalemi seçer/çıkarır. Seçimde doz 0/null ise 1'e çekilir.
  void toggleItem(int itemId) {
    final s = state;
    if (s is! MasterIntakeMedicineSelection || s.isChecking) return;

    final next = Set<int>.from(s.selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
      state = s.copyWith(selectedItemIds: next);
      return;
    }

    next.add(itemId);

    final items = s.items.map((it) {
      if (it.id != itemId) return it;
      final dose = it.dosePiece;
      if (dose != null && dose != 0) return it;

      final medicine = it.medicine;
      final initialDose = (medicine is Drug && medicine.isMeasureUnit)
          ? (medicine.doseMeasureUnit?.toDouble() ?? 1.0)
          : 1.0;
      return it.copyWith(dosePiece: initialDose);
    }).toList();

    state = s.copyWith(items: items, selectedItemIds: next);
  }

  /// Bir kalemin alım dozunu günceller (limit validasyonu ile).
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
    if (s is! MasterIntakeMedicineSelection || s.isChecking) return;

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

      final double stepFloor = medicine.isMeasureUnit ? (medicine.doseMeasureUnit?.toDouble() ?? 1.0) : 1.0;
      final double minLimit = (isOrdered && !canLower) ? upperLimitFromOrder : stepFloor;

      final double physicalLimit = item.assignment?.totalQuantity ?? 0.0;
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
    if (s is! MasterIntakeMedicineSelection) return;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;
    if (currentUserId != null && user.id == currentUserId) return;

    IntakeItem assignTo(IntakeItem item) => item.isEquivalentIntake
        ? item.copyWith(equivalentWitnessContext: item.activeWitnessContext.copyWith(witness: user))
        : item.copyWith(witnessContext: item.activeWitnessContext.copyWith(witness: user));

    final items = s.items.map((item) {
      if (item.id == itemId) return assignTo(item);

      final isSelected = s.selectedItemIds.contains(item.id);
      if (!isSelected || item.activeWitnessContext.witness != null) return item;

      final canWitness =
          item.activeWitnessContext.witnesses.isEmpty ||
          item.activeWitnessContext.witnesses.any((w) => w.id == user.id);
      return canWitness ? assignTo(item) : item;
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
    if (s is! MasterIntakeMedicineSelection) return null;
    final target = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (target == null) return null;

    final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;

    for (final item in s.items) {
      if (!s.selectedItemIds.contains(item.id)) continue;
      final w = item.activeWitnessContext.witness;
      if (w == null) continue;
      if (currentUserId != null && w.id == currentUserId) continue;

      final targetWitnesses = target.activeWitnessContext.witnesses;
      final canWitness = targetWitnesses.isEmpty || targetWitnesses.any((x) => x.id == w.id);
      if (canWitness) return w;
    }
    return null;
  }
  // ── FAZ 3: Toplu Check → Kuyruk ─────────────────────────────────────────

  /// "Alıma Başla" — seçili kalemleri toplu check eder, kuyruğu kurar, ilk
  /// çekmeceyi açar. Şahit gereken ama şahidi olmayan kalem varsa engellenir.
  Future<void> startIntake() async {
    _isRedirectedQueue = false;
    final s = state;
    if (s is! MasterIntakeMedicineSelection || !s.canStart) return;

    final selected = s.selectedItems;

    final missingWitness = selected.firstWhereOrNull(
      (it) => it.needsWitness(currentStation: _currentStation) && it.activeWitnessContext.witness == null,
    );

    if (missingWitness != null) {
      state = MasterIntakeError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.witnessRequired),
        previousState: s,
      );
      return;
    }

    state = s.copyWith(isChecking: true);
    final userId = ref.read(authNotifierProvider.notifier).currentUser?.id ?? 0;

    final normalItems = selected.where((it) => !it.isEquivalentIntake).toList();
    final equivalentItems = selected.where((it) => it.isEquivalentIntake).toList();

    // ── Normal itemlar: mevcut toplu check akışı ──
    final batchResult = normalItems.isEmpty
        ? null
        : await _checkIntake.callBatch(
            type: _type,
            userId: userId,
            hospitalizationId: _hospitalizationId,
            items: normalItems,
            onItemStatusChanged: (itemId, status) {
              final current = state;
              if (current is! MasterIntakeMedicineSelection) return;
              final statuses = Map<int, IntakeCheckState>.from(current.checkStates)..[itemId] = status;
              state = current.copyWith(isChecking: true, checkStates: statuses);
            },
          );

    // ── Muadilli itemlar: checkEquivalentIntake ayrı ayrı çağrılır ──
    final equivalentTargets = <IntakeTarget>[];
    List<MedicineAssignment> allAssignments = const [];

    if (equivalentItems.isNotEmpty) {
      final assignmentsResult = await _getAssignments();
      assignmentsResult.when(ok: (list) => allAssignments = list, error: (_) => allAssignments = const []);
    }

    for (final item in equivalentItems) {
      final prescriptionDetailId = item.id;
      final materialId = item.selectedEquivalent?.materialId;
      if (materialId == null) continue;

      final current = state;
      if (current is MasterIntakeMedicineSelection) {
        final statuses = Map<int, IntakeCheckState>.from(current.checkStates)..[item.id] = const CheckLoading();
        state = current.copyWith(isChecking: true, checkStates: statuses);
      }

      final result = await _checkEquivalentIntake.call(
        EquivalentIntakeParams(
          prescriptionDetailId: prescriptionDetailId,
          materialId: materialId,
          censusQuantity: item.dosePiece,
        ),
      );

      final afterCheck = state;
      if (afterCheck is! MasterIntakeMedicineSelection) return;
      final statuses = Map<int, IntakeCheckState>.from(afterCheck.checkStates);

      result.when(
        ok: (_) {
          final target = _buildEquivalentTarget(item, allAssignments);
          if (target != null) {
            equivalentTargets.add(target);
            statuses[item.id] = const CheckSuccess();
          } else {
            statuses[item.id] = const CheckFailed(message: null);
          }
        },
        error: (e) => statuses[item.id] = CheckFailed(message: e.message),
      );
      state = afterCheck.copyWith(checkStates: statuses);
    }

    final afterChecks = state;
    if (afterChecks is! MasterIntakeMedicineSelection) return;

    final allTargets = [...(batchResult?.targets ?? const <IntakeTarget>[]), ...equivalentTargets];
    final allStatuses = {...afterChecks.checkStates, ...(batchResult?.statuses ?? const <int, IntakeCheckState>{})};

    if (allTargets.isEmpty) {
      state = MasterIntakeError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
        previousState: afterChecks.copyWith(isChecking: false, checkStates: allStatuses),
      );
      return;
    }

    final jobs = IntakeQueueBuilder.build(allTargets);
    if (jobs.isEmpty) {
      state = MasterIntakeError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noDrawerFound),
        previousState: afterChecks.copyWith(isChecking: false, checkStates: allStatuses),
      );
      return;
    }

    state = MasterIntakeExecuting(
      hospitalization: s.hospitalization,
      intakeType: s.intakeType,
      jobs: jobs,
      currentIndex: 0,
    );
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  /// job.targets'ı fiziksel adım (aynı stockId'yi paylaşan hedef grubu)
  /// bazında gruplar. Kübik VE birim doz için ORTAK — tek fark, aralarındaki
  /// geçişin yazılımsal (lid) mi yoksa fiziksel (açma/kapama) mı olduğu.
  List<IntakeCellGroup> _jobSteps(IntakeDrawerJob job) => IntakeCellGrouper.group(job.targets);

  Future<void> _openJobAt({required int jobIndex, required int targetIndex}) async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    if (jobIndex < 0 || jobIndex >= s.jobs.length) return;
    final job = s.jobs[jobIndex];

    state = s.copyWith(
      jobs: _withStatus(s.jobs, jobIndex, CabinOperationJobStatus.active),
      currentIndex: jobIndex,
      currentTargetIndex: targetIndex,
      isSaving: false,
    );

    if (job.isKubik) {
      await _orchestrator.open(assignment: job.representativeAssignment);
      return;
    }

    // Birim doz: her fiziksel PORT kendi aç→işle→kapat döngüsünü yaşar (aynı
    // satırda farklı ilaçlar farklı portlarda olabilir - dolumdaki per-target
    // açma deseniyle tutarlı, bkz. master-refill-flow skill). [targetIndex]
    // burada STEP index'idir (job.targets index'i DEĞİL) - aynı stockId'yi
    // paylaşan hedefler (aynı fiziksel göz, farklı reçete kalemleri) doğal
    // olarak tek adımda birlikte açılır/kaydedilir, ekstra bir gruplamaya
    // gerek kalmadı (2026 düzeltmesi).
    final steps = _jobSteps(job);
    if (targetIndex < 0 || targetIndex >= steps.length) return;
    final (ti, _) = steps[targetIndex].refs.first;
    final target = job.targets[ti];
    final assignment = target.assignment;
    if (assignment == null) return;
    final stepNo = IntakeQueueBuilder.resolveStepNoForTarget(target);
    await _orchestrator.open(assignment: assignment, explicitTargetStep: stepNo);
  }

  // ── Sayım güncelleme (aktif job içinde) ──────────────────────────────────

  /// Kübik: aktif gözün belirli detayının sayımını günceller.
  void onCubicCountChanged(int detailIndex, double? value) =>
      _updateTarget(state is MasterIntakeExecuting ? (state as MasterIntakeExecuting).currentTargetIndex : 0, (t) {
        return t.withCountAt(detailIndex, value);
      });

  /// [group] içindeki TÜM (targetIndex, detailIndex) referanslarına aynı
  /// sayım değerini yazar — aynı fiziksel stok birden fazla target'tan
  /// (farklı prescriptionDetail/saat) referans veriliyorsa hepsi senkron kalır.
  void onGroupCountChanged(IntakeCellGroup group, double? value) {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final newTargets = List<IntakeTarget>.from(job.targets);
    for (final (ti, di) in group.refs) {
      newTargets[ti] = newTargets[ti].withCountAt(di, value);
    }

    final newJobs = List<IntakeDrawerJob>.from(s.jobs);
    newJobs[s.currentIndex] = job.copyWith(targets: newTargets);
    state = s.copyWith(jobs: newJobs);
  }

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
  ///   - Kübik: aktif STEP'in kaydı HEMEN atılır, sıradaki lid yazılımsal
  ///     açılır (fiziksel kapanma yok).
  ///   - Birim doz: aktif STEP'in (yani aktif PORTUN) kaydı HEMEN atılır,
  ///     ardından fiziksel kapanış tetiklenir - sıradaki port (varsa)
  ///     _onCurrentDrawerClosed'da yeni bir open() ile açılır.
  Future<void> confirmCurrent() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final target = s.currentTarget;
    if (target == null || !target.isValid) return;

    state = s.copyWith(isSaving: true);
    final ok = await _saveCurrentStep(job, s);
    final saved = state;
    if (saved is! MasterIntakeExecuting || !ok) return;

    if (job.isKubik) {
      await _advanceCubicLid();
    } else {
      state = saved.copyWith(isSaving: false);
      _orchestrator.confirmClose();
    }
  }

  /// Aktif STEP'teki (aynı stockId'yi paylaşan) TÜM hedefleri kaydeder. Her
  /// hedef için AYRI complete-intake isteği atılır (backend her
  /// prescriptionDetailId'yi ayrı reçete kalemi sayıyor), ama sayım miktarı
  /// yalnızca İLK hedefte gerçek kullanıcı girdisini taşır - diğerleri aynı
  /// fiziksel sayımı tekrar raporlamaz. Kübik/birim doz FARKI YOK - eskiden
  /// "_saveCurrentCubicStep" adındaydı, artık ikisi için de kullanılıyor.
  Future<bool> _saveCurrentStep(IntakeDrawerJob job, MasterIntakeExecuting s) async {
    final steps = _jobSteps(job);
    if (s.currentTargetIndex < 0 || s.currentTargetIndex >= steps.length) return false;
    final step = steps[s.currentTargetIndex];

    final targetIndices = step.refs.map((r) => r.$1).toSet().toList()..sort();

    for (var i = 0; i < targetIndices.length; i++) {
      final ok = await _saveTarget(job.targets[targetIndices[i]], suppressCensusQuantity: i != 0);
      if (!ok) return false;
    }
    return true;
  }

  /// Tek bir hedefin CompleteIntake isteğini atar. Hata olursa state'i
  /// MasterIntakeError(isQueueError) yapar ve false döner.
  Future<bool> _saveTarget(IntakeTarget target, {bool suppressCensusQuantity = false}) async {
    final item = target.item;

    final details = suppressCensusQuantity
        ? target.details.map((d) => IntakeDetail(stockId: d.stockId, dosePiece: d.dosePiece)).toList()
        : target.details;

    final result = item.isRedirectedIntake
        ? await _completeRedirectedIntake.call(
            referralId: item.redirectedOrder!.id,
            censusQuantity: suppressCensusQuantity ? null : details.firstOrNull?.censusQuantity,
          )
        : item.isEquivalentIntake
        ? await _completeEquivalentIntake.call(
            EquivalentIntakeParams(
              prescriptionDetailId: item.id,
              materialId: item.selectedEquivalent!.materialId ?? 0,
              censusQuantity: suppressCensusQuantity
                  ? null
                  : (details.firstOrNull?.censusQuantity ?? details.firstOrNull?.dosePiece),
            ),
          )
        : await _completeIntake.call(
            IntakeParams(
              type: _type,
              prescriptionDetailId: item.id,
              hospitalizationId: _hospitalizationId,
              userId: item.witnessContext.witness?.id,
              details: details,
            ),
          );

    var ok = true;
    result.when(
      ok: (_) {},
      error: (e) {
        ok = false;
        final s = state;
        if (s is MasterIntakeExecuting) {
          state = MasterIntakeError(
            failure: CabinApiFailure(message: e.message),
            previousState: s.copyWith(isSaving: false),
            //isQueueError: true,
          );
        }
      },
    );
    return ok;
  }

  /// SADECE kübik: sıradaki lid'e yazılımsal geçer (fiziksel kapanma yok).
  Future<void> _advanceCubicLid() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    final steps = _jobSteps(job);
    final nextStep = s.currentTargetIndex + 1;

    if (nextStep >= steps.length) {
      state = s.copyWith(isSaving: false);
      _orchestrator.confirmClose();
      return;
    }

    state = s.copyWith(currentTargetIndex: nextStep, isSaving: false);
    final (ti, _) = steps[nextStep].refs.first;
    final cellAssignment = job.targets[ti].assignment;
    if (cellAssignment != null) await _orchestrator.openCubicLid(cellAssignment);
  }

  void _onDrawerStage(MasterDrawerStage? previous, MasterDrawerStage current) {
    switch (current) {
      case MasterDrawerOpened():
        if (previous is MasterDrawerWaitingForPull) {
          _onDrawerOpened();
        }
      case MasterDrawerClosed():
        _onCurrentDrawerClosed();
      case MasterDrawerLidFailed(:final failure, :final detail):
        MedLogger.warn(
          unit: 'MasterIntake',
          swreq: 'SWREQ-CLI-MINTAKE-002',
          message: 'Kübik kapak açma reddedildi',
          context: {'failure': failure.name, 'detail': detail},
        );
      case MasterDrawerFailed(:final failure, :final detail):
        _onDrawerFailed(failure, detail: detail);
      default:
        break;
    }
  }

  /// Reddedilen (LidFailed) bir kübik gözü aynı hedefle tekrar dener.
  Future<void> retryCurrentLid() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik) return;

    final steps = _cubicSteps(job);
    if (steps.isEmpty || s.currentTargetIndex < 0 || s.currentTargetIndex >= steps.length) return;
    final (ti, _) = steps[s.currentTargetIndex].refs.first;
    final cellAssignment = job.targets[ti].assignment;
    if (cellAssignment != null) await _orchestrator.openCubicLid(cellAssignment);
  }

  List<IntakeCellGroup> _cubicSteps(IntakeDrawerJob job) => IntakeCellGrouper.group(job.targets);

  /// Ana çekmece açıldı. Kübikse ilk hedef gözün lid'ini aç.
  Future<void> _onDrawerOpened() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null || !job.isKubik || job.targets.isEmpty) return;

    final steps = _cubicSteps(job);
    if (steps.isEmpty) return;
    final (ti, _) = steps[s.currentTargetIndex.clamp(0, steps.length - 1)].refs.first;
    final firstCell = job.targets[ti].assignment;
    if (firstCell != null) await _orchestrator.openCubicLid(firstCell);
  }

  /// Aktif çekmece fiziksel olarak kapandı.
  ///   - Kübik: kayıt zaten step bazlı yapıldı (confirmCurrent'ta) → job
  ///     tamamlandı, sıradaki job'a geç.
  ///   - Birim doz: bu PORTUN kaydı zaten confirmCurrent'ta yapıldı. Job'da
  ///     başka step (başka port) varsa YENİ bir open() ile onu aç; yoksa job
  ///     tamamlandı, sıradaki job'a geç. ARTIK burada toplu kayıt YAPILMAZ
  ///     (eski _saveAllGroups çağrısı kaldırıldı - kayıt tek yerde,
  ///     confirmCurrent'te, kübikle aynı desende).
  Future<void> _onCurrentDrawerClosed() async {
    final s = state;
    if (s is! MasterIntakeExecuting) return;
    final job = s.currentJob;
    if (job == null) return;

    if (!job.isKubik) {
      final steps = _jobSteps(job);
      final nextStep = s.currentTargetIndex + 1;
      if (nextStep < steps.length) {
        await _orchestrator.stop();
        await _openJobAt(jobIndex: s.currentIndex, targetIndex: nextStep);
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

    state = MasterIntakeExecuting(
      hospitalization: s.hospitalization,
      intakeType: s.intakeType,
      jobs: completedJobs,
      currentIndex: nextIndex,
      currentTargetIndex: 0,
      isSaving: false,
    );
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
  }

  void _onDrawerFailed(MasterDrawerFailure failure, {String? detail}) {
    final s = state;
    if (s is MasterIntakeExecuting) {
      state = MasterIntakeError(
        failure: CabinMasterDrawerFailure(failure: failure, detail: detail),
        previousState: s.copyWith(isSaving: false),
        isQueueError: true,
      );
    }
  }

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

    final markedJobs = _withStatus(prev.jobs, prev.currentIndex, CabinOperationJobStatus.failed);
    final nextIndex = prev.currentIndex + 1;
    await _orchestrator.stop();

    if (nextIndex >= markedJobs.length) {
      await _reloadSelectionAfterQueue();
      return;
    }

    state = MasterIntakeExecuting(
      hospitalization: prev.hospitalization,
      intakeType: prev.intakeType,
      jobs: markedJobs,
      currentIndex: nextIndex,
      isSaving: false,
    );
    await _openJobAt(jobIndex: nextIndex, targetIndex: 0);
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
    // MedicineSelection'a dönerken check loading bayrağını temizle.
    final prev = s.previousState;
    if (prev is MasterIntakeMedicineSelection) {
      state = prev.copyWith(isChecking: false);
    } else {
      state = prev;
    }
  }

  /// Kuyruk bittiğinde: alım kalemlerini yeniden çek (stoklar değişti) ve temiz
  /// MedicineSelection fazına dön. Ayrı "başarılı" ekranı yoktur. Hasta yoksa
  /// PatientSelection'a döner.
  Future<void> _reloadSelectionAfterQueue() async {
    // Alım tamamlandı — sol paneldeki hasta listesi de tazelenmeli (order/
    // reçete durumu değişmiş olabilir). Redirected/normal akış ayrımından
    // ÖNCE, her durumda tetiklenir.
    unawaited(ref.read(patientSelectionNotifierProvider.notifier).refresh());

    if (_isRedirectedQueue) {
      _isRedirectedQueue = false;
      // Redirected akışın kendi state'i MasterIntakeNotifier'da değil,
      // RedirectedIntakeOrdersNotifier'da — burada yalnızca "hangi hasta
      // seçiliydi" bilgisini alıp onu tazeleriz.
      final selectedHospitalization = ref.read(redirectedIntakeOrdersNotifierProvider.notifier).selectedHospitalization;
      if (selectedHospitalization != null) {
        await ref.read(redirectedIntakeOrdersNotifierProvider.notifier).selectPatient(selectedHospitalization);
      }
      state = MasterIntakePatientSelection();
      return;
    }

    if (_hospitalization == null) {
      state = MasterIntakePatientSelection();
      return;
    }
    state = const MasterIntakeLoading();
    await _loadItems(refreshAssignments: false);
  }

  List<IntakeDrawerJob> _withStatus(List<IntakeDrawerJob> jobs, int index, CabinOperationJobStatus status) {
    final next = List<IntakeDrawerJob>.from(jobs);
    next[index] = next[index].copyWith(status: status);
    return next;
  }

  /// Bir muadili seçer; ZATEN seçiliyse tekrar tıklandığında seçimi KALDIRIR.
  void toggleEquivalentSelection(int itemId, EquivalentMedicine equivalent) {
    final s = state;
    if (s is! MasterIntakeMedicineSelection) return;
    final found = s.equivalentStates[itemId];
    if (found is! EquivalentFound) return;

    final isSameSelected = found.selected?.materialId == equivalent.materialId;
    final states = {
      ...s.equivalentStates,
      itemId: EquivalentFound(found.options, selected: isSameSelected ? null : equivalent),
    };

    final selectedIds = Set<int>.from(s.selectedItemIds);
    final items = s.items.map((it) {
      if (it.id != itemId) return it;
      if (isSameSelected) return it.copyWith(clearSelectedEquivalent: true);
      return it.copyWith(
        selectedEquivalent: equivalent,
        equivalentWitnessContext: equivalent.witnessContext,
        dosePiece: equivalent.purchaseQuantity ?? it.dosePiece,
      );
    }).toList();

    isSameSelected ? selectedIds.remove(itemId) : selectedIds.add(itemId);
    state = s.copyWith(items: items, equivalentStates: states, selectedItemIds: selectedIds);
  }

  IntakeTarget? _buildEquivalentTarget(IntakeItem item, List<MedicineAssignment> allAssignments) {
    final equivalent = item.selectedEquivalent;
    if (equivalent == null) return null;

    final resolvedMedicine = equivalent.medicine;
    if (resolvedMedicine == null) return null;

    final neededDose = item.dosePiece ?? equivalent.purchaseQuantity ?? 0;
    final stock =
        equivalent.stocks.firstWhereOrNull((s) => (s.quantity ?? 0) >= neededDose) ?? equivalent.stocks.firstOrNull;
    if (stock == null || stock.id == null) return null;

    // stock.assignment BU ENDPOINT'TE HER ZAMAN NULL (backend cabinDrawrQuantity
    // nest etmiyor) — göze özel gerçek assignment'ı cabinDrawerDetail.id
    // üzerinden ayrıca çözüyoruz.
    final cellId = stock.cabinDrawerDetail?.id;
    if (cellId == null) return null;

    final assignment = allAssignments.firstWhereOrNull(
      (a) => a.cabinDrawerDetail?.any((cell) => cell.id == cellId) ?? false,
    );
    if (assignment == null) return null;

    final resolvedItem = item.copyWith(assignment: assignment, stock: stock, medicine: resolvedMedicine);

    return IntakeTarget(
      item: resolvedItem,
      details: [IntakeDetail(stockId: stock.id!, dosePiece: neededDose)],
    );
  }

  Future<void> checkEquivalent(int itemId) async {
    final s = state;
    if (s is! MasterIntakeMedicineSelection) return;
    final item = s.items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final medicineId = item.medicine?.id;
    final relatedItems = medicineId == null ? [item] : s.items.where((i) => i.medicine?.id == medicineId).toList();

    final loadingStates = {...s.equivalentStates};
    for (final it in relatedItems) {
      loadingStates[it.id] = const EquivalentLoading();
    }
    state = s.copyWith(equivalentStates: loadingStates);

    final entries = await Future.wait(
      relatedItems.map((it) async {
        final prescriptionDetailId = it.id;

        final result = await _getEquivalents.call(prescriptionDetailId);
        return result.when(
          ok: (list) => MapEntry<int, EquivalentCheckState>(
            it.id,
            list.isEmpty ? const EquivalentNotFound() : EquivalentFound(list),
          ),
          error: (e) => MapEntry<int, EquivalentCheckState>(it.id, EquivalentFailed(e.message)),
        );
      }),
    );

    final current = state;
    if (current is! MasterIntakeMedicineSelection) return;
    final states = {...current.equivalentStates};
    for (final e in entries) {
      states[e.key] = e.value;
    }
    state = current.copyWith(equivalentStates: states);

    // Muadili bulunamayan her item için OTOMATİK başka kabin sorgusu tetikle.
    final notFoundIds = entries.where((e) => e.value is EquivalentNotFound).map((e) => e.key);
    for (final id in notFoundIds) {
      unawaited(_checkOtherStations(id));
    }
  }

  Future<void> _checkOtherStations(int itemId) async {
    final s = state;
    if (s is! MasterIntakeMedicineSelection) return;
    final item = s.items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionDetailId = item?.id;
    if (prescriptionDetailId == null) return;

    state = s.copyWith(otherStationStates: {...s.otherStationStates, itemId: const OtherStationLoading()});

    final result = await _getOtherStations.call(prescriptionDetailId);
    final current = state;
    if (current is! MasterIntakeMedicineSelection) return;

    final states = {...current.otherStationStates};
    result.when(
      ok: (list) => states[itemId] = list.isEmpty ? const OtherStationNotFound() : OtherStationFound(list),
      error: (e) => states[itemId] = OtherStationFailed(e.message),
    );
    state = current.copyWith(otherStationStates: states);
  }

  Future<void> redirectToStation(int itemId, OtherStationMedicine target) async {
    final s = state;
    if (s is! MasterIntakeMedicineSelection) return;
    final item = s.items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionDetailId = item?.id;
    final stationId = target.stationId;
    final materialId = target.materialId;
    if (prescriptionDetailId == null || stationId == null || materialId == null) return;

    state = s.copyWith(otherStationStates: {...s.otherStationStates, itemId: OtherStationRedirecting(target)});

    final result = await _redirectIntake.call(
      RedirectIntakeParams(prescriptionDetailId: prescriptionDetailId, stationId: stationId, materialId: materialId),
    );

    final current = state;
    if (current is! MasterIntakeMedicineSelection) return;
    final states = {...current.otherStationStates};

    await result.when(
      ok: (_) async {
        states[itemId] = OtherStationRedirected(target);
        final itemsWithTag = current.items.map((it) {
          return it.id == itemId ? it.copyWith(redirectedStation: target) : it;
        }).toList();
        final selectedIds = Set<int>.from(current.selectedItemIds)..remove(itemId);
        state = current.copyWith(items: itemsWithTag, otherStationStates: states, selectedItemIds: selectedIds);
        await _refreshMovement(itemId);
      },
      error: (e) async {
        states[itemId] = OtherStationRedirectFailed(target, e.message);
        state = current.copyWith(otherStationStates: states);
      },
    );
  }

  /// Yönlendirme sonrası backend'in gerçek durumunu (movementType=14) çeker,
  /// kilidi buna göre kalıcılaştırır.
  Future<void> _refreshMovement(int itemId) async {
    final s = state;
    if (s is! MasterIntakeMedicineSelection) return;
    final item = s.items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionId = item?.id;
    if (prescriptionId == null) return;

    final result = await _getPrescriptionDetail.call(prescriptionId);
    final current = state;
    if (current is! MasterIntakeMedicineSelection) return;

    result.when(
      ok: (detail) {
        if (detail?.lastMovement == null) return;
        final items = current.items.map((it) {
          return it.id == itemId ? it.copyWith(lastMovement: detail!.lastMovement) : it;
        }).toList();
        state = current.copyWith(items: items);
      },
      error: (_) {},
    );
  }

  /// RedirectedIntakeOrdersNotifier'daki seçim ekranından çağrılır — seçili
  /// order'ları toplu check eder, kuyruğu kurar, ilk çekmeceyi açar. Normal
  /// startIntake()'ten farkı: kaynak items zaten IntakeItem'a çevrilmiş geliyor,
  /// hasta/istasyon bağlamı ayrı bir "hospitalization" akışına bağlı değil.
  Future<void> startRedirectedIntake(List<RedirectedIntakeOrder> orders) async {
    _isRedirectedQueue = true;
    final targets = <IntakeTarget>[];

    for (final order in orders) {
      final result = await _checkRedirectedIntake.call(order.id);
      final ok = result.when(ok: (_) => true, error: (_) => false);

      if (!ok) {
        continue; // hatalı olan atlanır — UI tarafında ayrıca CheckFailed işaretlenmeli (RedirectedIntakeOrdersNotifier'da)
      }

      final target = _buildRedirectedTarget(order);
      if (target != null) targets.add(target);
    }

    if (targets.isEmpty) {
      state = MasterIntakeError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noValidTargets),
        previousState: state,
      );
      return;
    }

    final jobs = IntakeQueueBuilder.build(targets);
    if (jobs.isEmpty) {
      state = MasterIntakeError(
        failure: const CabinValidationFailure(reason: CabinValidationReason.noDrawerFound),
        previousState: state,
      );
      return;
    }

    // Redirected akışta "hasta" kavramı MasterIntakeExecuting'in beklediği
    // Hospitalization ile birebir örtüşmeyebilir (birden fazla hastanın
    // order'ı aynı kuyrukta olabilir) — ilk order'ın hastasını temsilci
    // olarak kullanıyoruz, yalnızca üst bilgi/breadcrumb amaçlı.
    final representativeHospitalization = orders.first.hospitalization;
    if (representativeHospitalization == null) return;

    state = MasterIntakeExecuting(
      hospitalization: representativeHospitalization,
      intakeType: IntakeType.ordered,
      jobs: jobs,
      currentIndex: 0,
    );
    await _openJobAt(jobIndex: 0, targetIndex: 0);
  }

  IntakeTarget? _buildRedirectedTarget(RedirectedIntakeOrder order) {
    final neededDose = order.dosePiece ?? 0;
    final stock = order.stocks.firstWhereOrNull((s) => (s.quantity ?? 0) >= neededDose) ?? order.stocks.firstOrNull;
    if (stock == null || stock.id == null || stock.assignment == null) return null;

    final item = order.toIntakeItem().copyWith(assignment: stock.assignment, stock: stock);

    return IntakeTarget(
      item: item,
      details: [IntakeDetail(stockId: stock.id!, dosePiece: neededDose)],
    );
  }

  /// Sekme değişiminde (Reçeteler'den ayrılırken) çağrılır — seçili hasta ve
  /// tüm item state'ini temizler, PatientSelection fazına döner. Böylece
  /// sağ panel, sol panelin (fresh reload sonrası) durumuyla senkron kalır.
  void resetToPatientSelection() {
    _hospitalization = null;
    _hospitalizationId = null;
    state = MasterIntakePatientSelection();
  }

  /// PatientSelection fazını atlayan çağıranlar için (acil hasta akışı gibi) —
  /// yalnızca needsWitness hesaplaması için gereken istasyonu set eder.
  /// init()'in aksine hospitalization/orchestrator sıfırlamaz, patient list'i
  /// tetiklemez — çünkü çağıran taraf zaten selectPatient()'a gidiyo
  void attachStation(Station station) {
    _currentStation = station;
  }

  /// Ekrandan tamamen çıkılırken (View.dispose) çağrılır — state'i
  /// Uninitialized'a döndürür ki bir sonraki mount'ta init() koşulsuz
  /// PatientSelection'a geçsin, eski MedicineSelection/Executing state'i
  /// sızmasın.
  void resetAll() {
    _hospitalization = null;
    _hospitalizationId = null;
    unawaited(_orchestrator.stop());
    Future.microtask(() => state = const MasterIntakeUninitialized());
  }
}
