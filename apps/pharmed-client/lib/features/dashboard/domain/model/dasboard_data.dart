// [SWREQ-UI-DASH-001]
// Anasayfanın ihtiyaç duyduğu tüm verileri tek modelde toplar.
// Repository'lerden ayrı ayrı çekilen veriler burada birleşir.
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

// ─────────────────────────────────────────────────────────────────
// DashboardData — tüm widget verilerini bir arada tutar
// ─────────────────────────────────────────────────────────────────

class DashboardData extends Equatable {
  const DashboardData({
    required this.kpi,
    required this.expiringMaterials,
    required this.upcomingTreatments,
    required this.criticalStocks,
    this.cabinVisualizerData,
  });

  final KpiData kpi;
  final CabinVisualizerData? cabinVisualizerData;
  final List<CabinStock> expiringMaterials;
  final List<PrescriptionItem> upcomingTreatments;
  final List<CabinStock> criticalStocks;

  bool get hasCabinData => cabinVisualizerData != null;

  @override
  List<Object?> get props => [expiringMaterials, upcomingTreatments, criticalStocks];
}
