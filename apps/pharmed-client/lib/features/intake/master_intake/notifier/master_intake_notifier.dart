import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/mixins/cabin_drawer_queue_mixin.dart';
import '../../../../widgets/patient_selection/patient_selection.dart';
import '../../../auth/auth.dart';

class MasterIntakeNotifier extends ChangeNotifier with ApiRequestMixin, CabinDrawerQueueMixin<CabinOperationTarget> {
  final PatientSelectionNotifier _patientSelection;
  final GetIntakeItemsUseCase _getItems;
  final GetCurrentStationUseCase _getStation;
  final AuthNotifier _authNotifier;
  final CheckIntakeUseCase _checkIntake;
  final CheckEquivalentIntakeUseCase _checkEquivalentIntake;
  final GetEquivalentMedicinesUseCase _getEquivalents;
  final GetOtherStationMedicinesUseCase _getOtherStations;
  final RedirectIntakeUseCase _redirectIntake;
  final GetPrescriptionDetailUseCase _getPrescriptionDetail;

  MasterIntakeNotifier({
    required PatientSelectionNotifier patientSelection,
    required AuthNotifier authNotifier,
    required GetIntakeItemsUseCase getItems,
    required GetCurrentStationUseCase getStation,
    required CheckIntakeUseCase checkIntake,
    required CheckEquivalentIntakeUseCase checkEquivalentIntake,
    required GetOtherStationMedicinesUseCase getOtherStations,
    required GetEquivalentMedicinesUseCase getEquivalents,
    required RedirectIntakeUseCase redirectIntake,
    required GetPrescriptionDetailUseCase getPrescriptionDetail,
  }) : _patientSelection = patientSelection,
       _authNotifier = authNotifier,
       _getItems = getItems,
       _getStation = getStation,
       _checkIntake = checkIntake,
       _checkEquivalentIntake = checkEquivalentIntake,
       _getEquivalents = getEquivalents,
       _getOtherStations = getOtherStations,
       _redirectIntake = redirectIntake,
       _getPrescriptionDetail = getPrescriptionDetail {
    _patientSelection.addListener(_onPatientSelectionChanged);
    unawaited(_fetchStation());
  }

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _patientSelection.removeListener(_onPatientSelectionChanged);
    super.dispose();
  }

  final OperationKey fetchStationOp = OperationKey.custom('fetch-station');
  bool get isFetchingStation => isLoading(fetchStationOp);

  final OperationKey fetchItemsOp = OperationKey.custom('fetch-items');
  bool get isFetchingItems => isLoading(fetchItemsOp);

  final OperationKey checkIntakeOp = OperationKey.custom('check-intake');

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  /// init() ile kurulan, o an üzerinde çalışılan kabinin id'si.
  int _cabinId = 0;
  int get cabinId => _cabinId;

  Station? _currentStation;
  Station? get currentStation => _currentStation;

  Hospitalization? get hospitalization => _patientSelection.selected;

  List<IntakeItem> _items = const [];
  List<IntakeItem> get items => _items;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  Set<int> _selectedItemIds = {};
  Set<int> get selectedItemIds => _selectedItemIds;

  bool _isWitnessFlowOpen = false;
  bool get isWitnessFlowOpen => _isWitnessFlowOpen;

  List<WitnessStep> _witnessSteps = const [];
  List<WitnessStep> get witnessSteps => _witnessSteps;

  int _currentWitnessStepIndex = 0;
  int get currentWitnessStepIndex => _currentWitnessStepIndex;

  /// Acil hasta akışı her zaman orderless sayılır — normal hastada,
  /// PatientSelectionNotifier2'nin o an aktif orderStatus'una bakılır.
  IntakeType get intakeType {
    if (_patientSelection.hasUrgentPatient && _patientSelection.selected == _patientSelection.urgentPatient) {
      return IntakeType.urgent;
    }
    return _patientSelection.orderStatus.isOrderless ? IntakeType.orderless : IntakeType.ordered;
  }

  List<IntakeItem> get visibleItems {
    final q = _searchQuery?.trim().toLowerCase();
    if (q == null || q.isEmpty) return _items;
    return _items.where((it) => (it.medicine?.name?.toLowerCase() ?? '').contains(q)).toList();
  }

  Future<void> init(CabinVisualizerData data) async {
    _cabinId = data.cabinId;
    notifyListeners();

    unawaited(_fetchItems());
  }

  bool get canStart => selectedItemIds.isNotEmpty;

  /// Seçim fazındayız (mixin'in isExecuting'i false).
  bool get isSelecting => !isExecuting;

  /// Seçim fazındayız VE gösterilen bir hata yok.
  bool get isActivelySelecting => isSelecting && errorFailure == null;

  /// Seçili kalemlerden en az biri şahit gerektiriyorsa true. Footer'daki
  /// butonun "Şahit Girişi Yap" mı "Alıma Başla" mı göstereceğine bununla
  /// karar verilir.
  bool get needsWitnessForSelection => _items
      .where((it) => _selectedItemIds.contains(it.id))
      .any((it) => it.needsWitness(currentStation: _currentStation));

  WitnessStep? get currentWitnessStep =>
      (_currentWitnessStepIndex >= 0 && _currentWitnessStepIndex < _witnessSteps.length)
      ? _witnessSteps[_currentWitnessStepIndex]
      : null;

  int get completedWitnessStepCount => _witnessSteps.where((s) => s.isCompleted).length;
  bool get allWitnessStepsCompleted => _witnessSteps.isNotEmpty && _witnessSteps.every((s) => s.isCompleted);

  Map<int, IntakeCheckState> _checkStates = {};
  Map<int, IntakeCheckState> get checkStates => _checkStates;
  IntakeCheckState checkStateOf(int itemId) => _checkStates[itemId] ?? const CheckIdle();

  List<IntakeTarget> _pendingTargets = [];

  bool _hasPendingCheckFailures = false;
  bool get hasPendingCheckFailures => _hasPendingCheckFailures;

  Map<int, EquivalentCheckState> _equivalentStates = {};
  Map<int, EquivalentCheckState> get equivalentStates => _equivalentStates;
  EquivalentCheckState equivalentStateOf(int itemId) => _equivalentStates[itemId] ?? const EquivalentIdle();

  Map<int, OtherStationCheckState> _otherStationStates = {};
  Map<int, OtherStationCheckState> get otherStationStates => _otherStationStates;
  OtherStationCheckState otherStationStateOf(int itemId) => _otherStationStates[itemId] ?? const OtherStationIdle();

  /// Kontrol başarısız olan kalemler — dialog'da listelemek için.
  List<({IntakeItem item, String? message})> get failedCheckItems => _items
      .where((it) => _checkStates[it.id] is CheckFailed)
      .map((it) => (item: it, message: (_checkStates[it.id] as CheckFailed).message))
      .toList();

  Future<void> _fetchStation() async {
    await execute(
      fetchStationOp,
      operation: () => _getStation.call(),
      onData: (s) {
        _currentStation = s;
        _notify();
      },
    );
  }

  void _onPatientSelectionChanged() {
    final current = _patientSelection.selected;

    if (current == null) {
      _clearItems();
      return;
    }
    unawaited(_fetchItems());
  }

  Future<void> _fetchItems({bool refreshAssignments = false}) async {
    final hosp = hospitalization;
    if (hosp == null) return;

    await execute(
      fetchItemsOp,
      operation: () => _getItems.call(
        GetIntakeItemsParams(type: intakeType, hospitalizationId: hosp.id, refreshAssignments: refreshAssignments),
        cabinId: _cabinId,
      ),
      onData: (items) {
        _items = items;
        _selectedItemIds = _patientSelection.filterType == PatientFilterType.ordersDue
            ? items.map((it) => it.id).toSet()
            : {};
        _equivalentStates = {};
        _otherStationStates = {};
        _searchQuery = null;
        _notify();
      },
    );
  }

  void onSearchChanged(String? value) {
    if (!isActivelySelecting) return;
    _searchQuery = value;
    notifyListeners();
  }

  void toggleItem(int itemId) {
    if (isLoading(fetchItemsOp)) return;

    final next = Set<int>.from(_selectedItemIds);
    if (next.contains(itemId)) {
      next.remove(itemId);
      _selectedItemIds = next;
      _notify();
      return;
    }

    next.add(itemId);
    _items = _items.map((it) {
      if (it.id != itemId) return it;
      final dose = it.dosePiece;
      return (dose == null || dose == 0) ? it.copyWith(dosePiece: 1) : it;
    }).toList();
    _selectedItemIds = next;
    _notify();
  }

  void _clearItems() {
    _items = const [];
    _selectedItemIds = {};
    _searchQuery = null;
    _notify();
  }

  /// Bir kalemin alım dozunu günceller (limit validasyonu ile).
  ///
  /// [MedicalConsumable] için:
  /// - Miktar 1'in altına düşemez.
  /// - Kabindeki fiziksel stok miktarını aşamaz.
  ///
  /// [Drug] için:
  /// - Reçeteli (ordered) alımda canLower false ise miktar reçete dozundan
  ///   aşağı düşemez.
  /// - Üst limit; reçete dozu, fiziksel stok ve günlük maks. kullanımın en
  ///   küçüğü olarak hesaplanır.
  void updateDose(int itemId, double dose) {
    if (isLoading(fetchItemsOp)) return;

    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final medicine = item.medicine;
    double validatedAmount = dose;

    if (medicine is MedicalConsumable) {
      final stockLimit = item.assignment?.toDisplayQuantity(item.assignment?.totalQuantity ?? 0) ?? 0.0;
      if (validatedAmount < 1) validatedAmount = 1;
      if (validatedAmount > stockLimit) validatedAmount = stockLimit;
    } else if (medicine is Drug) {
      final bool isOrdered = intakeType == IntakeType.ordered;
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

    _items = _items.map((it) => it.id == itemId ? it.copyWith(dosePiece: validatedAmount) : it).toList();
    _notify();
  }

  /// Footer butonuna basıldığında çağrılır. Şahit gerekmeyen bir durumda
  /// yanlışlıkla açılmasın diye burada da guard var — buton zaten
  /// needsWitnessForSelection'a göre hangi aksiyonu tetikleyeceğine karar
  /// verecek, ama notifier kendi tutarlılığını da korumalı.
  void openWitnessFlow() {
    if (!needsWitnessForSelection) return;
    // Adımlar dialog AÇILIRKEN bir kez hesaplanıp donduruluyor (snapshot) —
    // kullanıcı dialog içindeyken alt paneldeki seçim değişse bile (normalde
    // kilitli olması beklenir) adımlar kaymaz.
    _witnessSteps = _buildWitnessSteps();
    _currentWitnessStepIndex = 0;
    _isWitnessFlowOpen = true;
    _notify();
  }

  void closeWitnessFlow() {
    if (!_isWitnessFlowOpen) return;
    _isWitnessFlowOpen = false;
    _witnessSteps = const [];
    _currentWitnessStepIndex = 0;
    _notify();
  }

  List<WitnessStep> _buildWitnessSteps() {
    final selected = _items.where(
      (it) => _selectedItemIds.contains(it.id) && it.needsWitness(currentStation: _currentStation),
    );

    final groupKeys = <Set<int>>[];
    final itemsByKey = <int, List<int>>{};
    final witnessesByKeyIndex = <int, List<User>>{};

    for (final item in selected) {
      final witnesses = item.activeWitnessContext.witnesses;
      final key = witnesses.map((w) => w.id).whereType<int>().toSet();

      final existingIndex = groupKeys.indexWhere((k) => const SetEquality<int>().equals(k, key));
      final index = existingIndex >= 0 ? existingIndex : groupKeys.length;
      if (existingIndex < 0) {
        groupKeys.add(key);
        witnessesByKeyIndex[index] = witnesses;
      }
      itemsByKey.putIfAbsent(index, () => []).add(item.id);
    }

    return List.generate(groupKeys.length, (i) {
      final itemIds = itemsByKey[i] ?? const [];
      // Grup içindeki tüm kalemler zaten AYNI şahide atanmışsa, adımı
      // tamamlanmış olarak geri kur (dialog kapat/aç arasında ilerleme kaybolmasın).
      final assignedWitnesses = itemIds
          .map((id) => _items.firstWhere((it) => it.id == id).activeWitnessContext.witness)
          .toSet();
      final confirmed = (assignedWitnesses.length == 1 && assignedWitnesses.first != null)
          ? assignedWitnesses.first
          : null;

      return WitnessStep(
        itemIds: itemIds,
        eligibleWitnesses: witnessesByKeyIndex[i] ?? const [],
        confirmedWitness: confirmed,
      );
    });
  }

  /// Aktif adımdaki TÜM kalemlere seçilen şahidi atar, adımı tamamlanmış
  /// işaretler ve sıradaki tamamlanmamış adıma geçer. Muadil seçili kalemlerde
  /// equivalentWitnessContext, değilse witnessContext güncellenir (bkz.
  /// IntakeItem.activeWitnessContext).
  void confirmWitnessForCurrentStep(User witness) {
    final step = currentWitnessStep;
    if (step == null) return;

    final updatedSteps = List<WitnessStep>.from(_witnessSteps);

    // Aktif adımı onayla + witness bu şahidin eligibleWitnesses'ında olduğu
    // HENÜZ TAMAMLANMAMIŞ diğer adımlara da otomatik yay — aynı kişi birden
    // fazla adımda şahitlik yapabiliyorsa tekrar giriş istemeye gerek yok.
    for (var i = 0; i < updatedSteps.length; i++) {
      final s = updatedSteps[i];
      if (s.isCompleted) continue;
      final isSameStep = i == _currentWitnessStepIndex;
      final canWitnessHere = s.eligibleWitnesses.any((w) => w.id == witness.id);
      if (isSameStep || canWitnessHere) {
        updatedSteps[i] = s.copyWith(confirmedWitness: witness);
      }
    }
    _witnessSteps = updatedSteps;

    final confirmedStepIndexes = <int>{
      for (var i = 0; i < updatedSteps.length; i++)
        if (updatedSteps[i].isCompleted) i,
    };

    _items = _items.map((it) {
      final stepIndex = _witnessSteps.indexWhere((s) => s.itemIds.contains(it.id));
      if (stepIndex < 0 || !confirmedStepIndexes.contains(stepIndex)) return it;
      final stepWitness = _witnessSteps[stepIndex].confirmedWitness;
      if (stepWitness == null) return it;
      // Sadece bu turda yeni onaylanan adımlara ait kalemleri güncelle —
      // zaten witness'ı olan kalemleri (activeWitnessContext.witness aynıysa)
      // tekrar yazmak zararsız, farklı bir witness ile üzerine yazmayı önlemek
      // için mevcut witness'ı koru.
      if (it.activeWitnessContext.witness != null && it.activeWitnessContext.witness!.id != stepWitness.id) {
        return it; // teorik olarak oluşmamalı ama güvenlik için dokunma
      }
      return it.isEquivalentIntake
          ? it.copyWith(equivalentWitnessContext: it.activeWitnessContext.copyWith(witness: stepWitness))
          : it.copyWith(witnessContext: it.activeWitnessContext.copyWith(witness: stepWitness));
    }).toList();

    final nextIncomplete = _witnessSteps.indexWhere((s) => !s.isCompleted);
    _currentWitnessStepIndex = nextIncomplete >= 0 ? nextIncomplete : _currentWitnessStepIndex;

    _notify();
  }

  /// Footer butonu — dialog içindeki "Alımı Başlat" ve dışarıdaki
  /// "Şahit Girişi Yap"/"Alıma Başla" AYNI metodu çağırır.
  Future<void> startIntake() async {
    if (!canStart || _isChecking) return;

    _isChecking = true;
    _checkStates = {};
    _notify();

    final selected = _items.where((it) => _selectedItemIds.contains(it.id)).toList();
    final normalItems = selected.where((it) => !it.isEquivalentIntake).toList();
    final equivalentItems = selected.where((it) => it.isEquivalentIntake).toList();

    final batchResult = normalItems.isEmpty
        ? null
        : await _checkIntake.callBatch(
            type: intakeType,
            userId: _authNotifier.currentUser?.id ?? 0,
            hospitalizationId: hospitalization?.id,
            items: normalItems,
            onItemStatusChanged: (itemId, status) {
              _checkStates = {..._checkStates, itemId: status};
              _notify();
            },
          );

    final equivalentTargets = <IntakeTarget>[];
    for (final item in equivalentItems) {
      _checkStates = {..._checkStates, item.id: const CheckLoading()};
      _notify();

      final materialId = item.selectedEquivalent?.materialId;
      if (materialId == null) {
        _checkStates = {..._checkStates, item.id: const CheckFailed(message: null)};
        _notify();
        continue;
      }

      final result = await _checkEquivalentIntake.call(
        EquivalentIntakeParams(prescriptionDetailId: item.id, materialId: materialId, censusQuantity: item.dosePiece),
      );

      result.when(
        ok: (_) {
          final target = _buildEquivalentTarget(item);
          if (target != null) {
            equivalentTargets.add(target);
            _checkStates = {..._checkStates, item.id: const CheckSuccess()};
          } else {
            _checkStates = {..._checkStates, item.id: const CheckFailed(message: null)};
          }
        },
        error: (e) => _checkStates = {..._checkStates, item.id: CheckFailed(message: e.message)},
      );
      _notify();
    }

    final allTargets = [...(batchResult?.targets ?? const <IntakeTarget>[]), ...equivalentTargets];
    final hasAnyFailure = _checkStates.values.any((s) => s is CheckFailed);

    _isChecking = false;

    if (allTargets.isEmpty) {
      _notify();
      return; // tüm kalemler başarısız — dialog göstermeye gerek yok, kartlarda zaten kırmızı görünüyor
    }

    if (hasAnyFailure) {
      _pendingTargets = allTargets;
      _hasPendingCheckFailures = true;
      _notify();
      return;
    }

    _notify();
    await _proceedToExecuting(allTargets);
  }

  /// Hata dialog'unda kullanıcı "Yine de devam et" dediğinde — check TEKRAR
  /// YAPILMAZ, zaten başarılı olan targetlerle kuyruk kurulur.
  Future<void> confirmProceedDespiteCheckFailures() async {
    if (!_hasPendingCheckFailures) return;
    final targets = _pendingTargets;
    _hasPendingCheckFailures = false;
    _pendingTargets = [];
    _notify();
    await _proceedToExecuting(targets);
  }

  void dismissCheckFailures() {
    _hasPendingCheckFailures = false;
    _pendingTargets = [];
    _notify();
  }

  /// Seçilen muadil için kuyruğa girecek IntakeTarget'ı üretir. Check zaten
  /// başarılı döndükten SONRA çağrılır — burada sadece fiziksel hedefi
  /// (hangi stok/çekmece) çözüyoruz, iş kuralı doğrulaması _checkEquivalentIntake
  /// içindeydi.
  IntakeTarget? _buildEquivalentTarget(IntakeItem item) {
    final equivalent = item.selectedEquivalent;
    if (equivalent == null) return null;

    final neededDose = item.dosePiece ?? equivalent.purchaseQuantity ?? 0;

    // Miktarı karşılayan İLK stok tercih edilir; hiçbiri tam karşılamıyorsa
    // (kısmi/eksik senaryosu) listedeki ilk stoğa düşülür — backend zaten
    // check aşamasında fiziksel yeterliliği doğruladığı için burada ayrıca
    // bir "yetersiz stok" reddi yapmıyoruz, sadece HANGİ stoğu hedefleyeceğimizi
    // seçiyoruz.
    final stock =
        equivalent.stocks.firstWhereOrNull((s) => (s.quantity ?? 0) >= neededDose) ?? equivalent.stocks.firstOrNull;
    if (stock == null || stock.id == null || stock.assignment == null) return null;

    // KRİTİK: assignment artık MUADİLİN fiziksel konumu — orijinal item.assignment
    // (orijinal ilacın konumu) burada BİLEREK ezilir, çünkü kuyruk/donanım
    // katmanı çekmeceyi bu assignment üzerinden açacak.
    final resolvedItem = item.copyWith(assignment: stock.assignment, stock: stock);

    return IntakeTarget(
      item: resolvedItem,
      details: [IntakeDetail(stockId: stock.id!, dosePiece: neededDose)],
    );
  }

  Future<void> checkEquivalent(int itemId) async {
    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final medicineId = item.medicine?.id;
    final relatedItems = medicineId == null ? [item] : _items.where((i) => i.medicine?.id == medicineId).toList();

    _equivalentStates = {..._equivalentStates, for (final it in relatedItems) it.id: const EquivalentLoading()};
    _notify();

    final entries = await Future.wait(
      relatedItems.map((it) async {
        final result = await _getEquivalents.call(it.id);
        return result.when(
          ok: (list) => MapEntry<int, EquivalentCheckState>(
            it.id,
            list.isEmpty ? const EquivalentNotFound() : EquivalentFound(list),
          ),
          error: (e) => MapEntry<int, EquivalentCheckState>(it.id, EquivalentFailed(e.message)),
        );
      }),
    );

    _equivalentStates = {..._equivalentStates, for (final e in entries) e.key: e.value};
    _notify();

    // Muadili bulunamayan her item için OTOMATİK başka kabin sorgusu tetikle.
    final notFoundIds = entries.where((e) => e.value is EquivalentNotFound).map((e) => e.key);
    for (final id in notFoundIds) {
      unawaited(_checkOtherStations(id));
    }
  }

  Future<void> _checkOtherStations(int itemId) async {
    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionDetailId = item?.id;
    if (prescriptionDetailId == null) return;

    _otherStationStates = {..._otherStationStates, itemId: const OtherStationLoading()};
    _notify();

    final result = await _getOtherStations.call(prescriptionDetailId);
    result.when(
      ok: (list) => _otherStationStates = {
        ..._otherStationStates,
        itemId: list.isEmpty ? const OtherStationNotFound() : OtherStationFound(list),
      },
      error: (e) => _otherStationStates = {..._otherStationStates, itemId: OtherStationFailed(e.message)},
    );
    _notify();
  }

  Future<void> redirectToStation(int itemId, OtherStationMedicine target) async {
    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionDetailId = item?.id;
    final stationId = target.stationId;
    final materialId = target.materialId;
    if (prescriptionDetailId == null || stationId == null || materialId == null) return;

    _otherStationStates = {..._otherStationStates, itemId: OtherStationRedirecting(target)};
    _notify();

    final result = await _redirectIntake.call(
      RedirectIntakeParams(prescriptionDetailId: prescriptionDetailId, stationId: stationId, materialId: materialId),
    );

    await result.when(
      ok: (_) async {
        _otherStationStates = {..._otherStationStates, itemId: OtherStationRedirected(target)};
        _items = _items.map((it) => it.id == itemId ? it.copyWith(redirectedStation: target) : it).toList();
        _selectedItemIds = Set<int>.from(_selectedItemIds)..remove(itemId);
        _notify();
        await _refreshMovement(itemId);
      },
      error: (e) async {
        _otherStationStates = {..._otherStationStates, itemId: OtherStationRedirectFailed(target, e.message)};
        _notify();
      },
    );
  }

  /// Yönlendirme sonrası backend'in gerçek durumunu (movementType=14) çeker,
  /// kilidi buna göre kalıcılaştırır.
  Future<void> _refreshMovement(int itemId) async {
    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    final prescriptionId = item?.id;
    if (prescriptionId == null) return;

    final result = await _getPrescriptionDetail.call(prescriptionId);
    result.when(
      ok: (detail) {
        if (detail?.lastMovement == null) return;
        _items = _items.map((it) => it.id == itemId ? it.copyWith(lastMovement: detail!.lastMovement) : it).toList();
        _notify();
      },
      error: (_) {},
    );
  }

  /// ZATEN seçiliyse tekrar tıklandığında seçimi KALDIRIR.
  void toggleEquivalentSelection(int itemId, EquivalentMedicine equivalent) {
    final found = _equivalentStates[itemId];
    if (found is! EquivalentFound) return;

    final isSameSelected = found.selected?.materialId == equivalent.materialId;
    _equivalentStates = {
      ..._equivalentStates,
      itemId: EquivalentFound(found.options, selected: isSameSelected ? null : equivalent),
    };

    final selectedIds = Set<int>.from(_selectedItemIds);
    _items = _items.map((it) {
      if (it.id != itemId) return it;
      if (isSameSelected) return it.copyWith(clearSelectedEquivalent: true);
      return it.copyWith(
        selectedEquivalent: equivalent,
        equivalentWitnessContext: equivalent.witnessContext,
        dosePiece: equivalent.purchaseQuantity ?? it.dosePiece,
      );
    }).toList();

    isSameSelected ? selectedIds.remove(itemId) : selectedIds.add(itemId);
    _selectedItemIds = selectedIds;
    _notify();
  }

  Future<void> _proceedToExecuting(List<IntakeTarget> targets) async {
    final jobs = IntakeQueueBuilder.build(targets);
    if (jobs.isEmpty) {
      // TODO(FAZ-3): CabinValidationFailure(noDrawerFound) göstermek için
      // henüz bir "genel hata" alanımız yok — executing katmanıyla birlikte ekleyeceğiz.
      return;
    }
    // TODO(FAZ-3): CabinDrawerQueueMixin entegrasyonu — orchestrator ile
    // kuyruk başlatma bir sonraki adımda.
  }

  @override
  Future<void> onQueueFinished() {
    // TODO: implement onQueueFinished
    throw UnimplementedError();
  }

  @override
  // TODO: implement orchestrator
  MasterDrawerOrchestrator get orchestrator => throw UnimplementedError();

  @override
  Future<Result<void>> submitTarget(CabinOperationTarget target) {
    // TODO: implement submitTarget
    throw UnimplementedError();
  }
}
