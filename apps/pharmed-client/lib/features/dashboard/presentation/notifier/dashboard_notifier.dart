// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state yöneticisi — fetch grubu + menü/rota.
// Sensör telemetrisi (CabinSensorNotifier) ve kabin bağlantısı
// (CabinConnectionNotifier) bağımsız yaşam döngüsüne sahiptir; bu notifier
// onları yönetmez, sadece connect() tetikler.
// Repository'yi bilir, Dio/Hive'ı bilmez.
// Sınıf: Class B

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../settings/notifier/settings_notifier.dart';

class DashboardNotifier extends ChangeNotifier with ApiRequestMixin {
  DashboardNotifier({
    required GetUpcomingTreatmentsUseCase getUpcomingTreatments,
    required GetDrugActivitiesUseCase getDrugActivities,
    required GetDashboardUnappliedPrescriptionsUseCase getUnapplied,
    required GetCabinVisualizerDataUseCase getCabinVisualizer,
    required GetFilteredMenusUseCase getFilteredMenus,
    required GetAllRoomsUseCase getAllRooms,
    required GetAllBedsUseCase getAllBeds,
    required GetAllServicesUseCase getAllServices,
    required Future<CabinType?> Function() getDeviceMode,
    required AppSettingsCache settings,
    required AuthNotifier authNotifier,
    required SettingsNotifier settingsNotifier,
    required CabinConnectionNotifier cabinConnection,
  }) : _getUpcomingTreatments = getUpcomingTreatments,
       _getDrugActivities = getDrugActivities,
       _getUnapplied = getUnapplied,
       _getCabinVisualizer = getCabinVisualizer,
       _getFilteredMenus = getFilteredMenus,
       _getAllRooms = getAllRooms,
       _getAllBeds = getAllBeds,
       _getAllServices = getAllServices,
       _getDeviceMode = getDeviceMode,
       _settings = settings,
       _authNotifier = authNotifier,
       _settingsNotifier = settingsNotifier,
       _cabinConnection = cabinConnection {
    if (kDebugMode) {
      _settingsNotifier.addListener(_onSettingsChanged);
    }
  }

  //static const _refreshInterval = Duration(minutes: 5);

  final GetUpcomingTreatmentsUseCase _getUpcomingTreatments;
  final GetDrugActivitiesUseCase _getDrugActivities;
  final GetDashboardUnappliedPrescriptionsUseCase _getUnapplied;
  final GetCabinVisualizerDataUseCase _getCabinVisualizer;
  final GetFilteredMenusUseCase _getFilteredMenus;
  final GetAllRoomsUseCase _getAllRooms;
  final GetAllBedsUseCase _getAllBeds;
  final GetAllServicesUseCase _getAllServices;
  final Future<CabinType?> Function() _getDeviceMode;
  final AppSettingsCache _settings;
  final AuthNotifier _authNotifier;
  final SettingsNotifier _settingsNotifier;
  final CabinConnectionNotifier _cabinConnection;

