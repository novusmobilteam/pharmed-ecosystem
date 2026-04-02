// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi.
// UI'dan gelen aksiyonları karşılar, UiState'i günceller.
// Repository'yi bilir, Dio/Hive'ı bilmez.
// Sınıf: Class B

import 'dart:async';
import 'package:collection/collection.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_client/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:pharmed_client/features/dashboard/domain/usecase/cabin_visualizer_usecase.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../domain/model/dasboard_data.dart';
import '../state/dashboard_ui_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardUiState>(DashboardNotifier.new);

class DashboardNotifier extends Notifier<DashboardUiState> {
  // Veriler 7 dakikada bir güncellenir.
  static const _refreshInterval = Duration(minutes: 7);
  Timer? _timer;
  FilteredMenus? _pendingMenus;

  GetCriticalStocksUseCase get _getCriticalStocks => ref.read(getCriticalStocksUseCaseProvider);
  GetExpiringMaterialsUseCase get _getExpiringMaterials => ref.read(getExpiringMaterialsUseCaseProvider);
  GetUpcomingTreatmensUseCase get _getUpcomingTreatments => ref.read(getUpcomingTreatmensUseCaseProvider);
  GetCabinVisualizerDataUseCase get _getCabinVisualizer => ref.read(getCabinVisualizerDataUseCaseProvider);

  @override
  DashboardUiState build() {
    ref.onDispose(() => _timer?.cancel());

    Future.microtask(_load);
    Future.microtask(_fetchMenus);
    _startPeriodicRefresh();

    return const DashboardLoading();
  }

  /// Manuel yenileme — pull-to-refresh veya retry butonu
  Future<void> refresh() => _load(forceRefresh: true);

  // ── Yükleme ──────────────────────────────────────────────────

  Future<void> _fetchMenus() async {
    final current = state;
    final hasMenu = switch (current) {
      DashboardLoaded(:final menuTree) => menuTree != null,
      DashboardStale(:final menuTree) => menuTree != null,
      DashboardPartial(:final menuTree) => menuTree != null,
      _ => false,
    };
    if (hasMenu) return;

    final user = ref.read(authNotifierProvider.notifier).currentUser;
    final menuResult = await ref.read(getFilteredMenusUseCaseProvider)(userId: user?.id);

    menuResult.when(
      success: (menus) => _applyMenus(menus),
      stale: (menus, savedAt) => _applyMenus(menus), // [HAZ-007]
      failure: (_) {
        // Dashboard gösterilebilir, menü bölümü hata gösterir
        final current = state;
        state = switch (current) {
          DashboardLoaded() => current.copyWith(failedSections: [DashboardSection.menu]),
          DashboardStale() => current.copyWith(failedSections: [DashboardSection.menu]),
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
      DashboardStale() => current.copyWith(menuTree: menus.tree, flattenedMenus: menus.flattened),
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

    if (state is! DashboardLoaded && state is! DashboardStale && state is! DashboardPartial) {
      state = const DashboardLoading();
    }

    final results = await Future.wait([
      _getCriticalStocks.call(true, forceRefresh: forceRefresh),
      _getExpiringMaterials.call(forceRefresh: forceRefresh),
      _getUpcomingTreatments.call(forceRefresh: forceRefresh),
      _getCabinVisualizer.call(),
    ]);

    final criticalResult = results[0] as RepoResult<List<CabinStock>>;
    final expiringResult = results[1] as RepoResult<List<CabinStock>>;
    final treatmentsResult = results[2] as RepoResult<List<PrescriptionItem>>;
    final cabinResult = results[3] as RepoResult<CabinVisualizerData>;

    _resolveState(
      criticalResult: criticalResult,
      expiringResult: expiringResult,
      treatmentsResult: treatmentsResult,
      cabinResult: cabinResult,
    );
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
    required RepoResult<List<CabinStock>> criticalResult,
    required RepoResult<List<CabinStock>> expiringResult,
    required RepoResult<List<PrescriptionItem>> treatmentsResult,
    required RepoResult<CabinVisualizerData> cabinResult,
  }) {
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
      state = const DashboardError(message: 'Veriler yüklenemedi. Lütfen tekrar deneyin.', isRetryable: true);
      return;
    }

    final data = DashboardData(
      criticalStocks: criticalStocks ?? [],
      expiringMaterials: expiringMaterials ?? [],
      upcomingTreatments: upcomingTreatments ?? [],
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

    // En az bir kaynak Stale — HAZ-007
    final staleEntry = _firstStaleEntry([criticalResult, expiringResult, treatmentsResult]);

    if (staleEntry != null) {
      MedLogger.warn(
        unit: 'SW-UNIT-UI',
        swreq: 'SWREQ-UI-DASH-007',
        message: 'Dashboard: eski cache verisi gösteriliyor — savedAt: ${staleEntry.savedAt}',
      );
      // HAZ-009: kritik stok verisi stale ise aksiyon kısıtlanır
      final canProceed = criticalResult is! RepoStale;
      state = DashboardStale(
        data: data,
        staleSince: staleEntry.savedAt,
        canProceed: canProceed,
        menuTree: _pendingMenus?.tree,
        flattenedMenus: _pendingMenus?.flattened,
      );
      _pendingMenus = null;
      return;
    }

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
        menuTree: _pendingMenus?.tree,
        flattenedMenus: _pendingMenus?.flattened,
      );
      _pendingMenus = null;
      return;
    }

    // Tam başarı
    MedLogger.info(unit: 'SW-UNIT-UI', swreq: 'SWREQ-UI-DASH-003', message: 'Dashboard başarıyla yüklendi');
    state = DashboardLoaded(data).copyWith(menuTree: _pendingMenus?.tree, flattenedMenus: _pendingMenus?.flattened);
  }

  /// RepoSuccess veya RepoStale → data döner, RepoFailure → null
  T? _extractData<T>(RepoResult<T> result) => switch (result) {
    RepoSuccess(:final data) => data,
    RepoStale(:final data) => data,
    RepoFailure() => null,
  };

  /// Listede ilk RepoStale'i döndürür — staleSince için
  RepoStale? _firstStaleEntry(List<RepoResult> results) {
    for (final r in results) {
      if (r is RepoStale) return r;
    }
    return null;
  }

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
      DashboardStale s => s.copyWith(activeRoute: targetRoute),
      DashboardPartial s => s.copyWith(activeRoute: targetRoute),
      _ => current, // Loading veya Error durumunda rota değişmez
    };

    MedLogger.info(unit: 'SW-UNIT-UI', message: 'Navigasyon tetiklendi: Target -> $targetRoute', swreq: '');
  }

  // Yardımcı metod: Farklı state tiplerinden listeyi güvenli al
  List<MenuItem>? _getFlattenMenus(DashboardUiState s) => switch (s) {
    DashboardLoaded(:final flattenedMenus) => flattenedMenus,
    DashboardStale(:final flattenedMenus) => flattenedMenus,
    DashboardPartial(:final flattenedMenus) => flattenedMenus,
    _ => null,
  };
}
