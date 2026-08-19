// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi — fetch grubu + menü/rota.
// Sensör telemetrisi (cabinSensorProvider) ve kabin bağlantısı
// (cabinConnectionProvider) bağımsız yaşam döngüsüne sahiptir; bu notifier
// onları yönetmez.
// Repository'yi bilir, Dio/Hive'ı bilmez.
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../core/providers/providers.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardState> {
  Timer? _timer;

  GetUpcomingTreatmentsUseCase get _getUpcomingTreatments => ref.read(getUpcomingTreatmensUseCaseProvider);
  GetDrugActivitiesUseCase get _getDrugActivities => ref.read(getDrugActivitiesUseCaseProvider);
  GetDashboardUnappliedPrescriptionsUseCase get _getUnapplied => ref.read(getUnappliedPrescriptionsUseCaseProvider);
  GetCurrentStationUseCase get _getCurrentStation => ref.read(getCurrentStationUseCaseProvider);
  GetCabinVisualizerDataUseCase get _getCabinVisualizer => ref.read(getCabinVisualizerDataUseCaseProvider);
  AppSettingsCache get _settings => ref.read(appSettingsCacheProvider);

  /// Kabin seçimi gerektiren route'lar — bu listedeki bir hedefe navigateTo
  /// çağrıldığında doğrudan gidilmez, önce CabinSelectionView gösterilir.
  static const _cabinScopedRoutes = {
    'drug-assignment',
    'drug-refill',
    'drug-intake',
    'drug-unload',
    'drug-census',
    'drawer-malfunction',
    'drug-return',
    'drug-waste',
    'cabin-stock',
    'drug-destruction',
    'return-box-unload',
  };

  @override
  DashboardState build() {
    ref.onDispose(() => _timer?.cancel());

    return const DashboardLoading();
  }

  Future<void> initialize() async {
    await Future.wait([_fetchMenus(), _load()]);

    if (await _settings.isSetupComplete()) {
      ref.read(cabinConnectionProvider.notifier).connect();
    }
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final mac = await DeviceInfo.getMacAddress();
    final setupDone = await _settings.isSetupComplete();

    final deviceMode = setupDone ? await _resolveDeviceMode() : null;

    final results = await Future.wait([
      _getUpcomingTreatments.call(mac: mac),
      _getDrugActivities.call(mac: mac),
      _getUnapplied.call(),
      ref.read(allRoomsProvider.future),
      ref.read(allBedsProvider.future),
      ref.read(allServicesProvider.future),
    ]);

    final treatmentsResult = results[0] as Result<List<PrescriptionItem>>;
    final activitiesResult = results[1] as Result<List<PrescriptionItemMovement>?>;
    final unappliedResult = results[2] as Result<List<PrescriptionItem>>;

    final treatmentsSection = _toSection<List<PrescriptionItem>?>(treatmentsResult);
    final activitiesSection = _toSection<List<PrescriptionItemMovement>?>(activitiesResult);
    final unappliedSection = _toSection<List<PrescriptionItem>?>(unappliedResult);

    final (stationCabins, cabinData, cabinFailed) = setupDone
        ? await _loadAllCabinVisualizers()
        : (<Cabin>[], <int, CabinVisualizerData>{}, false);

    final allFailed = treatmentsSection.data == null && activitiesSection.data == null && (setupDone && cabinFailed);

    if (allFailed) {
      state = DashboardError(message: contextlessL10n().dashboard_allSectionsLoadError);
      return;
    }

    final data = DashboardData(
      upcomingTreatments: treatmentsSection,
      drugActivities: activitiesSection,
      unappliedPrescriptions: unappliedSection,
      stationCabins: stationCabins,
      cabinVisualizerDataByCabinId: cabinData,
      cabinDataFailed: cabinFailed,
    );

    final current = state;
    state = current is DashboardLoaded
        ? current.copyWith(data: data, deviceMode: deviceMode)
        : DashboardLoaded(data: data, deviceMode: deviceMode);
  }

  /// [cachedDeviceModeProvider] ile aynı parse mantığı — notifier'ın kendi
  /// state'inde bir kere tutulur ki navigateTo() SENKRON karar verebilsin
  /// (async provider'a her seferinde bağımlı kalmasın).
  Future<CabinType?> _resolveDeviceMode() async {
    final raw = await _settings.getDeviceMode();
    if (raw == null) return null;
    return CabinType.values.firstWhereOrNull((t) => t.name == raw || 'CabinType.${t.name}' == raw);
  }

  /// İstasyondaki TÜM kabinler için görselleştirme verisini PARALEL ve
  /// HER ZAMAN TAZE (forceRefresh: true) çeker — dashboard uygulamanın
  /// girişi olduğu için burada cache'e güvenilmez.
  ///
  /// Dönüş: (cabinId->data haritası, en az bir kabin başarısız oldu mu).
  /// İstasyon çekilemezse (kendisi de başarısız) → boş harita + failed=true.
  Future<(List<Cabin>, Map<int, CabinVisualizerData>, bool)> _loadAllCabinVisualizers() async {
    final stationResult = await _getCurrentStation.call();
    final station = stationResult.when(ok: (s) => s, error: (_) => null);

    if (station == null || station.cabins.isEmpty) {
      return (<Cabin>[], <int, CabinVisualizerData>{}, true);
    }

    final results = await Future.wait(
      station.cabins.where((c) => c.id != null).map((cabin) async {
        final result = await _getCabinVisualizer.call(deviceMode: cabin.type, cabinId: cabin.id, forceRefresh: true);
        return (cabin.id!, result);
      }),
    );

    final map = <int, CabinVisualizerData>{};
    var anyFailed = false;

    for (final (cabinId, result) in results) {
      result.when(ok: (data) => map[cabinId] = data, error: (_) => anyFailed = true);
    }

    return (station.cabins, map, anyFailed);
  }

  /// Sadece kabin verisini yeniden çeker — diğer section'lara dokunmaz.
  /// "Tekrar Dene" butonu bunu çağırır.
  Future<void> retryCabinData() async {
    final current = state;
    if (current is! DashboardLoaded) return;

    final (stationCabins, cabinData, cabinFailed) = await _loadAllCabinVisualizers();

    state = current.copyWith(
      data: current.data.copyWith(
        stationCabins: stationCabins,
        cabinVisualizerDataByCabinId: cabinData,
        cabinDataFailed: cabinFailed,
      ),
    );
  }

  /// Tek bir kabinin görselleştirme verisini yeniden çeker ve haritada
  /// günceller. Diğer kabinlere/section'lara dokunmaz — refreshCabinVisualizer()
  /// yerine geçer (artık "tek aktif kabin" kavramı olmadığı için hangi
  /// kabinin yenileneceği çağıran taraftan gelmeli).
  Future<void> refreshCabinVisualizer(int cabinId) async {
    final current = state;
    if (current is! DashboardLoaded) return;

    final cabin = current.data.stationCabins.firstWhereOrNull((c) => c.id == cabinId);
    if (cabin == null) return;

    final result = await _getCabinVisualizer.call(deviceMode: cabin.type, cabinId: cabinId, forceRefresh: true);

    final data = result.when(ok: (d) => d, error: (_) => null);
    if (data == null) return; // hata → mevcut (eski) veriyi koru, sessizce geç

    final updatedMap = {...current.data.cabinVisualizerDataByCabinId, cabinId: data};
    state = current.copyWith(data: current.data.copyWith(cabinVisualizerDataByCabinId: updatedMap));
  }

  DashboardSection<T> _toSection<T>(Result<T> result) {
    return switch (result) {
      Ok(:final value) => DashboardSection<T>(data: value),
      Error(:final error) => DashboardSection<T>(error: error.message),
    };
  }

  Future<void> _fetchMenus() async {
    final user = ref.read(authNotifierProvider.notifier).currentUser;
    final result = await ref.read(getFilteredMenusUseCaseProvider)(userId: user?.id);

    final menus = _unwrap(result);
    if (menus == null) return;

    final current = state;
    state = current is DashboardLoaded
        ? current.copyWith(menuTree: menus.tree, flattenedMenus: menus.flattened)
        : DashboardLoaded(menuTree: menus.tree, flattenedMenus: menus.flattened);
  }

  void navigateTo(dynamic destination) {
    final current = state;
    if (current is! DashboardLoaded) return;

    final route = switch (destination) {
      int id => current.flattenedMenus?.firstWhereOrNull((m) => m.id == id)?.slug ?? 'dashboard',
      String path => path,
      _ => 'dashboard',
    };

    if (route == 'dashboard') {
      state = current.copyWith(activeRoute: 'dashboard', clearActiveCabinId: true, clearPendingCabinRoute: true);
      return;
    }

    if (_cabinScopedRoutes.contains(route)) {
      // Mobil istasyonda çoklu-kabin/adresleme mimarisi hiç yok — seçim
      // ekranı atlanır, istasyonun tek (mobil) kabinine doğrudan gidilir.
      if (current.deviceMode == CabinType.mobile) {
        final cabinId = current.data.stationCabins.firstOrNull?.id;
        state = current.copyWith(activeRoute: route, activeCabinId: cabinId, clearPendingCabinRoute: true);
        return;
      }

      state = current.copyWith(pendingCabinRoute: route, clearActiveCabinId: true);
      return;
    }

    state = current.copyWith(activeRoute: route, clearPendingCabinRoute: true, clearActiveCabinId: true);
  }

  /// Kabin seçim ekranından bir kabine tıklanınca çağrılır — bekleyen route'a
  /// kabin ID'siyle birlikte geçilir.
  void selectCabinForPendingRoute(int cabinId) {
    final current = state;
    if (current is! DashboardLoaded) return;
    final target = current.pendingCabinRoute;
    if (target == null) return;

    state = current.copyWith(activeRoute: target, activeCabinId: cabinId, clearPendingCabinRoute: true);
  }

  /// Operasyon ekranı içinden "kabin değiştir" tetiklenince — aynı hedef
  /// route için seçim ekranına geri döner.
  void changeCabin() {
    final current = state;
    if (current is! DashboardLoaded) return;
    if (current.deviceMode == CabinType.mobile) return;
    if (!_cabinScopedRoutes.contains(current.activeRoute)) return;

    state = current.copyWith(pendingCabinRoute: current.activeRoute, clearActiveCabinId: true);
  }

  T? _unwrap<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Error() => null,
  };
}
