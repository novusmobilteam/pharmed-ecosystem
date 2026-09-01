import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../core/mixins/api_request_mixin.dart';
import '../../../../core/providers/providers.dart';
import '../../../auth/auth.dart';

final dashboardNotifierProvider = ChangeNotifierProvider<DashboardNotifier>((ref) {
  return DashboardNotifier(
    getFilteredMenus: ref.read(getFilteredMenusUseCaseProvider),
    getUpcomingTreatments: ref.read(getUpcomingTreatmensUseCaseProvider),
    getDrugActivities: ref.read(getDrugActivitiesUseCaseProvider),
    getUnappliedPrescriptions: ref.read(getUnappliedPrescriptionsUseCaseProvider),
    getCurrentStation: ref.read(getCurrentStationUseCaseProvider),
    getCabinVisualizer: ref.read(getCabinVisualizerDataUseCaseProvider),
    settings: ref.read(appSettingsCacheProvider),
    authNotifier: ref.read(authNotifierProvider.notifier),
    cabinConnectionNotifier: ref.read(cabinConnectionProvider.notifier),
  );
});

class DashboardNotifier extends ChangeNotifier with ApiRequestMixin {
  DashboardNotifier({
    required GetFilteredMenusUseCase getFilteredMenus,
    required GetUpcomingTreatmentsUseCase getUpcomingTreatments,
    required GetDrugActivitiesUseCase getDrugActivities,
    required GetDashboardUnappliedPrescriptionsUseCase getUnappliedPrescriptions,
    required GetCurrentStationUseCase getCurrentStation,
    required GetCabinVisualizerDataUseCase getCabinVisualizer,
    required AppSettingsCache settings,
    required AuthNotifier authNotifier,
    required CabinConnectionNotifier cabinConnectionNotifier,
  }) : _getFilteredMenus = getFilteredMenus,
       _getUpcomingTreatments = getUpcomingTreatments,
       _getDrugActivities = getDrugActivities,
       _getUnapplied = getUnappliedPrescriptions,
       _getCurrentStation = getCurrentStation,
       _getCabinVisualizer = getCabinVisualizer,
       _settings = settings,
       _authNotifier = authNotifier,
       _cabinConnectionNotifier = cabinConnectionNotifier;

  final GetFilteredMenusUseCase _getFilteredMenus;
  final GetUpcomingTreatmentsUseCase _getUpcomingTreatments;
  final GetDrugActivitiesUseCase _getDrugActivities;
  final GetDashboardUnappliedPrescriptionsUseCase _getUnapplied;
  final GetCurrentStationUseCase _getCurrentStation;
  final GetCabinVisualizerDataUseCase _getCabinVisualizer;
  final AuthNotifier _authNotifier;
  final AppSettingsCache _settings;
  final CabinConnectionNotifier _cabinConnectionNotifier;

  String _activeRoute = 'dashboard';
  String get activeRoute => _activeRoute;

  int? _activeCabinId;
  int? get activeCabinId => _activeCabinId;

  String? _pendingCabinRoute;
  String? get pendingCabinRoute => _pendingCabinRoute;

  CabinType? _deviceMode;
  CabinType? get deviceMode => _deviceMode;

  FilteredMenus? _menus;
  FilteredMenus? get menus => _menus;

  List<MenuItem>? _menuTree;
  List<MenuItem>? get menuTree => _menuTree;

  List<MenuItem>? _flattenedMenus;
  List<MenuItem>? get flattenedMenus => _flattenedMenus;

  Station? _station;
  Station? get station => _station;

  List<Cabin> get cabins => _station?.cabins ?? [];

  Map<Cabin, CabinVisualizerData> _cabinVisualizerDataByCabin = {};
  Map<Cabin, CabinVisualizerData> get cabinVisualizerDataByCabin => _cabinVisualizerDataByCabin;

  Cabin? get activeCabin =>
      _cabinVisualizerDataByCabin.entries.firstWhereOrNull((e) => e.key.id == _activeCabinId)?.key;

  List<UpcomingTreatment>? _upcomingTreatments;
  List<UpcomingTreatment>? get upcomingTreatments => _upcomingTreatments;

  List<PrescriptionItemMovement>? _drugActivities;
  List<PrescriptionItemMovement>? get drugActivities => _drugActivities;

  List<PrescriptionItem>? _unappliedPrescriptions;
  List<PrescriptionItem>? get unappliedPrescriptions => _unappliedPrescriptions;

