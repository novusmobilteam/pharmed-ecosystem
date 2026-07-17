// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi — fetch grubu + menü/rota.
// Sensör telemetrisi (cabinSensorProvider) ve kabin bağlantısı
// (cabinConnectionProvider) bağımsız yaşam döngüsüne sahiptir; bu notifier
// onları yönetmez.
// Repository'yi bilir, Dio/Hive'ı bilmez.
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/providers/providers.dart';
import '../../../settings/presentation/notifier/settings_notifier.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardState> {
  static const _refreshInterval = Duration(minutes: 60);

  Timer? _timer;

  GetUpcomingTreatmentsUseCase get _getUpcomingTreatments => ref.read(getUpcomingTreatmensUseCaseProvider);
  GetDrugActivitiesUseCase get _getDrugActivities => ref.read(getDrugActivitiesUseCaseProvider);
  GetDashboardUnappliedPrescriptionsUseCase get _getUnapplied => ref.read(getUnappliedPrescriptionsUseCaseProvider);
  GetCabinVisualizerDataUseCase get _getCabinVisualizer => ref.read(getCabinVisualizerDataUseCaseProvider);
  AppSettingsCache get _settings => ref.read(appSettingsCacheProvider);

  @override
  DashboardState build() {
    ref.onDispose(() => _timer?.cancel());

    if (kDebugMode) {
      ref.listen(settingsNotifierProvider, (prev, next) {
        if (prev?.debugCabin?.id != next.debugCabin?.id) {
          unawaited(_load());
        }
      });
    }

    return const DashboardLoading();
  }

  Future<void> initialize() async {
    await Future.wait([_fetchMenus(), _load()]);

    if (await _settings.isSetupComplete()) {
      ref.read(cabinConnectionProvider.notifier).connect();
    }

    _startPeriodicRefresh();
  }

  /// Manuel yenileme — pull-to-refresh veya panel içi retry.
  Future<void> refresh() => _load();

  // ------------------------------------------------------------------ fetch

  Future<void> _load() async {
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard yükleniyor');

    final mac = await DeviceInfo.getMacAddress();
    final setupDone = await _settings.isSetupComplete();

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
    final cabinVisualizer = setupDone ? await _loadCabinVisualizer() : null;

    // Hiçbir kaynakta gösterilecek veri yoksa global hata
    final allFailed =
        treatmentsSection.data == null && activitiesSection.data == null && (setupDone && cabinVisualizer == null);

    if (allFailed) {
      MedLogger.warn(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard: tüm kaynaklar başarısız');
      state = DashboardError(message: contextlessL10n().dashboard_allSectionsLoadError);
      return;
    }

    final data = DashboardData(
      upcomingTreatments: treatmentsSection,
      drugActivities: activitiesSection,
      unappliedPrescriptions: unappliedSection,
      cabinVisualizerData: cabinVisualizer,
    );

    final current = state;
    state = current is DashboardLoaded ? current.copyWith(data: data) : DashboardLoaded(data: data);

    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard yüklendi');
  }

  DashboardSection<T> _toSection<T>(Result<T> result) {
    return switch (result) {
      Ok(:final value) => DashboardSection<T>(data: value),
      Error(:final error) => DashboardSection<T>(error: error.message),
    };
  }

  Future<CabinVisualizerData?> _loadCabinVisualizer() async {
    final deviceMode = await ref.read(deviceModeProvider.future);
    final cabinId = await _settings.getCurrentCabinId();

    final result = await _getCabinVisualizer.call(deviceMode: deviceMode, cabinId: cabinId);
    return _unwrap(result);
  }

  /// Kabin işlemi sonrası yalnızca görselleştirmeyi tazeler.
  Future<void> refreshCabinVisualizer() async {
    if (!await _settings.isSetupComplete()) return;

    final cabin = await _loadCabinVisualizer();
    if (cabin == null) return; // hata → mevcut görseli koru

    final current = state;
    if (current is! DashboardLoaded) return;

    state = current.copyWith(data: current.data.copyWith(cabinVisualizerData: cabin), cabinFailed: false);
  }

  // ------------------------------------------------------------------- menü

  Future<void> _fetchMenus() async {
    final user = ref.read(authNotifierProvider.notifier).currentUser;
    final result = await ref.read(getFilteredMenusUseCaseProvider)(userId: user?.id);

    final menus = _unwrap(result);
    if (menus == null) {
      // Menü olmadan da dashboard gösterilebilir — state'e dokunma
      MedLogger.warn(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Menü yüklenemedi');
      return;
    }

    final current = state;
    state = current is DashboardLoaded
        ? current.copyWith(menuTree: menus.tree, flattenedMenus: menus.flattened)
        // _load henüz bitmedi — boş data ile Loaded'a geç, _load üzerine yazar
        : DashboardLoaded(menuTree: menus.tree, flattenedMenus: menus.flattened);
  }

  /// [destination] int ise menuId, String ise doğrudan rota.
  void navigateTo(dynamic destination) {
    final current = state;
    if (current is! DashboardLoaded) return;

    final route = switch (destination) {
      int id => current.flattenedMenus?.firstWhereOrNull((m) => m.id == id)?.slug ?? 'dashboard',
      String path => path,
      _ => 'dashboard',
    };

    state = current.copyWith(activeRoute: route);

    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Navigasyon: $route');
  }

  // --------------------------------------------------------------- yardımcı

  void _startPeriodicRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) {
      MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard periyodik yenileme');
      unawaited(_load());
    });
  }

  T? _unwrap<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Error() => null,
  };
}
