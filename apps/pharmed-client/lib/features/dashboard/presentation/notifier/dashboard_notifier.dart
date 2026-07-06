// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi.
// UI'dan gelen aksiyonları karşılar, UiState'i günceller.
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
import '../../domain/model/dasboard_data.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardState> {
  static const _refreshInterval = Duration(minutes: 60);
  Timer? _timer;
  FilteredMenus? _pendingMenus;

  GetCriticalStocksUseCase get _getCriticalStocks => ref.read(getCriticalStocksUseCaseProvider);
  GetExpiringMaterialsUseCase get _getExpiringMaterials => ref.read(getExpiringMaterialsUseCaseProvider);
  GetUpcomingTreatmentsUseCase get _getUpcomingTreatments => ref.read(getUpcomingTreatmensUseCaseProvider);
  GetCabinVisualizerDataUseCase get _getCabinVisualizer => ref.read(getCabinVisualizerDataUseCaseProvider);
  AppSettingsCache get _settings => ref.read(appSettingsCacheProvider);

  @override
  DashboardState build() {
    ref.onDispose(() => _timer?.cancel());
    if (kDebugMode) {
      ref.listen(settingsNotifierProvider, (prev, next) {
        if (prev?.debugCabin?.id != next.debugCabin?.id) {
          _load(forceRefresh: true);
        }
      });
    }
    Future.microtask(() => _load(forceRefresh: true));
    return const DashboardLoading();
  }

  Future<void> initialize() async {
    Future.microtask(_fetchMenus);
    Future.microtask(_load);
    final setupDone = await appSettingsCache.isSetupComplete();
    if (setupDone) {
      ref.read(cabinConnectionProvider.notifier).connect();
    }

    _startPeriodicRefresh();
  }

  /// Manuel yenileme — pull-to-refresh veya retry butonu
  Future<void> refresh() => _load(forceRefresh: true);

  Future<void> _fetchMenus() async {
    final current = state;
    final hasMenu = switch (current) {
      DashboardLoaded(:final menuTree) => menuTree != null,
      DashboardPartial(:final menuTree) => menuTree != null,
      _ => false,
    };
    if (hasMenu) return;

    final user = ref.read(authNotifierProvider.notifier).currentUser;
    final menuResult = await ref.read(getFilteredMenusUseCaseProvider)(userId: user?.id);

    menuResult.when(
      ok: (FilteredMenus value) => _applyMenus(value),
      error: (error) {
        // Dashboard gösterilebilir, menü bölümü hata gösterir
        final current = state;
        state = switch (current) {
          DashboardLoaded() => current.copyWith(failedSections: [DashboardSection.menu]),
          DashboardPartial() => current.copyWith(failedSections: [...current.failedSections, DashboardSection.menu]),
          _ => current, // Loading → _resolveState zaten _pendingMenus'a bakar, menu null kalır
        };
      },
    );
  }

  void _applyMenus(FilteredMenus menus) {
    final current = state;

    state = switch (current) {
      DashboardLoaded() => current.copyWith(menuTree: menus.tree, flattenedMenus: menus.flattened),
      DashboardPartial() => current.copyWith(menuTree: menus.tree, flattenedMenus: menus.flattened),
      _ => current,
    };

    // Periyodik fetch henüz tamamlanmadı — pending'de sakla
    if (current is DashboardLoading) {
      _pendingMenus = menus;
    }
  }

  // [SWREQ-UI-DASH-003]
  Future<void> _load({bool forceRefresh = false}) async {
    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-DASH-003',
      message: 'Dashboard yükleniyor — forceRefresh: $forceRefresh',
    );

    if (state is! DashboardLoaded && state is! DashboardPartial) {
      state = const DashboardLoading();
    }

    final deviceMode = await ref.read(deviceModeProvider.future);
    final macAddress = await DeviceInfo.getMacAddress();

    final cabinId = await _settings.getCurrentCabinId();

    final results = await Future.wait([
      _getCabinVisualizer.call(deviceMode: deviceMode, cabinId: cabinId),
      _getCriticalStocks.call(true),
      _getExpiringMaterials.call(),
      _getUpcomingTreatments.call(mac: macAddress),

      /// Hasta atama işlemlerinde oda/yatak/servis bilgileri Hospitalization içerisinde
      /// yer almadığı için (sadece idleri geliyor) önden bu verileri çekip in-memory cachede
      /// tutuyor ve bu verileri buradan gösteriyoruz.
      ref.read(allRoomsProvider.future),
      ref.read(allBedsProvider.future),
      ref.read(allServicesProvider.future),
    ]);

    final cabinResult = results[0] as Result<CabinVisualizerData>;
    final criticalResult = results[1] as Result<List<CabinStock>>;
    final expiringResult = results[2] as Result<List<CabinStock>>;
    final treatmentsResult = results[3] as Result<List<PrescriptionItem>>;

    _resolveState(
      criticalResult: criticalResult,
      expiringResult: expiringResult,
      treatmentsResult: treatmentsResult,
      cabinResult: cabinResult,
    );
  }

  Future<void> refreshCabinVisualizer() async {
    final deviceMode = await ref.read(deviceModeProvider.future);
    final cabinId = await _settings.getCurrentCabinId();

    final cabinResult = await _getCabinVisualizer.call(deviceMode: deviceMode, cabinId: cabinId);

    final current = state;
    final cabinData = _extractData(cabinResult);
    if (cabinData == null) return; // hata varsa mevcut veriyi koru

    state = switch (current) {
      DashboardLoaded s => s.copyWith(data: s.data.copyWith(cabinVisualizerData: cabinData)),
      DashboardPartial s => s.copyWith(data: s.data.copyWith(cabinVisualizerData: cabinData)),
      _ => current,
    };
  }

  void _startPeriodicRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) {
      MedLogger.info(
        unit: 'SW-UNIT-UI',
        swreq: 'SWREQ-UI-DASH-003',
        message: 'Dashboard periyodik yenileme tetiklendi',
      );
      _load();
    });
  }

  void _resolveState({
    required Result<List<CabinStock>> criticalResult,
    required Result<List<CabinStock>> expiringResult,
    required Result<List<PrescriptionItem>> treatmentsResult,
    required Result<CabinVisualizerData> cabinResult,
  }) {
    // _resolveState başında mevcut menüyü al
    final existingMenus = switch (state) {
      DashboardLoaded(:final menuTree, :final flattenedMenus) => (menuTree, flattenedMenus),
      DashboardPartial(:final menuTree, :final flattenedMenus) => (menuTree, flattenedMenus),
      _ => (null, null),
    };

    final menuTree = _pendingMenus?.tree ?? existingMenus.$1;
    final flattenedMenus = _pendingMenus?.flattened ?? existingMenus.$2;

    // Her sonucu sınıfına göre ayır
    final criticalStocks = _extractData(criticalResult);
    final expiringMaterials = _extractData(expiringResult);
    final upcomingTreatments = _extractData(treatmentsResult);
    final cabinVisualizer = _extractData(cabinResult);

    final failedSections = <DashboardSection>[];

    if (criticalStocks == null) failedSections.add(DashboardSection.kpi);
    if (expiringMaterials == null) failedSections.add(DashboardSection.skt);
    if (upcomingTreatments == null) failedSections.add(DashboardSection.treatments);
    if (cabinVisualizer == null) failedSections.add(DashboardSection.cabin);

    // Tüm kaynaklar failure — hiç data yok
    if (criticalStocks == null && expiringMaterials == null && upcomingTreatments == null && cabinVisualizer == null) {
      MedLogger.warn(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard: tüm kaynaklar başarısız');
      // TODO(l10n): move to view layer or pass translated string as parameter
      state = const DashboardError(message: 'Veriler yüklenemedi. Lütfen tekrar deneyin.', isRetryable: true);
      return;
    }

    final data = DashboardData(
      criticalStocks: criticalStocks ?? [],
      expiringMaterials: expiringMaterials ?? [],
      // upcomingTreatments: upcomingTreatments ?? [],
      upcomingTreatments: [
        PrescriptionItem(
          id: 3,
          patientName: 'Kemal Demir',
          protocolNo: 'P-0091',
          time: DateTime.now().add(const Duration(minutes: 30)),
          medicine: Drug(id: 4, name: 'Amoksisilin 500mg'),
        ),
        PrescriptionItem(
          id: 4,
          patientName: 'Selma Ercan',
          protocolNo: 'P-0033',
          time: DateTime.now().add(const Duration(hours: 1)),
          medicine: Drug(id: 2, name: 'Metronidazol 500mg'),
        ),
        PrescriptionItem(
          id: 5,
          patientName: 'Hasan Korkmaz',
          protocolNo: 'P-0112',
          time: DateTime.now().add(const Duration(hours: 2)),
          medicine: Drug(id: 1, name: 'İnsülin Glarjin'),
        ),
      ],
      cabinVisualizerData: cabinVisualizer,
      kpi: KpiData(
        activePatients: 22,
        activePatientsProgress: 0.7,
        activePatientsChange: 5,
        completedOperations: 10,
        completedOperationsProgress: 0.5,
        completedOperationsChange: 5,
        pendingPrescriptions: 20,
        pendingPrescriptionsProgress: 0.7,
        criticalAlerts: 4,
        criticalAlertsProgress: 0.5,
        criticalAlertsChange: 2,
      ),
    );

    // Kısmi hata — bazı bölümler yüklendi
    if (failedSections.isNotEmpty) {
      MedLogger.warn(
        unit: 'SW-UNIT-UI',
        swreq: 'SWREQ-UI-DASH-003',
        message: 'Dashboard: kısmi yükleme — başarısız: $failedSections',
      );
      state = DashboardPartial(
        data: data,
        failedSections: failedSections,
        menuTree: menuTree,
        flattenedMenus: flattenedMenus,
      );
      _pendingMenus = null;
      return;
    }

    // Tam başarı
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard başarıyla yüklendi');
    state = DashboardLoaded(data).copyWith(menuTree: menuTree, flattenedMenus: flattenedMenus);
  }

  /// Result.ok → data döner, Result.error → null
  T? _extractData<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Error() => null,
  };

  void navigateTo(dynamic destination) {
    final current = state;
    String targetRoute = 'dashboard';

    // 1. Gelen değer int ise (menuId), flattenedMenus içinden routePath'i bul
    if (destination is int) {
      final menus = _getFlattenMenus(current);
      final targetMenu = menus?.firstWhereOrNull((m) => m.id == destination);
      targetRoute = targetMenu?.slug ?? 'dashboard';
    }
    // 2. Gelen değer String ise (doğrudan path), onu kullan
    else if (destination is String) {
      targetRoute = destination;
    }

    // 3. Mevcut state tipine göre copyWith ile rotayı güncelle
    state = switch (current) {
      DashboardLoaded s => s.copyWith(activeRoute: targetRoute),
      DashboardPartial s => s.copyWith(activeRoute: targetRoute),
      _ => current, // Loading veya Error durumunda rota değişmez
    };

    MedLogger.info(unit: 'SW-UNIT-UI', message: 'Navigasyon tetiklendi: Target -> $targetRoute', swreq: '');
  }

  // Yardımcı metod: Farklı state tiplerinden listeyi güvenli al
  List<MenuItem>? _getFlattenMenus(DashboardState s) => switch (s) {
    DashboardLoaded(:final flattenedMenus) => flattenedMenus,
    DashboardPartial(:final flattenedMenus) => flattenedMenus,
    _ => null,
  };
}