  AppUser? get currentUser => _authNotifier.currentUser;

  OperationKey fetchMenusKey = OperationKey.custom('fetch-menus');
  OperationKey fetchCurrentStationKey = OperationKey.custom('fetch-current-station');
  OperationKey fetchCabinVisualizerDataKey = OperationKey.custom('fetch-cabin-visualizer-data');

  bool get isMainDataLoading =>
      isLoading(fetchMenusKey) || isLoading(fetchCurrentStationKey) || isLoading(fetchCabinVisualizerDataKey);

  bool get isActiveRouteDashboard => _activeRoute == 'dashboard';

  CabinVisualizerData? primaryCabinData() {
    final targetCabin = _deviceMode == CabinType.mobile
        ? cabins.firstOrNull
        : cabins.firstWhereOrNull((c) => c.type == CabinType.master);

    if (targetCabin == null) return null;
    return cabinVisualizerDataByCabin[targetCabin];
  }

  /// Kabin seçimi gerektiren route'lar — bu listedeki bir hedefe navigateTo
  /// çağrıldığında doğrudan gidilmez, önce CabinSelectionView gösterilir.
  static const _cabinScopedRoutes = {
    'drug-assignment',
    'drug-refill',
    'drug-unload',
    'drug-census',
    'drawer-malfunction',
    'cabin-stock',
    'drug-destruction',
    'return-box-unload',
  };

  /// Dashboard'un İLK RENDER'I için gereken veri: kurulum durumu, cihaz
  /// modu, menüler ve istasyon+kabin görselleştirme verisi. Kabin verisi
  /// istasyon geldikten SONRA tetiklenir (bkz. _fetchCurrentStation).
  Future<void> initialize() async {
    final isSetupComplete = await _settings.isSetupComplete();
    _deviceMode = isSetupComplete ? await _resolveDeviceMode() : null;
    notifyListeners();

    if (isSetupComplete) {
      unawaited(_cabinConnectionNotifier.connect());
    }

    await Future.wait([_fetchMenus(), if (isSetupComplete) _fetchCurrentStation()]);

    // Tedavi/aktivite/reçete section'ları primary veriyi bloklamasın diye
    // arka planda, beklenmeden başlatılır.
    unawaited(_loadSecondaryData());
  }

  Future<void> refresh({bool forceRefresh = true}) async {
    final isSetupComplete = await _settings.isSetupComplete();
    _deviceMode = isSetupComplete ? await _resolveDeviceMode() : null;

    if (!forceRefresh) {
      await _loadSecondaryData();
      return;
    }

    await Future.wait([_fetchMenus(), if (isSetupComplete) _fetchCurrentStation(forceRefreshCabins: forceRefresh)]);

    await _loadSecondaryData();
  }

  Future<void> _fetchMenus() => execute(
    fetchMenusKey,
    operation: () => _getFilteredMenus.call(userId: currentUser?.id),
    onData: (data) {
      _menus = data;
      _menuTree = data.tree;
      _flattenedMenus = data.flattened;
      notifyListeners();
    },
  );

  /// İstasyonu çeker; başarılı olursa kabin görselleştirme verisini de
  /// hemen tetikler — station olmadan cabin visualizer istekleri anlamsız.
  Future<void> _fetchCurrentStation({bool forceRefreshCabins = true}) => execute(
    fetchCurrentStationKey,
    operation: () => _getCurrentStation.call(),
    onData: (data) {
      _station = data;
      notifyListeners();
      _loadAllCabinData(forceRefresh: forceRefreshCabins);
    },
  );

  /// İstasyondaki tüm kabinlerin görselleştirme verisini paralel çeker.
  /// Her kabin kendi OperationKey'i ile izlenir — biri hata verse diğerleri
  /// etkilenmez, geldikçe haritaya eklenir.
  void _loadAllCabinData({bool forceRefresh = true}) {
    final currentStation = _station;
    final mode = _deviceMode;
    if (currentStation == null || mode == null) return;

    for (final cabin in currentStation.cabins.where((c) => c.id != null)) {
      execute(
        fetchCabinVisualizerDataKey,
        operation: () => _getCabinVisualizer.call(deviceMode: mode, cabin: cabin, forceRefresh: forceRefresh),
        onData: (data) {
          _cabinVisualizerDataByCabin = {..._cabinVisualizerDataByCabin, cabin: data};
          notifyListeners();
        },
      );
    }
  }

