import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cache/witness_session_store.dart';
import '../../../../core/mixins/witness_mixin.dart';
import '../../../auth/auth.dart';
import '../../../dashboard/dashboard.dart';
import '../../../service_selection/notifier/active_service_notifier.dart';
import 'intake_plan_merger.dart';

final masterIntakeSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterIntakeSelectionNotifier>((ref) {
  ref.onDispose(() => debugPrint('MasterIntakeSelectionNotifier DISPOSED'));

  return MasterIntakeSelectionNotifier(
    authNotifier: ref.read(authNotifierProvider.notifier),
    activeServiceNotifier: ref.read(activeServiceNotifierProvider),
    getIntakeItemsUseCase: ref.read(getIntakeItemsUseCaseProvider),
    getEquivalentsUseCase: ref.read(getEquivalentIntakesUseCaseProvider),
    getOtherStationsUseCase: ref.read(getOtherStationMedicinesUseCaseProvider),
    redirectIntakeUseCase: ref.read(redirectIntakeUseCaseProvider),
    getPrescriptionDetailUseCase: ref.read(getPrescriptionDetailUseCaseProvider),
    getRedirectedOrdersUseCase: ref.read(getRedirectedIntakeOrdersUseCaseProvider),
    checkIntakeUseCase: ref.read(checkIntakeUseCaseProvider),
    checkEquivalentIntakeUseCase: ref.read(checkEquivalentIntakeUseCaseProvider),
    getStationAssignmentsUseCase: ref.read(getStationAssignmentsUseCaseProvider),
    witnessStore: ref.read(witnessSessionStoreProvider),
  );
});

class MasterIntakeSelectionNotifier extends ChangeNotifier with ApiRequestMixin, WitnessMixin<IntakeItem> {
  MasterIntakeSelectionNotifier({
    required AuthNotifier authNotifier,
    required ActiveServiceNotifier activeServiceNotifier,
    required GetIntakeItemsUseCase getIntakeItemsUseCase,
    required GetEquivalentIntakesUseCase getEquivalentsUseCase,
    required GetOtherStationMedicinesUseCase getOtherStationsUseCase,
    required RedirectIntakeUseCase redirectIntakeUseCase,
    required GetPrescriptionDetailUseCase getPrescriptionDetailUseCase,
    required GetRedirectedIntakeOrdersUseCase getRedirectedOrdersUseCase,
    required CheckIntakeUseCase checkIntakeUseCase,
    required CheckEquivalentIntakeUseCase checkEquivalentIntakeUseCase,
    required GetStationAssignmentsUseCase getStationAssignmentsUseCase,
    required WitnessSessionStore witnessStore,
  }) : _authNotifier = authNotifier,
       _activeServiceNotifier = activeServiceNotifier,
       _getIntakeItemsUseCase = getIntakeItemsUseCase,
       _getEquivalentsUseCase = getEquivalentsUseCase,
       _getOtherStationsUseCase = getOtherStationsUseCase,
       _redirectIntakeUseCase = redirectIntakeUseCase,
       _getPrescriptionDetailUseCase = getPrescriptionDetailUseCase,
       _getRedirectedOrdersUseCase = getRedirectedOrdersUseCase,
       _checkIntakeUseCase = checkIntakeUseCase,
       _checkEquivalentIntakeUseCase = checkEquivalentIntakeUseCase,
       _getStationAssignmentsUseCase = getStationAssignmentsUseCase,
       _witnessStore = witnessStore;

  // ── Bağımlılıklar ─────────────────────────────────────────────────────

  /// Aktif kullanıcıyı okumak için (yetki kontrolleri, şahit karşılaştırması).
  final AuthNotifier _authNotifier;

  /// Serbest ilaçlar aktif servise göre listelenir.
  final ActiveServiceNotifier _activeServiceNotifier;

  /// Hasta için alım kalemlerini (ilaç listesi) çeker.
  final GetIntakeItemsUseCase _getIntakeItemsUseCase;

  /// Stoksuz bir kalem için muadil ilaç seçeneklerini sorgular.
  final GetEquivalentIntakesUseCase _getEquivalentsUseCase;

  /// Muadili de bulunamayan bir kalem için başka istasyonlardaki stoğu sorgular.
  final GetOtherStationMedicinesUseCase _getOtherStationsUseCase;

  /// Bir kalemi başka bir istasyona yönlendirme isteği atar.
  final RedirectIntakeUseCase _redirectIntakeUseCase;

  /// Yönlendirme sonrası backend'in gerçek hareket durumunu (movementType)
  /// çekmek için — kalıcı kilit UI'ı buna göre şekillenir.
  final GetPrescriptionDetailUseCase _getPrescriptionDetailUseCase;

  /// Yönlendirilmiş orderları sorgular
  final GetRedirectedIntakeOrdersUseCase _getRedirectedOrdersUseCase;

  /// Seçili kalemleri toplu doğrular (stok + şahit uygunluğu) — hangi
  /// stoktan alınacağı bilgisini de döner.
  final CheckIntakeUseCase _checkIntakeUseCase;

  /// Muadil seçilmiş bir kalemi doğrular.
  final CheckEquivalentIntakeUseCase _checkEquivalentIntakeUseCase;

  /// Muadil için hedef assignment'ı çözmek amacıyla istasyonun TÜM
  /// assignment'larını çeker (muadilin döndürdüğü stok kaydı kendi
  /// assignment'ını taşımıyor, cabinDrawerDetail.id üzerinden ayrıca
  /// aranması gerekiyor).
  final GetStationAssignmentsUseCase _getStationAssignmentsUseCase;

  final WitnessSessionStore _witnessStore;

  /// Alım kalemlerini yeniden çekme işleminin durumunu (loading/success/failed)
  /// izlemek için — ApiRequestMixin'in genel operasyon anahtarı.
  final OperationKey fetchIntakeItemsOp = OperationKey.fetch();

  /// Yönlendirilen siparişleri çekme operasyonunun durumu — normal kalem
  /// çekiminden (`fetchIntakeItemsOp`) AYRI bir key, çünkü ikisi asla eşzamanlı
  /// çalışmaz ama ayrı izlenmesi loading göstergesini karıştırmaz.
  final OperationKey fetchRedirectedItemsOp = OperationKey.custom('fetch-redirected-items');