  Timer? _timer;
  bool _isDisposed = false;
  int? _debugCabinIdWatched;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    if (kDebugMode) {
      _settingsNotifier.removeListener(_onSettingsChanged);
    }
    super.dispose();
  }

  void _onSettingsChanged() {
    final nextDebugCabinId = _settingsNotifier.debugCabin?.id;
    if (_debugCabinIdWatched == nextDebugCabinId) return;
    _debugCabinIdWatched = nextDebugCabinId;
    unawaited(_load(cabinId: nextDebugCabinId));
  }

  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  CabinType? _cabinType;
  CabinType? get cabinType => _cabinType;

  String? _globalErrorMessage;
  String? get globalErrorMessage => _globalErrorMessage;

  List<MenuItem> _menuTree = [];
  List<MenuItem> get menuTree => _menuTree;

  List<MenuItem>? _flattenedMenus;
  List<MenuItem>? get flattenedMenus => _flattenedMenus;

  String _activeRoute = 'dashboard';
  String get activeRoute => _activeRoute;

  bool get isLoaded => !_isInitialLoading && _globalErrorMessage == null;

  List<PrescriptionItemMovement> _activities = const [];
  List<PrescriptionItemMovement> get activities => _activities;

  List<PrescriptionItem> _treatments = const [];
  List<PrescriptionItem> get treatments => _treatments;

  List<PrescriptionItem> _unapplieds = const [];
  List<PrescriptionItem> get unapplieds => _unapplieds;

  CabinVisualizerData? _cabinVisualizerData;
  CabinVisualizerData? get cabinVisualizerData => _cabinVisualizerData;

  final activitiesOp = OperationKey.custom('fetch-activities');
  final treatmentsOp = OperationKey.custom('fetch-treatments');
  final unappliedOp = OperationKey.custom('fetch-unapplied');
  final cabinVisualizerOp = OperationKey.custom('fetch-cabin-visualizer');

  bool get isActiveRouteDashboard => _activeRoute == 'dashboard';

  Future<void> initialize() async {
    _cabinType = await _getDeviceMode();
    if (_isDisposed) return;

    await Future.wait([_fetchMenus(), _load()]);
    if (_isDisposed) return;

    if (await _settings.isSetupComplete()) {
      if (_isDisposed) return;
      unawaited(_cabinConnection.connect());
    }

    //_startPeriodicRefresh();
  }

  Future<void> refresh() => _load();

  Future<void> _load({int? cabinId}) async {
    if (_isDisposed) return;
    _isInitialLoading = true;
    _notify();

    if (_isDisposed) return;

    await Future.wait([
      _getAllRooms.call(),
      _getAllBeds.call(),
      _getAllServices.call(),
      fetchActivities(),
      fetchTreatments(),
      fetchUnapplied(),
      _fetchCabinVisualizer(debugCabinId: cabinId),
    ]);

    if (_isDisposed) return;
    _isInitialLoading = false;
    _notify();
  }

  Future<void> fetchActivities() async {
    final mac = await DeviceInfo.getMacAddress();
    await execute(
      activitiesOp,
      operation: () => _getDrugActivities.call(mac: mac),
      onData: (data) {
        _activities = data ?? const [];
        _notify();
      },
    );
  }

  Future<void> fetchTreatments() async {
    final mac = await DeviceInfo.getMacAddress();
    await execute(
      treatmentsOp,
      operation: () => _getUpcomingTreatments.call(mac: mac),
      onData: (data) {
        _treatments = data;
        _notify();
      },
    );
  }

  Future<void> fetchUnapplied() async {
    await execute(
      unappliedOp,
      operation: () => _getUnapplied.call(),
      onData: (data) {
        _unapplieds = data;
        _notify();
      },
    );
  }

  Future<void> _fetchCabinVisualizer({int? debugCabinId}) async {
    if (!await _settings.isSetupComplete()) return;
    if (_isDisposed) return;
    if (_cabinVisualizerData != null) return;

    await execute(
      cabinVisualizerOp,
      operation: () async {
        final cabinId = debugCabinId ?? await _settings.getCurrentCabinId();
        return _getCabinVisualizer.call(deviceMode: _cabinType, cabinId: cabinId);
      },
      onData: (cabin) {
        _cabinVisualizerData = cabin;
        _notify();
      },
    );
  }

  /// Kabin görselini bağımsız olarak yeniden çeker (ör. donanım event'i
  /// sonrası) — tüm dashboard'u yeniden yüklemeden.
  Future<void> refreshCabinVisualizer() async {
    if (_isInitialLoading) return;
    await _fetchCabinVisualizer();
  }

  Future<void> _fetchMenus() async {
    final user = _authNotifier.currentUser;
    final result = await _getFilteredMenus.call(userId: user?.id);
    if (_isDisposed) return;

    result.when(
      ok: (menus) {
        _menuTree = menus.tree;
        _flattenedMenus = menus.flattened;
        _notify();
      },
      error: (_) {},
    );
  }

  void navigateTo(dynamic destination) {
    if (_isInitialLoading) return;

    final route = switch (destination) {
      int id => _flattenedMenus?.firstWhereOrNull((m) => m.id == id)?.slug ?? 'dashboard',
      String path => path,
      _ => 'dashboard',
    };

    _activeRoute = route;
    _notify();
  }

  // void _startPeriodicRefresh() {
  //   _timer?.cancel();
  //   _timer = Timer.periodic(_refreshInterval, (_) {
  //     //_load();
  //   });
  // }
}
