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

final masterIntakeSelectionNotifierProvider = ChangeNotifierProvider.autoDispose<MasterIntakeSelectionNotifier>((ref) {
  ref.onDispose(() => debugPrint('MasterIntakeSelectionNotifier DISPOSED'));

  return MasterIntakeSelectionNotifier(
    authNotifier: ref.read(authNotifierProvider.notifier),
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
  bool get canStart => _selectedItemIds.isNotEmpty && !hasMissingWitness;

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

  /// İstasyondaki kabin sırası — alım birden fazla kabine yayılabilir, kuyruk
  /// kabin kabin ilerler.
  List<int> _cabinOrder = const [];

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
          filter: PatientFilterType.ordersDue,
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

    _selectedItemIds
      ..clear()
      ..addAll(
        autoSelectAll
            ? _intakeItems.where((it) => !it.hasNoStock && !it.isRedirected && !it.inCaseOfNecessity).map((it) => it.id)
            : const <int>{},
      );

    notifyListeners();
  }

  /// Bir kalemi seçer/seçimden çıkarır. Stoksuz, yönlendirilmiş veya şahit
  /// gerekip henüz şahidi olmayan kalemler seçilemez. İlk seçimde dozu boş/0
  /// olan kaleme 1 adet atanır.
  void selectItem(int itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
      notifyListeners();
      return;
    }

    final item = _intakeItems.firstWhereOrNull((i) => i.id == itemId);
    if (item == null || item.isRedirected) return;
    if (item.hasNoStock && !item.isEquivalentIntake) return;
    if (needsWitness(item) && witnessContextOf(item).witness == null) return;

    if (item.dosePiece == null || item.dosePiece == 0) {
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
  /// günlük maksimum ve stoğun birleşik sınırı. Reçete ve günlük maksimum
  /// (ölçü birimli ilaçta ml) burada adede çevrilir; stok zaten adettir.
  ({double min, double max}) _doseBounds(IntakeItem item) {
    final medicine = item.medicine;
    final stock = item.assignment?.totalQuantity ?? 0.0;

    if (medicine is MedicalConsumable) return (min: 1, max: stock);

    if (medicine is Drug) {
      final isOrdered = _intakeType == IntakeType.ordered;
      final orderedPieces = medicine.dosePieces(item.prescriptionDose ?? 0);

      final dailyMax = medicine.dailyMaxUsage ?? 0;
      final dailyMaxPieces = dailyMax > 0 ? medicine.dosePieces(dailyMax.toDouble()) : double.infinity;
      final safetyLimit = math.min(stock, dailyMaxPieces);

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
    if (item.hasNoStock && !item.isEquivalentIntake) return;
    if (needsWitness(item) && witnessContextOf(item).witness == null) return;

    final bounds = _doseBounds(item);
    if (bounds.max < bounds.min) return;

    var validated = dose;
    if (validated < bounds.min) validated = bounds.min;
    if (validated > bounds.max) validated = bounds.max;

    _intakeItems = _intakeItems.map((it) => it.id == itemId ? it.copyWith(dosePiece: validated) : it).toList();
    notifyListeners();
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
            _equivalentOptions[it.id] = list;
            if (list.isEmpty) unawaited(_checkOtherStations(it.id));
          },
        ),
      ),
    );
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
    if (!canStart || isStartingIntake) return;

    if (hasMissingWitness) {
      onFailed?.call(contextlessL10n().intake_error_witnessRequired);
      return;
    }

    setLoading(startIntakeOp);
    _pendingJobs = const [];
    _pendingPlans = const [];

    final normalItems = selectedItems.where((it) => !it.isEquivalentIntake).toList();
    final equivalentItems = selectedItems.where((it) => it.isEquivalentIntake).toList();

    final plans = <IntakePlan>[
      ...await _checkEquivalentItems(equivalentItems),
      ...await _checkNormalItems(normalItems),
    ];

    // Plan → target. Göz çözülemeyen plan kuyruğa ALINMAZ — ya çekmece tam
    // açılırdı (FIFO güvenliği kalkar) ya da alınmayan stok kayda giderdi.
    final built = <({IntakePlan plan, CabinOperationTarget target})>[];
    for (final plan in plans) {
      final target = IntakeTargetMapper.build(plan.item, plan.details);
      if (target == null) {
        setFailed(checkItemOpFor(plan.item.id), message: contextlessL10n().cabinCore_targetDrawerNotFound);
        continue;
      }
      built.add((plan: plan, target: target));
    }

    _pendingPlans = [for (final b in built) b.plan];
    _pendingJobs = CabinOperationQueueBuilder.build(
      items: built,
      assignmentOf: (b) => b.plan.item.assignment!,
      targetOf: (b, _) => b.target,
      cabinOrder: _cabinOrder,
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
    final stock =
        equivalent.stocks.firstWhereOrNull((s) => (s.quantity ?? 0) >= neededDose) ?? equivalent.stocks.firstOrNull;
    final stockId = stock?.id;
    final cellId = stock?.cabinDrawerDetail?.id;
    if (stockId == null || cellId == null) return null;

    final assignment = allAssignments.firstWhereOrNull(
      (a) => a.cabinDrawerDetail?.any((cell) => cell.id == cellId) ?? false,
    );
    if (assignment == null) return null;

    // İstasyon atamaları paylaşılan çekmecelerde karışık stok döndürür —
    // yalnızca muadil malzemenin stokları (sayım ve üst sınır buna göre).
    final ownStocks = assignment.stocks?.where((s) => s.materialId == equivalent.materialId).toList();

    final resolvedItem = item.copyWith(
      assignment: assignment.copyWith(stocks: ownStocks),
      stock: stock,
      medicine: resolvedMedicine,
    );
    return (item: resolvedItem, details: [IntakeDetail(stockId: stockId, dosePiece: neededDose)]);
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