  /// Toplu check akışının genel kapısı — "Alıma Başla" butonunun loading/
  /// disabled durumu bundan okunur. Her kalemin KENDİ check durumu ayrıca
  /// checkItemOpFor(itemId) üzerinden izlenir (kartta per-item gösterim için).
  final OperationKey startIntakeOp = OperationKey.custom('start-intake');
  bool get isStartingIntake => isLoading(startIntakeOp);

  /// İşlem yapılan istasyon — `init()`'te set edilir, ordered/orderless
  /// varsayılanı ve yetki kontrollerini buradan türetiriz.
  Station? _currentStation;

  /// Ekranın o anki ordered/orderless GÖRÜNÜM modu. Station'ın varsayılan
  /// durumundan başlar, yetkili kullanıcı `toggleOrderlessStatus()` ile
  /// değiştirebilir.
  late OrderStatus _viewOrderStatus;

  /// Bu alımın backend'e gönderileceği tip (ordered/orderless/free/urgent).
  /// Dört yerden değişebilir: acil hasta oluşturma, "Serbest İlaç" toggle'ı,
  /// ordered/orderless toggle'ı.
  IntakeType _intakeType = IntakeType.ordered;

  /// Seçili hasta (yatış). Orderless/urgent/free akışlarda da taşınır.
  Hospitalization? _hospitalization;

  /// Seçili hasta için çekilen alım kalemleri listesi.
  List<IntakeItem> _intakeItems = [];

  /// Kullanıcının işaretlediği (toplu alıma dahil edeceği) kalem id'leri.
  final Set<int> _selectedItemIds = {};

  /// Hastaya "Serbest İlaç" (order/reçete bağlantısı olmayan tek seferlik
  /// alım) modunda mı bakılıyor. Açıkken `_intakeType = free`, kapanınca
  /// önceki ordered/orderless durumuna geri döner (bkz. `toggleFreeDrugStatus`).
  bool _freeDrugStatus = false;

  /// Stoksuz bir kalem için sorgulanan muadil seçenekleri. Key yoksa "hiç
  /// sorgulanmadı" (idle) anlamına gelir — bkz. `equivalentOptionsFor`.
  final Map<int, List<EquivalentMedicine>> _equivalentOptions = {};

  /// Muadili de bulunamamış bir kalem için sorgulanan diğer istasyon
  /// seçenekleri. Key yoksa "hiç sorgulanmadı" anlamına gelir.
  final Map<int, List<OtherStationMedicine>> _otherStationOptions = {};

  /// Başarıyla yönlendirilmiş kalemlerin, yönlendirildiği hedef istasyon
  /// bilgisi — UI'da "nereye yönlendirildi" göstermek için.
  final Map<int, OtherStationMedicine> _redirectedTo = {};

  // ── Getterlar ─────────────────────────────────────────────────────────

  /// Aktif oturum kullanıcısı.
  AppUser? get _currentUser => _authNotifier.currentUser;
  AppUser? get currentUser => _currentUser;

  /// Görünüm modu — dışarıya salt-okunur.
  OrderStatus get orderStatus => _viewOrderStatus;

  /// `MedSegmentedButton` gibi index tabanlı widget'lar için.
  int get orderStatusIndex => OrderStatus.values.indexOf(_viewOrderStatus);

  /// Aktif alım tipi — dışarıya salt-okunur.
  IntakeType get intakeType => _intakeType;

  /// Seçili hasta — dışarıya salt-okunur.
  Hospitalization? get hospitalization => _hospitalization;

  /// Alım kalemleri — dışarıya salt-okunur.
  List<IntakeItem> get intakeItems => _intakeItems;

  /// Seçili kalem id'leri — dışarıya değiştirilemez (kopya) olarak sunulur.
  Set<int> get selectedItemIds => Set.unmodifiable(_selectedItemIds);

  /// Seçili id'lere karşılık gelen kalem nesneleri — her çağrıda
  /// `_intakeItems` üzerinden türetilir, ayrı saklanmaz.
  List<IntakeItem> get selectedItems => _intakeItems.where((it) => _selectedItemIds.contains(it.id)).toList();

  /// Kullanıcının ordersız alım YAPMA yetkisi var mı — bu, `orderStatus`'u
  /// DEĞİL, ordered/orderless toggle butonunun GÖRÜNÜRLÜĞÜNÜ belirler.
  OrderStatus get userOrderStatus =>
      (_currentUser?.isNotOrdered ?? false) ? OrderStatus.ordered : OrderStatus.orderless;

  /// Ordered/Ordersız toggle butonu gösterilsin mi — istasyon ordered VE
  /// kullanıcı orderless yetkiliyse (istasyon zaten orderless'sa toggle'a
  /// gerek yok, sabit orderless kalır).
  bool get isStatusToggleVisible => (_currentStation?.drugStatus.isOrdered ?? false) && userOrderStatus.isOrderless;

  /// Kullanıcı ve istasyonun birlikte acil hasta oluşturma yetkisi var mı.
  bool get canCreateUrgentPatient =>
      (_currentUser?.canCreateEmergencyPatient ?? false) && (_currentStation?.canCreateEmergencyPatient ?? false);

  /// "Serbest İlaç" toggle'ının o anki durumu — dışarıya salt-okunur.
  bool get freeDrugStatus => _freeDrugStatus;

  /// Seçili kalemlerden şahit gerektirip henüz şahidi olmayan var mı.
  bool get hasMissingWitness => selectedItems.any((it) => needsWitness(it) && witnessContextOf(it).witness == null);

  /// "Alıma Başla" butonu aktif olsun mu — en az bir kalem seçili olmalı.
  bool get canStart => _selectedItemIds.isNotEmpty && !hasMissingWitness && !isOverdueSelectionLocked;

  /// Bir kalem şu an seçili mi.
  bool isSelected(int itemId) => _selectedItemIds.contains(itemId);

  /// Bir kalem için muadil sonuçları. `null` = hiç sorgulanmadı (henüz
  /// `checkEquivalent` çağrılmadı), boş liste = sorgulandı ama muadil yok.
  List<EquivalentMedicine>? equivalentOptionsFor(int itemId) => _equivalentOptions[itemId];

