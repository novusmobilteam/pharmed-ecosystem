// [SWREQ-UI-DASH-002] [IEC 62304 §5.5]
// Anasayfa UiState tanımı.
// Her durum açık ve ayrıştırılmış — belirsizlik yok.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

class KpiData extends Equatable {
  const KpiData({
    required this.activePatients,
    required this.activePatientsProgress,
    required this.activePatientsChange,
    required this.completedOperations,
    required this.completedOperationsProgress,
    required this.completedOperationsChange,
    required this.pendingPrescriptions,
    required this.pendingPrescriptionsProgress,
    required this.criticalAlerts,
    required this.criticalAlertsProgress,
    required this.criticalAlertsChange,
  });

  final int activePatients;
  final double activePatientsProgress; // 0.0 – 1.0
  final int activePatientsChange; // +3, -1, 0

  final int completedOperations;
  final double completedOperationsProgress;
  final int completedOperationsChange;

  final int pendingPrescriptions;
  final double pendingPrescriptionsProgress;

  final int criticalAlerts;
  final double criticalAlertsProgress;
  final int criticalAlertsChange;

  @override
  List<Object?> get props => [activePatients, completedOperations, pendingPrescriptions, criticalAlerts];
}

class DashboardData {
  const DashboardData({
    this.upcomingTreatments = const [],
    this.drugActivities = const [],
    this.cabinVisualizerData,
    this.kpi,
  });

  final List<PrescriptionItem> upcomingTreatments;
  final List<PrescriptionItemMovement> drugActivities;
  final CabinVisualizerData? cabinVisualizerData;

  /// KPI servisi henüz yok — hazır olana kadar null, şerit gizlenir.
  final KpiData? kpi;

  bool get hasCabinData => cabinVisualizerData != null;
  bool get hasKpi => kpi != null;

  DashboardData copyWith({
    List<PrescriptionItem>? upcomingTreatments,
    List<PrescriptionItemMovement>? drugActivities,
    CabinVisualizerData? cabinVisualizerData,
    KpiData? kpi,
  }) => DashboardData(
    upcomingTreatments: upcomingTreatments ?? this.upcomingTreatments,
    drugActivities: drugActivities ?? this.drugActivities,
    cabinVisualizerData: cabinVisualizerData ?? this.cabinVisualizerData,
    kpi: kpi ?? this.kpi,
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
    this.treatmentsFailed = false,
    this.activitiesFailed = false,
    this.cabinFailed = false,
  });

  final DashboardData data;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;
  final String activeRoute;

  /// Bölüm bazlı hata — ilgili panel yerine retry kutusu gösterilir.
  /// Kurulum tamamlanmamışsa [cabinFailed] false kalır; kabin bölümü
  /// hata değil, "veri yok" olarak ele alınır.
  final bool treatmentsFailed;
  final bool activitiesFailed;
  final bool cabinFailed;

  DashboardLoaded copyWith({
    DashboardData? data,
    List<MenuItem>? menuTree,
    List<MenuItem>? flattenedMenus,
    String? activeRoute,
    bool? treatmentsFailed,
    bool? activitiesFailed,
    bool? cabinFailed,
  }) => DashboardLoaded(
    data: data ?? this.data,
    menuTree: menuTree ?? this.menuTree,
    flattenedMenus: flattenedMenus ?? this.flattenedMenus,
    activeRoute: activeRoute ?? this.activeRoute,
    treatmentsFailed: treatmentsFailed ?? this.treatmentsFailed,
    activitiesFailed: activitiesFailed ?? this.activitiesFailed,
    cabinFailed: cabinFailed ?? this.cabinFailed,
  );
}
