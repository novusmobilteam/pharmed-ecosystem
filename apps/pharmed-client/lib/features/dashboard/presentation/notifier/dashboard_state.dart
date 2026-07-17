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
    this.cabinVisualizerData,
  });

  final CabinVisualizerData? cabinVisualizerData;
  final DashboardSection<List<PrescriptionItem>?> upcomingTreatments;
  final DashboardSection<List<PrescriptionItem>?> unappliedPrescriptions;
  final DashboardSection<List<PrescriptionItemMovement>?> drugActivities;

  bool get hasCabinData => cabinVisualizerData != null;

  DashboardData copyWith({
    CabinVisualizerData? cabinVisualizerData,
    DashboardSection<List<PrescriptionItem>>? upcomingTreatments,
    DashboardSection<List<PrescriptionItemMovement>>? drugActivities,
    DashboardSection<List<PrescriptionItem>>? unappliedPrescriptions,
  }) => DashboardData(
    upcomingTreatments: upcomingTreatments ?? this.upcomingTreatments,
    drugActivities: drugActivities ?? this.drugActivities,
    cabinVisualizerData: cabinVisualizerData ?? this.cabinVisualizerData,
    unappliedPrescriptions: unappliedPrescriptions ?? this.unappliedPrescriptions,
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
  });

  final DashboardData data;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;
  final String activeRoute;

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
  );
}