  /// Bir kalem için diğer istasyon sonuçları. `null` = hiç sorgulanmadı.
  List<OtherStationMedicine>? otherStationOptionsFor(int itemId) => _otherStationOptions[itemId];

  /// Bir kalem başarıyla yönlendirildiyse hedef istasyon bilgisi.
  OtherStationMedicine? redirectedStationFor(int itemId) => _redirectedTo[itemId];

  /// Bir kalemin muadil sorgu operasyonunun durumunu (`isLoading`/`isFailed`)
  /// izlemek için — `equivalentOptionsFor` ile birlikte kullanılır.
  OperationKey equivalentOpFor(int itemId) => OperationKey.custom('equivalent-$itemId');

  /// Bir kalemin diğer istasyon sorgu operasyonunun durumu için.
  OperationKey otherStationOpFor(int itemId) => OperationKey.custom('otherStation-$itemId');

  /// Bir kalemin yönlendirme isteğinin durumu için.
  OperationKey redirectOpFor(int itemId) => OperationKey.custom('redirect-$itemId');

  /// Bir kalemin (normal ya da muadil) check operasyonunun durumu —
  /// isLoading/isFailed/message ile birlikte kullanılır.
  OperationKey checkItemOpFor(int itemId) => OperationKey.custom('check-item-$itemId');

  /// Dialog'daki "Devam Et" butonu tarafından okunur — hatalı kalemler
  /// zaten hiç bu listeye girmemişti (bkz. aşağıdaki inşa mantığı).
  List<CabinOperationDrawerJob> _pendingJobs = const [];
  List<CabinOperationDrawerJob> get pendingJobs => _pendingJobs;

  /// Hatalı kalem varken "Devam Et" butonunun aktif olup olmayacağını
  /// belirler — başarılı check'ten geçmiş hiç kalem yoksa (hepsi başarısız)
  /// devam edilecek bir şey yok.
  bool get hasSuccessfulItemsToStart => _pendingJobs.isNotEmpty;

  /// WitnessMixin köprüsü — şahit kısıtı kontrolünde kullanılacak aktif kullanıcı id'si.
  @override
  int? get currentWitnessUserId => _authNotifier.currentUser?.id;

  @override
  WitnessSessionStore get witnessStore => _witnessStore;

  List<IntakePlan> _pendingPlans = const [];
  List<IntakePlan> get pendingPlans => _pendingPlans;

  /// Hasta panelinde seçili reçete/hasta filtresi. Alım kalemleri bu filtreyle
  /// çekilir (yalnızca ordered alımda — bkz. `_fetchPrescriptionItems`).
  PatientFilterType _patientFilter = PatientFilterType.ordersDue;
  PatientFilterType get patientFilter => _patientFilter;

  /// Kullanıcının uygulama saati geçmiş ilaçları alma yetkisi var mı.
  bool get canCollectOverdue => _currentUser?.canCollectOverdueMedication ?? false;

  /// Ordered alımda filtre "Order Saati Gelenler" dışındaysa ve kullanıcının
  /// yetkisi yoksa kalemler listelenir ama SEÇİLEMEZ.
  bool get isOverdueSelectionLocked =>
      _intakeType == IntakeType.ordered && _patientFilter != PatientFilterType.ordersDue && !canCollectOverdue;

  /// İstasyondaki kabin sırası — alım birden fazla kabine yayılabilir, kuyruk
  /// kabin kabin ilerler.
  List<int> _cabinOrder = const [];

  /// İstasyondaki tüm kabinlerin çekmece grupları — serum avadanlığı kilit adresleri için.
  List<DrawerGroup> _groups = const [];

  /// Zamanı geçmiş kalemler için alım öncesi girilen açıklamalar (itemId → metin).
  /// Kalemler yeniden çekildiğinde sıfırlanır.
  Map<int, String> _overdueDescriptions = const {};
  Map<int, String> get overdueDescriptions => _overdueDescriptions;

  /// Yetkili kullanıcı zamanı geçmiş kalemleri alıyorsa, alıma başlamadan
  /// önce açıklama dialogu gösterilmeli.
  bool get requiresOverdueDescription =>
      _intakeType == IntakeType.ordered && _patientFilter != PatientFilterType.ordersDue && canCollectOverdue;

  /// Ekran mount olduğunda bir kez çağrılır — istasyonu ve buna bağlı
  /// varsayılan ordered/orderless görünümünü set eder.
  void init(StationCabinsContext stationContext) {
    final station = stationContext.station;
    _currentStation = station;
    _viewOrderStatus = (station?.drugStatus.isOrderless ?? false) ? OrderStatus.orderless : OrderStatus.ordered;
    _cabinOrder = [
      for (final c in stationContext.cabins)
        if (c.id != null) c.id!,
    ];
    _groups = stationContext.allGroups;
  }

  /// Ordered ↔ orderless görünüm geçişi (yalnızca `isStatusToggleVisible`
  /// true iken UI'da gösterilir). Kalem listesini baştan çeker.
  void toggleOrderlessStatus() {
    _viewOrderStatus = _viewOrderStatus.isOrderless ? OrderStatus.ordered : OrderStatus.orderless;
    _intakeType = _viewOrderStatus.isOrderless ? IntakeType.orderless : IntakeType.ordered;
    notifyListeners();
    _getIntakeItems();
  }

  /// "Serbest İlaç" toggle'ı. Açılırken `_intakeType = free`'ye geçer;
  /// kapanırken kullanıcının o anki ordered/orderless görünümüne
  /// (`_viewOrderStatus`) göre geri döner — `_viewOrderStatus`'a hiç
  /// dokunulmaz, çünkü free açıkken zaten değişmemişti.
  void toggleFreeDrugStatus() {
    _freeDrugStatus = !_freeDrugStatus;
    _intakeType = _freeDrugStatus
        ? IntakeType.free
        : (_viewOrderStatus.isOrderless ? IntakeType.orderless : IntakeType.ordered);
    notifyListeners();
    _getIntakeItems();
  }