  /// Tüm kabinlerin görselleştirme verisini yeniden çeker — "Tekrar Dene"
  /// butonu bunu çağırır (bkz. dashboard_content.dart).
  void refreshCabinData({bool forceRefresh = true}) => _loadAllCabinData(forceRefresh: forceRefresh);

  /// Tek bir kabinin görselleştirme verisini yeniden çeker — diğer
  /// kabinlere dokunmaz. Kabin ekranından "yenile" tetiklendiğinde kullanılır.
  Future<void> refreshCabinVisualizer(int cabinId) async {
    final mode = _deviceMode;
    final cabin = cabins.firstWhereOrNull((c) => c.id == cabinId);
    if (mode == null || cabin == null) return;

    await execute(
      OperationKey.custom('fetch-cabin-visualizer-$cabinId'),
      operation: () => _getCabinVisualizer.call(deviceMode: mode, cabin: cabin, forceRefresh: true),
      onData: (data) {
        _cabinVisualizerDataByCabin = {..._cabinVisualizerDataByCabin, cabin: data};
        notifyListeners();
      },
    );
  }

  Future<void> _loadSecondaryData() async {
    final mac = await DeviceInfo.getMacAddress();
    Future.wait([
      execute(
        OperationKey.custom('fetch-upcoming-treatments'),
        operation: () => _getUpcomingTreatments.call(mac: mac),
        onData: (data) {
          _upcomingTreatments = data;
          notifyListeners();
        },
      ),
      execute(
        OperationKey.custom('fetch-drug-activities'),
        operation: () => _getDrugActivities.call(mac: mac),
        onData: (data) {
          _drugActivities = data;
          notifyListeners();
        },
      ),
      execute(
        OperationKey.custom('fetch-unapplied-prescriptions'),
        operation: () => _getUnapplied.call(),
        onData: (data) {
          _unappliedPrescriptions = data;
          notifyListeners();
        },
      ),
    ]);
  }

  Future<CabinType?> _resolveDeviceMode() async {
    final raw = await _settings.getDeviceMode();
    if (raw == null) return null;
    return CabinType.values.firstWhereOrNull((t) => t.name == raw || 'CabinType.${t.name}' == raw);
  }

  void navigateTo(dynamic destination) {
    final route = switch (destination) {
      int id => _flattenedMenus?.firstWhereOrNull((m) => m.id == id)?.slug ?? 'dashboard',
      String path => path,
      _ => 'dashboard',
    };

    debugPrint(route);

    if (route == 'dashboard') {
      _activeRoute = 'dashboard';
      _activeCabinId = null;
      _pendingCabinRoute = null;
      notifyListeners();
      return;
    }

    if (_cabinScopedRoutes.contains(route)) {
      // Mobil istasyonda çoklu-kabin/adresleme mimarisi hiç yok — seçim
      // ekranı atlanır, istasyonun tek (mobil) kabinine doğrudan gidilir.
      if (_deviceMode == CabinType.mobile) {
        _activeRoute = route;
        _activeCabinId = _station?.cabins.firstOrNull?.id;
        _pendingCabinRoute = null;
        notifyListeners();
        return;
      }

      _pendingCabinRoute = route;
      _activeCabinId = null;
      notifyListeners();
      return;
    }

    // Kabin gerektirmeyen düz bir route — eski taslakta bu dal eksikti,
    // yani menüden normal bir sayfaya geçiş hiçbir şey yapmıyordu.
    _activeRoute = route;
    _pendingCabinRoute = null;
    _activeCabinId = null;
    notifyListeners();
  }

  /// Kabin seçim ekranından bir kabine tıklanınca çağrılır — bekleyen route'a
  /// kabin ID'siyle birlikte geçilir.
  void selectCabinForPendingRoute(int cabinId) {
    final target = _pendingCabinRoute;
    if (target == null) return;

    _activeRoute = target;
    _activeCabinId = cabinId;
    _pendingCabinRoute = null;
    notifyListeners();
  }

  /// Operasyon ekranı içinden "kabin değiştir" tetiklenince — aynı hedef
  /// route için seçim ekranına geri döner.
  void changeCabin() {
    if (_deviceMode == CabinType.mobile) return;
    if (!_cabinScopedRoutes.contains(_activeRoute)) return;

    _pendingCabinRoute = _activeRoute;
    _activeCabinId = null;
    notifyListeners();
  }
}
