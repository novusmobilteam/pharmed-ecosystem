import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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

  bool _cabinDesignsVerifiedThisSession = false;

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

  @override
  DashboardState build() {
    ref.onDispose(() => _timer?.cancel());

    return const DashboardLoading();
  }

  Future<void> initialize() async {
    final shouldForceRefresh = !_cabinDesignsVerifiedThisSession;

    await Future.wait([_fetchMenus(), _loadPrimary(forceRefresh: shouldForceRefresh)]);
    _cabinDesignsVerifiedThisSession = true;

    if (await _settings.isSetupComplete()) {
      ref.read(cabinConnectionProvider.notifier).connect();
    }

    unawaited(_loadSecondary());
  }

  Future<void> refresh({required bool forceRefresh}) =>
      Future.wait([_loadPrimary(forceRefresh: forceRefresh), _loadSecondary()]);

  /// Dashboard'un İLK RENDER'I için gereken veri: kurulum durumu, cihaz modu
  /// ve istasyondaki kabinlerin görselleştirme verisi. Diğer section'lar
  /// BURADA ÇEKİLMEZ.
  Future<void> _loadPrimary({required bool forceRefresh}) async {
    final setupDone = await _settings.isSetupComplete();
    final deviceMode = setupDone ? await _resolveDeviceMode() : null;

    final (station, stationCabins, cabinData, cabinFailed) = setupDone
        ? await _loadAllCabinVisualizers(forceRefresh: forceRefresh)
        : (null, <Cabin>[], <int, CabinVisualizerData>{}, false);

    // İstasyonun kendisi çekilemediyse (kabin listesi boş + failed=true) → hard error.
    if (setupDone && stationCabins.isEmpty && cabinFailed) {
      state = DashboardError(message: contextlessL10n().dashboard_allSectionsLoadError);
      return;
    }

    final current = state;
    state = current is DashboardLoaded
        ? current.copyWith(
            data: current.data.copyWith(
              station: station,
              stationCabins: stationCabins,
              cabinVisualizerDataByCabinId: cabinData,
              cabinDataFailed: cabinFailed,
            ),
            deviceMode: deviceMode,
          )
        : DashboardLoaded(
            data: DashboardData(
              station: station!,
              stationCabins: stationCabins,
              cabinVisualizerDataByCabinId: cabinData,
              cabinDataFailed: cabinFailed,
            ),
            deviceMode: deviceMode,
          );
  }

  /// İkincil section'lar: tedavi listesi, ilaç aktiviteleri, bekleyen
  /// reçeteler, oda/yatak/servis. _loadPrimary() bitmeden bunlara başlanmaz.
  Future<void> _loadSecondary() async {
    final mac = await DeviceInfo.getMacAddress();

    final results = await Future.wait([
      _getUpcomingTreatments.call(mac: mac),
      _getDrugActivities.call(mac: mac),
      _getUnapplied.call(),
      // TODO : Mobil kabin için kontrol et
      // ref.read(allRoomsProvider.future),
      // ref.read(allBedsProvider.future),
      // ref.read(allServicesProvider.future),
    ]);

    final treatmentsSection = _toSection<List<UpcomingTreatment>?>(results[0] as Result<List<UpcomingTreatment>>);
    final activitiesSection = _toSection<List<PrescriptionItemMovement>?>(
      results[1] as Result<List<PrescriptionItemMovement>?>,
    );
    final unappliedSection = _toSection<List<PrescriptionItem>?>(results[2] as Result<List<PrescriptionItem>>);

    final current = state;
    if (current is! DashboardLoaded) return; // primary hataya düştüyse burada duracak bir şey yok

    state = current.copyWith(
      data: current.data.copyWith(
        upcomingTreatments: treatmentsSection,
        drugActivities: activitiesSection,
        unappliedPrescriptions: unappliedSection,
      ),
      initialLoadComplete: true,
    );
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
  Future<(Station?, List<Cabin>, Map<int, CabinVisualizerData>, bool)> _loadAllCabinVisualizers({
    bool forceRefresh = true,
  }) async {
    final stationResult = await _getCurrentStation.call();
    final station = stationResult.when(ok: (s) => s, error: (_) => null);

    if (station == null || station.cabins.isEmpty) {
      return (null, <Cabin>[], <int, CabinVisualizerData>{}, true);
    }

    final map = <int, CabinVisualizerData>{};
    var anyFailed = false;

    // Tüm kabinleri aynı anda değil, 2'şerli gruplar halinde çek —
    // Dio connection pool'unu tek seferde doldurmamak için.
    final cabinsWithId = station.cabins.where((c) => c.id != null).toList();
    for (var i = 0; i < cabinsWithId.length; i += 2) {
      final batch = cabinsWithId.skip(i).take(2);
      final batchResults = await Future.wait(
        batch.map((cabin) async {
          final result = await _getCabinVisualizer.call(
            deviceMode: cabin.type,
            cabin: cabin,
            forceRefresh: forceRefresh,
          );
          return (cabin.id!, result);
        }),
      );
      for (final (cabinId, result) in batchResults) {
        result.when(ok: (data) => map[cabinId] = data, error: (_) => anyFailed = true);
      }
    }

    return (station, station.cabins, map, anyFailed);
  }

  /// Sadece kabin verisini yeniden çeker — diğer section'lara dokunmaz.
  /// "Tekrar Dene" butonu bunu çağırır.
  Future<void> retryCabinData() async {
    final current = state;
    if (current is! DashboardLoaded) return;

    final (station, stationCabins, cabinData, cabinFailed) = await _loadAllCabinVisualizers();

    state = current.copyWith(
      data: current.data.copyWith(
        station: station,
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

    final result = await _getCabinVisualizer.call(deviceMode: cabin.type, cabin: cabin, forceRefresh: true);

    final data = result.when(ok: (d) => d, error: (_) => null);
    if (data == null) return; // hata → mevcut (eski) veriyi koru, sessizce geç

    final updatedMap = {...current.data.cabinVisualizerDataByCabinId, cabinId: data};
    state = current.copyWith(data: current.data.copyWith(cabinVisualizerDataByCabinId: updatedMap));
  }

  DashboardSection<T> _toSection<T>(Result<T> result) {
    return switch (result) {
      Ok(:final value) => DashboardSection<T>(data: value, savedAt: DateTime.now()),
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

    debugPrint(route);

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