  /// Hasta panelindeki filtre değiştiğinde çağrılır. Seçili hasta varsa
  /// kalemler yeni filtreyle yeniden çekilir (seçimler `_applyFetchedItems`
  /// içinde sıfırlanır).
  void setPatientFilter(PatientFilterType filter) {
    if (_patientFilter == filter) return;
    _patientFilter = filter;
    notifyListeners();
    _getIntakeItems();
  }

  void setOverdueDescriptions(Map<int, String> descriptions) {
    _overdueDescriptions = Map.unmodifiable(descriptions);
  }

  /// Sol paneldeki hasta listesinden bir hasta seçildiğinde/seçim
  /// kaldırıldığında çağrılır. `null` gelmesi seçimin kaldırıldığı anlamına
  /// gelir — bu durumda hastaya bağlı TÜM state (kalemler, seçimler, muadil/
  /// yönlendirme sonuçları) temizlenir; aksi halde bir sonraki hastada eski
  /// verinin sızma riski olurdu (bkz. yukarıdaki not).
  void onPatientSelected(Hospitalization? hosp) {
    if (hosp == null) {
      _hospitalization = null;
      _intakeItems = [];
      _selectedItemIds.clear();
      _equivalentOptions.clear();
      _otherStationOptions.clear();
      _redirectedTo.clear();
      _overdueDescriptions = const {};
      notifyListeners();
      return;
    }
    _hospitalization = hosp;
    notifyListeners();
    _getIntakeItems();
  }

  /// Acil hasta oluşturulduğunda (PatientSelectionView'daki iki butondan biri
  /// üzerinden) çağrılır — [type] `IntakeType.free` veya `IntakeType.urgent`
  /// olur, hangi butona basıldığına bağlı.
  void onUrgentPatientCreated(Hospitalization hosp, IntakeType type) {
    _hospitalization = hosp;
    _intakeType = type;
    _getIntakeItems();
  }

  /// Acil hasta onay kartındaki "Sil" ile normal akışa dönüldüğünde çağrılır.
  /// `_getIntakeItems()`'a güvenmiyoruz çünkü `_hospitalization` burada
  /// `null`'a çekiliyor — o metod null hospitalization'da hiçbir şey
  /// yapmadan çıkar, bu yüzden TÜM ilgili state burada elle temizlenir.
  void onUrgentPatientDeleted() {
    _hospitalization = null;
    _intakeItems = [];
    _selectedItemIds.clear();
    _equivalentOptions.clear();
    _otherStationOptions.clear();
    _redirectedTo.clear();
    _intakeType = IntakeType.ordered;
    _freeDrugStatus = false;
    notifyListeners();
  }

  /// Kalem listesini, o anki sekmeye (`_intakeMode`) göre doğru kaynaktan çeker.
  Future<void> _getIntakeItems() async {
    if (_hospitalization == null) return;

    final isRedirected = _hospitalization!.isRedirected;

    if (isRedirected) {
      _fetchRedirectedItems();
    } else {
      _fetchPrescriptionItems();
    }
  }

  Future<void> _fetchPrescriptionItems() async {
    await execute(
      fetchIntakeItemsOp,
      operation: () => _getIntakeItemsUseCase.call(
        GetIntakeItemsParams(
          type: _intakeType,
          refreshAssignments: false,
          hospitalizationId: _hospitalization?.id,
          filter: _intakeType == IntakeType.ordered ? _patientFilter : PatientFilterType.ordersDue,
          serviceId: _activeServiceNotifier.activeService?.id,
        ),
      ),
      onData: (items) => _applyFetchedItems(items, autoSelectAll: _intakeType == IntakeType.ordered),
    );
  }

  /// Yönlendirilen siparişler her zaman kullanıcının kendisinin tek tek
  /// işaretlemesi gerekir — otomatik seçim YOK (eski RedirectedIntakeOrdersNotifier
  /// ile aynı davranış; bunlar başka istasyondan gelen, dikkatle onaylanması
  /// gereken kalemler).
  Future<void> _fetchRedirectedItems() async {
    await execute(
      fetchRedirectedItemsOp,
      operation: () => _getRedirectedOrdersUseCase.call(_hospitalization!.id!),
      onData: (orders) => _applyFetchedItems(orders.map((o) => o.toIntakeItem()).toList(), autoSelectAll: false),
    );
  }

  /// Her iki kaynaktan (reçeteli/yönlendirilen) gelen sonucu ortak şekilde
  /// işler — şahit yeniden uygulama, muadil/yönlendirme state temizliği ve
  /// otomatik seçim tek yerde toplanır.
  void _applyFetchedItems(List<IntakeItem> items, {required bool autoSelectAll}) {
    _intakeItems = reapplyConfirmedWitnesses(items);
    _equivalentOptions.clear();
    _otherStationOptions.clear();
    _redirectedTo.clear();

    _selectedItemIds.clear();
    if (autoSelectAll && !isOverdueSelectionLocked) {
      // Order saatine göre sırayla: stok önce erken orderı karşılar. Gözün
      // kalan stoğuna tam sığmayan order seçilmez (yetersiz stok — muadil).
      final candidates = _intakeItems
          .where((it) => !it.hasNoStock && !it.isRedirected && !it.inCaseOfNecessity)
          .toList()
        ..sort(_byOrderTime);
      for (final it in candidates) {
        if (_fitsRemainingStock(it, _allocationDose(it))) _selectedItemIds.add(it.id);
      }
    }

    notifyListeners();
  }

  /// Bir kalemi seçer/seçimden çıkarır. Stoksuz, yönlendirilmiş kalemler ve
  /// zamanı geçmiş kilidi aktifken kalemler seçilemez. Şahidi eksik kalem
  /// seçilebilir; alıma başlamak `canStart` (hasMissingWitness) ile engellenir.
  /// İlk seçimde dozu boş/0 olan kaleme 1 adet atanır.
  void selectItem(int itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
      notifyListeners();
      return;
    }

