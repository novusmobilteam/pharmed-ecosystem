// lib/feature/dashboard/domain/model/dashboard_data.dart
//
// [SWREQ-UI-DASH-001]
// Anasayfanın ihtiyaç duyduğu tüm verileri tek modelde toplar.
// Repository'lerden ayrı ayrı çekilen veriler burada birleşir.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import '../../../../shared/widgets/atoms/atoms.dart';
import '../../../../shared/widgets/molecules/molecules.dart';
import '../../../cabin_stock/domain/model/cabin_stock.dart';
import 'app_model.dart';

// ─────────────────────────────────────────────────────────────────
// KpiData — üst KPI kartlarının verisi
// ─────────────────────────────────────────────────────────────────

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
// CabinSummary — kabin widget'ının verisi
// ─────────────────────────────────────────────────────────────────

class CabinSummary extends Equatable {
  const CabinSummary({
    required this.cabinId,
    required this.cabinCode,
    required this.isLocked,
    required this.stocks,
    required this.lastOpenedAt,
    required this.lastOpenedBy,
    required this.todayOperations,
  });

  final int cabinId;

  /// Örn: "CB-304"
  final String cabinCode;
  final bool isLocked;

  /// Tüm çekmece stokları — görsel grid ve istatistik için
  final List<CabinStock> stocks;

  final String lastOpenedAt;
  final String lastOpenedBy;
  final int todayOperations;

  // ── Hesaplanan getter'lar ─────────────────────────────────────

  int get totalDrawers => stocks.length;

  int get fullDrawers => stocks.where((s) => s.stockStatus == StockStatus.full).length;

  int get emptyDrawers => stocks.where((s) => s.stockStatus == StockStatus.empty).length;

  int get criticalCount => stocks.where((s) => s.stockStatus == StockStatus.critical).length;

  /// [HAZ-003] Grid için satır × sütun yapısı
  /// Çekmeceler drawerRow ve drawerColumn'a göre sıralanır
  List<List<DrawerStatus>> get drawerGrid {
    if (stocks.isEmpty) return [];

    // Satır ve sütun sayısını belirle
    final maxRow = stocks.map((s) => s.drawerRow).reduce((a, b) => a > b ? a : b);
    final maxCol = stocks.map((s) => s.drawerColumn).reduce((a, b) => a > b ? a : b);

    // Grid'i boş ile doldur
    final grid = List.generate(maxRow, (_) => List.filled(maxCol, DrawerStatus.empty));

    // Stokları yerleştir (0-indexed)
    for (final stock in stocks) {
      final row = stock.drawerRow - 1;
      final col = stock.drawerColumn - 1;
      if (row >= 0 && row < maxRow && col >= 0 && col < maxCol) {
        grid[row][col] = _toDrawerStatus(stock.stockStatus);
      }
    }

    return grid;
  }

  DrawerStatus _toDrawerStatus(StockStatus s) => switch (s) {
    StockStatus.full => DrawerStatus.full,
    StockStatus.low => DrawerStatus.low,
    StockStatus.critical => DrawerStatus.critical,
    StockStatus.empty => DrawerStatus.empty,
  };

  @override
  List<Object?> get props => [cabinId, isLocked, stocks];
}

// ─────────────────────────────────────────────────────────────────
// SktSummary — SKT widget'ının verisi
// ─────────────────────────────────────────────────────────────────

class SktSummary extends Equatable {
  const SktSummary({required this.expiringStocks, required this.expiredStocks});

  final List<CabinStock> expiringStocks;
  final List<CabinStock> expiredStocks;

  List<CabinStock> get allItems => [...expiredStocks, ...expiringStocks];

  int get expiredCount => expiredStocks.length;
  int get criticalCount => expiringStocks.where((s) => s.expiryStatus == ExpiryStatus.critical).length;
  int get warningCount => expiringStocks.where((s) => s.expiryStatus == ExpiryStatus.warning).length;

  @override
  List<Object?> get props => [expiringStocks, expiredStocks];
}

// ─────────────────────────────────────────────────────────────────
// TreatmentEntry — yaklaşan tedaviler listesindeki tek kayıt
// ─────────────────────────────────────────────────────────────────

class TreatmentEntry extends Equatable {
  const TreatmentEntry({
    required this.id,
    required this.scheduledAt,
    required this.patientName,
    required this.patientId,
    required this.patientRoom,
    required this.medicineName,
    required this.dose,
    required this.drawerCode,
    required this.priority,
    required this.status,
  });

  final int id;
  final DateTime scheduledAt;
  final String patientName;
  final String patientId;
  final String patientRoom;
  final String medicineName;
  final String dose;
  final String drawerCode;
  final TreatmentPriority priority;
  final TreatmentStatus status;

  String get timeLabel {
    final h = scheduledAt.hour.toString().padLeft(2, '0');
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get patientIdLabel => '#$patientId · $patientRoom';

  bool get isUrgent => priority == TreatmentPriority.urgent && status == TreatmentStatus.pending;

  @override
  List<Object?> get props => [id, scheduledAt, status];
}

// ─────────────────────────────────────────────────────────────────
// DashboardData — tüm widget verilerini bir arada tutar
// ─────────────────────────────────────────────────────────────────

class DashboardData extends Equatable {
  const DashboardData({
    required this.kpi,
    required this.cabin,
    required this.skt,
    required this.treatments,
    this.alerts = const [],
    this.activities = const [],
  });

  final KpiData kpi;
  final CabinSummary cabin;
  final SktSummary skt;
  final List<TreatmentEntry> treatments;
  final List<AlertItem> alerts;
  final List<ActivityItem> activities;

  @override
  List<Object?> get props => [kpi, cabin, skt, treatments];
}
