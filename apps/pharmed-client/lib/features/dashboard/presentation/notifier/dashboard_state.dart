// [SWREQ-UI-DASH-002] [IEC 62304 §5.5]
// Anasayfa UiState tanımı.
// Her durum açık ve ayrıştırılmış — belirsizlik yok.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class DashboardData {
  const DashboardData({
    this.upcomingTreatments = const DashboardSection(),
    this.drugActivities = const DashboardSection(),
    this.unappliedPrescriptions = const DashboardSection(),
    this.stationCabins = const [],
    this.cabinVisualizerDataByCabinId = const {},
    this.cabinDataFailed = false,
  });

  final DashboardSection<List<PrescriptionItem>?> upcomingTreatments;
  final DashboardSection<List<PrescriptionItem>?> unappliedPrescriptions;
  final DashboardSection<List<PrescriptionItemMovement>?> drugActivities;

  /// İstasyondaki tüm kabinler — kabin seçim ekranında isim/tip/adres
  /// göstermek için (CabinVisualizerData bu bilgileri taşımıyor).
  final List<Cabin> stationCabins;

  final Map<int, CabinVisualizerData> cabinVisualizerDataByCabinId;
  final bool cabinDataFailed;

  bool get hasCabinData => cabinVisualizerDataByCabinId.isNotEmpty;

  DashboardData copyWith({
    DashboardSection<List<PrescriptionItem>?>? upcomingTreatments,
    DashboardSection<List<PrescriptionItemMovement>?>? drugActivities,
    DashboardSection<List<PrescriptionItem>?>? unappliedPrescriptions,
    List<Cabin>? stationCabins,
    Map<int, CabinVisualizerData>? cabinVisualizerDataByCabinId,
    bool? cabinDataFailed,
  }) => DashboardData(
    upcomingTreatments: upcomingTreatments ?? this.upcomingTreatments,
    drugActivities: drugActivities ?? this.drugActivities,
    unappliedPrescriptions: unappliedPrescriptions ?? this.unappliedPrescriptions,
    stationCabins: stationCabins ?? this.stationCabins,
    cabinVisualizerDataByCabinId: cabinVisualizerDataByCabinId ?? this.cabinVisualizerDataByCabinId,
    cabinDataFailed: cabinDataFailed ?? this.cabinDataFailed,
  );
}

// [SWREQ-UI-DASH-003] [IEC 62304 §5.5]
// Anasayfa state hiyerarşisi. Sınıf: Class B

sealed class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Tüm kaynaklar başarısız — gösterilecek hiçbir şey yok.
class DashboardError extends DashboardState {
  const DashboardError({required this.message, this.isRetryable = true});

  final String message;
  final bool isRetryable;
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    this.data = const DashboardData(),
    this.menuTree,
    this.flattenedMenus,
    this.activeRoute = 'dashboard',
    this.activeCabinId,
    this.pendingCabinRoute,
    this.deviceMode,
  });

  final DashboardData data;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;
  final String activeRoute;
  final int? activeCabinId;
  final String? pendingCabinRoute;

  /// İstasyonun cihaz modu (kurulum sırasında sabitlenmiş — master/mobile).
  /// Kabin seçim ekranının gösterilip gösterilmeyeceğine bu karar verir:
  /// mobil istasyonlarda seçim ekranı HİÇ gösterilmez.
  final CabinType? deviceMode;

  DashboardLoaded copyWith({
    DashboardData? data,
    List<MenuItem>? menuTree,
    List<MenuItem>? flattenedMenus,
    String? activeRoute,
    int? activeCabinId,
    bool clearActiveCabinId = false,
    String? pendingCabinRoute,
    bool clearPendingCabinRoute = false,
    CabinType? deviceMode,
  }) => DashboardLoaded(
    data: data ?? this.data,
    menuTree: menuTree ?? this.menuTree,
    flattenedMenus: flattenedMenus ?? this.flattenedMenus,
    activeRoute: activeRoute ?? this.activeRoute,
    activeCabinId: clearActiveCabinId ? null : (activeCabinId ?? this.activeCabinId),
    pendingCabinRoute: clearPendingCabinRoute ? null : (pendingCabinRoute ?? this.pendingCabinRoute),
    deviceMode: deviceMode ?? this.deviceMode,
  );
}