    if (isOverdueSelectionLocked) return;
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || item.isRedirected) return;
    if (item.hasNoStock && !item.isEquivalentIntake) return;

    final needsDefaultDose = item.dosePiece == null || item.dosePiece == 0;
    // Order bölünmez: gözün kalan stoğu orderı tam karşılamıyorsa normal alım
    // seçilemez — kart "yetersiz stok" gösterir, muadil akışına yönlendirir.
    if (!item.isEquivalentIntake && !_fitsRemainingStock(item, needsDefaultDose ? 1.0 : _allocationDose(item))) {
      notifyListeners();
      return;
    }

    if (needsDefaultDose) {
      _intakeItems = _intakeItems.map((it) => it.id == itemId ? it.copyWith(dosePiece: 1.0) : it).toList();
    }

    _selectedItemIds.add(itemId);
    notifyListeners();
  }

  /// WitnessMixin köprüsü — bir kalemin id'si.
  @override
  int idOf(IntakeItem item) => item.id;

  /// WitnessMixin köprüsü — bu kalem şahit gerektiriyor mu (ilaç flag'i +
  /// aktif istasyon kuralına göre).
  @override
  bool needsWitness(IntakeItem item) => item.needsWitness(currentStation: _currentStation);

  /// WitnessMixin köprüsü — kaleme şahit atar. Muadil seçilmişse muadilin
  /// şahit context'ine, değilse orijinal ilacın context'ine yazar.
  @override
  IntakeItem withWitness(IntakeItem item, User witness) => item.isEquivalentIntake
      ? item.copyWith(equivalentWitnessContext: item.activeWitnessContext.copyWith(witness: witness))
      : item.copyWith(witnessContext: item.activeWitnessContext.copyWith(witness: witness));

  /// WitnessMixin köprüsü — bir kalemin GERÇEKTEN geçerli şahit context'i
  /// (muadil seçiliyse muadilin, değilse orijinalin).
  @override
  WitnessContext witnessContextOf(IntakeItem item) => item.activeWitnessContext;

  /// Bir kaleme şahit girişi yapılır. Aktif kullanıcı asla şahit olamaz;
  /// girilen şahit oturum belleğine kaydedilir ve uygun olan diğer TÜM
  /// kalemlere (seçili olsun olmasın) otomatik yayılır — bkz. `WitnessMixin`.
  void addWitness(int itemId, User user) {
    final target = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (target == null) return;
    _intakeItems = applyWitness(target: target, user: user, pool: _intakeItems);
    notifyListeners();
  }

  /// Alım dozunun sınırları — tümü ADET cinsinden. `MedicalConsumable`'da
  /// yalnızca stok; `Drug`'da reçete dozu, düşürülebilirlik (`isCanLowerDose`),
  /// günlük maksimum ve stoğun birleşik sınırı. Reçete dozu zaten adettir;
  /// yalnızca günlük maksimum (ölçü birimli ilaçta ml) adede çevrilir.
  ({double min, double max}) _doseBounds(IntakeItem item) {
    final medicine = item.medicine;
    final stock = item.assignment?.totalQuantity ?? 0.0;

    if (medicine is MedicalConsumable) return (min: 1, max: math.min(stock, _remainingStockFor(item)));

    if (medicine is Drug) {
      final isOrdered = _intakeType == IntakeType.ordered;
      final orderedPieces = item.prescriptionDose ?? 0;

      final dailyMax = medicine.dailyMaxUsage ?? 0;
      final dailyMaxPieces = dailyMax > 0 ? medicine.dosePieces(dailyMax.toDouble()) : double.infinity;
      // Aynı gözden alınan diğer seçili kalemlerin payı düşülür.
      final safetyLimit = math.min(math.min(stock, _remainingStockFor(item)), dailyMaxPieces);

      // Doz düşürülemiyorsa reçetedeki miktar hem alt hem üst sınırdır.
      final minLimit = (isOrdered && !medicine.isCanLowerDose) ? orderedPieces : 1.0;
      final maxLimit = isOrdered ? math.min(orderedPieces, safetyLimit) : safetyLimit;

      return (min: minLimit, max: maxLimit);
    }

    return (min: 0, max: double.infinity);
  }

  /// View'ın `MedDoseStepper`'a geçeceği gerçek min/max — hardcoded bir
  /// sabit değil, bu hesaplamadan gelir.
  ({double min, double max}) doseBoundsFor(int itemId) {
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    return item == null ? (min: 0, max: 0) : _doseBounds(item);
  }

  /// Bir kalemin alım dozunu, hesaplanan sınırlar içinde günceller. Stoksuz
  /// ya da şahit bekleyen kalemlerde hiç çalışmaz (o kalemlerde stepper
  /// zaten UI'da gösterilmiyor, ama savunma amaçlı burada da engellenir).
  /// Sınırlar dejenere ise (`max < min` — assignment çözülememiş olabilir)
  /// sessizce hiçbir şey yapmaz.
  void updateDose(int itemId, double dose) {
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;
    if (isOverdueSelectionLocked) return;
    if (item.hasNoStock && !item.isEquivalentIntake) return;
    if (isStockInsufficient(itemId) && !item.isEquivalentIntake) return;
    if (needsWitness(item) && witnessContextOf(item).witness == null) return;

    final bounds = _doseBounds(item);
    if (bounds.max < bounds.min) return;

    var validated = dose;
    if (validated < bounds.min) validated = bounds.min;
    if (validated > bounds.max) validated = bounds.max;

    _intakeItems = _intakeItems.map((it) => it.id == itemId ? it.copyWith(dosePiece: validated) : it).toList();
    notifyListeners();
  }

  // ── Göz stoğu paylaşımı [SWREQ-CLI-MINTAKE-005] ─────────────────────────
  //
  // Check servisi kalemleri tek tek doğruluyor; aynı gözden alınan birden
  // fazla order'ın TOPLAMI stoğu aşabiliyor (gözde 3, order 2+2). Backend
  // kümülatif kontrole geçene kadar client sınırlar:
  //   - Order bölünmez: kalan stok orderı tam karşılamıyorsa o order normal
  //     alım için seçilemez → "yetersiz stok", muadil akışı.
  //   - Stok önce erken saatli order'a gider (otomatik seçim bu sırayla).
  //   - Seçili kalemlerin dozları toplamı gözün stoğunu aşamaz (doz sınırı).
  // Check sonrası ayrıca stok kaydı bazında doğrulanır (_rejectOverAllocated).

  /// Aynı göz paylaşım grubu: ilaç + atama. Çözülemeyen, muadil ve
  /// yönlendirilmiş alım gruba girmez (null).
  (int, int)? _stockGroupOf(IntakeItem item) {
    final medicineId = item.medicine?.id;
    final assignmentId = item.assignment?.id;
    if (medicineId == null || assignmentId == null) return null;
    if (item.isEquivalentIntake || item.isRedirected || item.isRedirectedIntake) return null;
    return (medicineId, assignmentId);
  }

  /// Kalemin stoktan ayıracağı miktar — seçilmişse girilen doz, değilse order dozu.
  double _allocationDose(IntakeItem item) {
    final dose = item.dosePiece ?? 0;
    return dose > 0 ? dose : (item.prescriptionDose ?? 0);
  }

  /// Gözde, AYNI gruptaki diğer seçili (normal alım) kalemler düşüldükten
  /// sonra kalan stok. Gruba girmeyen kalemde sınırsız.
  double _remainingStockFor(IntakeItem item) {
    final group = _stockGroupOf(item);
    if (group == null) return double.infinity;
    final stock = item.assignment?.totalQuantity ?? 0.0;
    final used = _intakeItems
        .where((o) => o.id != item.id && _selectedItemIds.contains(o.id) && _stockGroupOf(o) == group)
        .fold<double>(0, (sum, o) => sum + _allocationDose(o));
    return stock - used;
  }

  bool _fitsRemainingStock(IntakeItem item, double dose) => dose <= _remainingStockFor(item);

  int _byOrderTime(IntakeItem a, IntakeItem b) {
    final DateTime? ta = a.time;
    final DateTime? tb = b.time;
    if (ta == null || tb == null) return (ta == null ? 1 : 0) - (tb == null ? 1 : 0);
    return ta.compareTo(tb);
  }

  /// Kalem kendi başına stoklu ama gözün kalan stoğu orderı TAM
  /// karşılamıyor — kart "yetersiz stok" gösterir ve muadil sorgulatır.
  /// Muadil seçilmiş kalem bu durumda kalır (muadil bölümü açık kalsın).
  bool isStockInsufficient(int itemId) {
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || item.hasNoStock) return false;
    if (item.isEquivalentIntake) return true;
    if (_selectedItemIds.contains(itemId)) return false;
    if (_stockGroupOf(item) == null) return false;
    return !_fitsRemainingStock(item, _allocationDose(item));
  }

  /// [SWREQ-CLI-MINTAKE-005] Check sonrası savunma: planlar stok kaydı bazında
  /// toplanır; kaydın miktarını aşan kalem (order saati sırasıyla, sonraki
  /// olan) kuyruğa alınmaz ve hata ile işaretlenir.
  List<IntakePlan> _rejectOverAllocated(List<IntakePlan> plans) {
    final sorted = [...plans]..sort((a, b) => _byOrderTime(a.item, b.item));
    final usedByStock = <int, double>{};
    final accepted = <IntakePlan>[];

    for (final plan in sorted) {
      final stocks = plan.item.assignment?.stocks ?? const [];
      double? capacityOf(int stockId) => stocks.firstWhereOrNull((s) => s.id == stockId)?.quantity?.toDouble();

      final exceeds = plan.details.any((d) {
        final capacity = capacityOf(d.stockId);
        if (capacity == null) return false; // stok bilgisi yok — backend kararı geçerli
        return (usedByStock[d.stockId] ?? 0) + d.dosePiece > capacity;
      });

      if (exceeds) {
        setFailed(checkItemOpFor(plan.item.id), message: contextlessL10n().intake_error_totalExceedsStock);
        continue;
      }
      for (final d in plan.details) {
        usedByStock.update(d.stockId, (v) => v + d.dosePiece, ifAbsent: () => d.dosePiece);
      }
      accepted.add(plan);
    }

    // Kuyruk/plan sırası orijinal sırayla korunur.
    return [for (final p in plans) if (accepted.contains(p)) p];
  }

  /// Stoksuz bir kalem (ve aynı ilacın diğer tüm kalemleri) için muadil
  /// ilaç seçeneklerini sorgular. Hiç muadil bulunamayan kalemler için
  /// otomatik olarak diğer istasyon sorgusu (`_checkOtherStations`) tetiklenir.
  Future<void> checkEquivalent(int itemId) async {
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final medicineId = item.medicine?.id;
    final relatedItems = medicineId == null ? [item] : _intakeItems.where((i) => i.medicine?.id == medicineId).toList();

    await Future.wait(
      relatedItems.map(
        (it) => execute(
          equivalentOpFor(it.id),
          operation: () => _getEquivalentsUseCase.call(it.id),
          onData: (list) {
            // Kabinde yeterli stoğu olmayan muadil önerilmez — seçilse bile
            // alım başlatılamaz. Yeterli muadil yoksa diğer istasyonlara geçilir.
            final sufficient = list.where((eq) => _hasEnoughEquivalentStock(it, eq)).toList();
            if (sufficient.length != list.length) {
              MedLogger.info(
                unit: 'SW-UNIT-UI',
                swreq: 'SWREQ-CLI-MINTAKE-004',
                message: 'Insufficient-stock equivalents filtered',
                context: {'itemId': it.id, 'total': list.length, 'sufficient': sufficient.length},
              );
            }
            _equivalentOptions[it.id] = sufficient;
            if (sufficient.isEmpty) unawaited(_checkOtherStations(it.id));
          },
        ),
      ),
    );
  }

  /// [SWREQ-CLI-MINTAKE-004] Muadilin kabindeki toplam stoğu alınacak
  /// miktarı (muadilin satın alma miktarı; yoksa reçete dozu) karşılıyor mu.
  bool _hasEnoughEquivalentStock(IntakeItem item, EquivalentMedicine eq) {
    final needed = eq.purchaseQuantity ?? item.prescriptionDose ?? 0;
    final available = eq.stocks.fold<double>(0, (sum, s) => sum + (s.quantity ?? 0).toDouble());
    return available > 0 && available >= needed;
  }

  /// Muadili de bulunamayan bir kalem için başka istasyonlardaki stoğu sorgular.
  Future<void> _checkOtherStations(int itemId) async {
    await execute(
      otherStationOpFor(itemId),
      operation: () => _getOtherStationsUseCase.call(itemId),
      onData: (list) => _otherStationOptions[itemId] = list,
    );
  }

  /// Bir kalemi başka istasyona yönlendirir. Başarılı olursa kalem seçimden
  /// çıkarılır (artık bu istasyondan alınmayacak), kaleme `redirectedStation`
  /// işaretlenir ve backend'in gerçek hareket durumu ayrıca çekilir
  /// (`_refreshMovement`) — kart kalıcı kilide bu veri üzerinden geçer.
  Future<void> redirectToStation(int itemId, OtherStationMedicine target) async {
    final stationId = target.stationId;
    final materialId = target.materialId;
    if (stationId == null || materialId == null) return;

    var succeeded = false;

    await execute(
      redirectOpFor(itemId),
      operation: () => _redirectIntakeUseCase.call(
        RedirectIntakeParams(prescriptionDetailId: itemId, stationId: stationId, materialId: materialId),
      ),
      onData: (_) {
        succeeded = true;
        _redirectedTo[itemId] = target;
        _intakeItems = _intakeItems.map((it) => it.id == itemId ? it.copyWith(redirectedStation: target) : it).toList();
        _selectedItemIds.remove(itemId);
      },
    );

    if (succeeded) await _refreshMovement(itemId);
  }

  /// Yönlendirme sonrası backend'in gerçek durumunu (movementType) çeker —
  /// kartın kalıcı kilide (`item.isRedirected`) geçmesi buna bağlıdır.
  Future<void> _refreshMovement(int itemId) async {
    final result = await _getPrescriptionDetailUseCase.call(itemId);
    result.when(
      ok: (detail) {
        if (detail?.lastMovement == null) return;
        _intakeItems = _intakeItems
            .map((it) => it.id == itemId ? it.copyWith(lastMovement: detail!.lastMovement) : it)
            .toList();
        notifyListeners();
      },
      error: (_) {},
    );
  }

  /// Kullanıcının bir kalem için muadil seçmesi/seçimi geri alması. Muadil
  /// seçildiğinde: kalemin şahit context'i muadilin kendi context'ine döner
  /// (oturumdaki uygun bir şahit varsa otomatik atanır), dozu muadilin satın
  /// alma miktarına güncellenir, kalem otomatik seçilir.
  void toggleEquivalentSelection(int itemId, EquivalentMedicine equivalent) {
    if (isOverdueSelectionLocked) return;
    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null) return;

    final isSameSelected = item.selectedEquivalent?.materialId == equivalent.materialId;

    _intakeItems = _intakeItems.map((it) {
      if (it.id != itemId) return it;
      if (isSameSelected) return it.copyWith(clearSelectedEquivalent: true);

      final rawContext = equivalent.witnessContext;
      final resolvedWitness = resolveWitnessForList(rawContext.witnesses);

      return it.copyWith(
        selectedEquivalent: equivalent,
        equivalentWitnessContext: resolvedWitness != null ? rawContext.copyWith(witness: resolvedWitness) : rawContext,
        dosePiece: equivalent.purchaseQuantity ?? it.dosePiece,
      );
    }).toList();

    isSameSelected ? _selectedItemIds.remove(itemId) : _selectedItemIds.add(itemId);
    notifyListeners();
  }

  Future<void> startIntake({
    required void Function(List<CabinOperationDrawerJob> jobs, List<IntakePlan> plans) onQueueReady,
    void Function(String message)? onFailed,
  }) async {
    if (!canStart || isStartingIntake || isOverdueSelectionLocked) return;

    if (hasMissingWitness) {
      onFailed?.call(contextlessL10n().intake_error_witnessRequired);
      return;
    }

    if (requiresOverdueDescription &&
        selectedItems.any((it) => (_overdueDescriptions[it.id]?.trim().isEmpty ?? true))) {
      onFailed?.call(contextlessL10n().intake_overdue_descriptionRequiredError);
      return;
    }

    setLoading(startIntakeOp);
    _pendingJobs = const [];
    _pendingPlans = const [];

    final normalItems = selectedItems.where((it) => !it.isEquivalentIntake).toList();
    final equivalentItems = selectedItems.where((it) => it.isEquivalentIntake).toList();

    final plans = <IntakePlan>[
      ...await _checkEquivalentItems(equivalentItems),
      ..._rejectOverAllocated(await _checkNormalItems(normalItems)),
    ];

    // Aynı ilacın aynı gözden alınacak kalemleri (farklı order saatleri) tek
    // hedefte birleşir — kullanıcı toplam adedi tek seferde alır.
    // Plan → target. Göz çözülemeyen plan kuyruğa ALINMAZ — ya çekmece tam
    // açılırdı (FIFO güvenliği kalkar) ya da alınmayan stok kayda giderdi.
    final built = <({IntakePlanGroup group, CabinOperationTarget target})>[];
    for (final group in IntakePlanMerger.group(plans)) {
      final target = IntakeTargetMapper.build(group.merged.item, group.merged.details);
      if (target == null) {
        for (final m in group.members) {
          setFailed(checkItemOpFor(m.item.id), message: contextlessL10n().cabinCore_targetDrawerNotFound);
        }
        continue;
      }
      built.add((group: group, target: target));
    }

    // Yürütmeye kalem planları gider; yürütme aynı gruplamayı yeniden kurar.
    _pendingPlans = [for (final b in built) ...b.group.members];
    _pendingJobs = CabinOperationQueueBuilder.build(
      items: built,
      // Hedefin ataması — serumda avadanlık kimliği plandan tamamlanmış olabilir.
      assignmentOf: (b) => b.target.assignment,
      targetOf: (b, _) => b.target,
      cabinOrder: _cabinOrder,
      groups: _groups,
    ).jobs;

    // Hatalı kalemler kuyruğa hiç girmedi — "hatasızlarla devam et" senaryosu
    // için ayrıca filtrelemeye gerek yok.
    final anyFailed = selectedItems.any((it) => isFailed(checkItemOpFor(it.id)));
    if (anyFailed) {
      setFailed(startIntakeOp, message: contextlessL10n().intake_status_checkFailed);
      onFailed?.call(contextlessL10n().intake_status_checkFailed);
      return; // dialog açık kalır — kullanıcı "Devam Et" ya da "İptal" seçer
    }

    if (_pendingJobs.isEmpty) {
      setFailed(startIntakeOp, message: contextlessL10n().intake_error_noValidTargets);
      onFailed?.call(contextlessL10n().intake_error_noValidTargets);
      return;
    }

    setSuccess(startIntakeOp);
    onQueueReady(_pendingJobs, _pendingPlans);
  }

  /// Normal kalemler — toplu kontrol, başarılı olanların planı döner.
  Future<List<IntakePlan>> _checkNormalItems(List<IntakeItem> items) async {
    if (items.isEmpty) return const [];

    final result = await _checkIntakeUseCase.callBatch(
      type: _intakeType,
      userId: _currentUser?.id ?? 0,
      hospitalizationId: _hospitalization?.id,
      items: items,
      overdueDescriptions: _overdueDescriptions,
      onItemStatusChanged: (itemId, status) => switch (status) {
        CheckLoading() => setLoading(checkItemOpFor(itemId)),
        CheckSuccess() => setSuccess(checkItemOpFor(itemId)),
        CheckFailed(:final message) => setFailed(
          checkItemOpFor(itemId),
          message: message ?? contextlessL10n().intake_status_checkFailed,
        ),
        CheckIdle() => null,
      },
    );
    return result.plans;
  }

  /// Muadil seçilmiş kalemler — tek tek kontrol. Hedef atama istasyon
  /// atamalarından çözülür (tüm muadiller için TEK istek).
  Future<List<IntakePlan>> _checkEquivalentItems(List<IntakeItem> items) async {
    final plans = <IntakePlan>[];
    List<MedicineAssignment>? allAssignments;

    for (final item in items) {
      setLoading(checkItemOpFor(item.id));

      final result = await _checkEquivalentIntakeUseCase.call(
        EquivalentIntakeParams(
          prescriptionDetailId: item.id,
          materialId: item.selectedEquivalent!.materialId ?? 0,
          censusQuantity: item.dosePiece,
        ),
      );

      final error = result.when(ok: (_) => null, error: (e) => e.message);
      if (error != null) {
        setFailed(checkItemOpFor(item.id), message: error);
        continue;
      }

      allAssignments ??= (await _getStationAssignmentsUseCase.call()).when(
        ok: (list) => list,
        error: (_) => const <MedicineAssignment>[],
      );

      // Kontrol geçti ama hedef göz çözülemedi — sessizce atlamak yerine hata:
      // kart "başarılı" görünüp alım yapılmaması kullanıcıyı yanıltır.
      final plan = _buildEquivalentPlan(item, allAssignments ?? []);
      if (plan == null) {
        setFailed(checkItemOpFor(item.id), message: contextlessL10n().cabinCore_targetDrawerNotFound);
        continue;
      }

      setSuccess(checkItemOpFor(item.id));
      plans.add(plan);
    }

    return plans;
  }

  /// Muadil seçilmiş bir kalemin planı — muadilin stoğu ve o stoğun bulunduğu
  /// gözün ataması üzerinden kurulur.
  IntakePlan? _buildEquivalentPlan(IntakeItem item, List<MedicineAssignment> allAssignments) {
    final equivalent = item.selectedEquivalent;
    final resolvedMedicine = equivalent?.medicine;
    if (equivalent == null || resolvedMedicine == null) return null;

    final neededDose = item.dosePiece ?? equivalent.purchaseQuantity ?? 0;
    MedicineAssignment? assignmentOfCell(int? cellId) {
      if (cellId == null) return null;
      return allAssignments.firstWhereOrNull((a) => a.cabinDrawerDetail?.any((cell) => cell.id == cellId) ?? false);
    }

    // Tek stok yetiyorsa o; yetmiyorsa aynı atamadaki (aynı fiziksel yer)
    // stoklar FIFO sırasıyla toplanır — tek açılışta alınabilmeli.
    final single = equivalent.stocks.firstWhereOrNull((s) => (s.quantity ?? 0) >= neededDose && s.id != null);
    final stock = single ?? equivalent.stocks.firstWhereOrNull((s) => s.id != null);
    final stockId = stock?.id;
    if (stock == null || stockId == null) return null;

    final assignment = assignmentOfCell(stock.cabinDrawerDetail?.id);
    if (assignment == null) return null;

    final details = <IntakeDetail>[];
    if (single != null) {
      details.add(IntakeDetail(stockId: stockId, dosePiece: neededDose));
    } else {
      var remaining = neededDose;
      for (final s in equivalent.stocks) {
        if (remaining <= 0) break;
        final id = s.id;
        final qty = (s.quantity ?? 0).toDouble();
        if (id == null || qty <= 0 || assignmentOfCell(s.cabinDrawerDetail?.id)?.id != assignment.id) continue;
        final take = qty < remaining ? qty : remaining;
        details.add(IntakeDetail(stockId: id, dosePiece: take));
        remaining -= take;
      }
      // Muadil stoğu farklı yerlere dağılmış — önceki davranış: tüm doz ilk
      // stoktan planlanır, hangi partiden düşüleceğine backend karar verir.
      if (remaining > 0) {
        details
          ..clear()
          ..add(IntakeDetail(stockId: stockId, dosePiece: neededDose));
      }
    }

    // İstasyon atamaları paylaşılan çekmecelerde karışık stok döndürür —
    // yalnızca muadil malzemenin stokları (sayım ve üst sınır buna göre).
    final ownStocks = assignment.stocks?.where((s) => s.materialId == equivalent.materialId).toList();

    final resolvedItem = item.copyWith(
      assignment: assignment.copyWith(stocks: ownStocks),
      stock: stock,
      medicine: resolvedMedicine,
    );
    return (item: resolvedItem, details: details);
  }

  /// Kuyruk bittiğinde (execution notifier'ın onQueueFinished'ından) çağrılır.
  /// Kalemleri yeniden çeker — stoklar/check durumları artık değişmiş olabilir.
  /// Ayrı bir "başarılı" ekranı yok, aynı hastanın MedicineSelection fazına
  /// (varsa) temiz dönülür.
  Future<void> refreshAfterQueue() async {
    clearAllOperations(); // check sırasında biriken checkItemOpFor(...) key'leri temizlenir
    if (_hospitalization != null) {
      await _getIntakeItems();
    }
  }
}
