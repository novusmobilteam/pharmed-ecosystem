// // lib/feature/dashboard/data/mock/dashboard_mock_repository.dart
// //
// // [SWREQ-CORE-003]
// // Mock flavor için anasayfa veri kaynağı.
// // Tüm UI state'lerini test edebilmek için yeterli veri içerir.

// import 'package:pharmed_core/pharmed_core.dart';

// import '../../../../shared/widgets/molecules/molecules.dart';
// import '../../../cabin_stock/domain/model/cabin_stock.dart';
// import '../../domain/model/dasboard_data.dart';

// class DashboardMockRepository {
//   static const _delay = Duration(milliseconds: 800);

//   Future<Result<DashboardData>> getDashboardData() async {
//     await Future.delayed(_delay);
//     return Result.ok(_buildMockData());
//   }

//   static DashboardData _buildMockData() {
//     return DashboardData(kpi: _mockKpi(), cabin: _mockCabin(), skt: _mockSkt(), treatments: _mockTreatments());
//   }

//   // ── KPI ──────────────────────────────────────────────────────

//   static KpiData _mockKpi() => const KpiData(
//     activePatients: 18,
//     activePatientsProgress: 0.72,
//     activePatientsChange: 3,
//     completedOperations: 42,
//     completedOperationsProgress: 0.85,
//     completedOperationsChange: 5,
//     pendingPrescriptions: 7,
//     pendingPrescriptionsProgress: 0.35,
//     criticalAlerts: 3,
//     criticalAlertsProgress: 0.20,
//     criticalAlertsChange: -1,
//   );

//   // ── Kabin ─────────────────────────────────────────────────────

//   static CabinSummary _mockCabin() => CabinSummary(
//     cabinId: 304,
//     cabinCode: 'CB-304',
//     isLocked: true,
//     todayOperations: 24,
//     lastOpenedAt: '08:31',
//     lastOpenedBy: 'Ayşe Kara',
//     stocks: _mockStocks(),
//   );

//   static List<CabinStock> _mockStocks() => [
//     _stock(
//       id: 1,
//       row: 1,
//       col: 1,
//       code: 'A-01',
//       name: 'Amoksisilin 500mg',
//       qty: 24,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 8, 15),
//     ),
//     _stock(
//       id: 2,
//       row: 1,
//       col: 2,
//       code: 'A-02',
//       name: 'Metformin 1000mg',
//       qty: 18,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 11, 20),
//     ),
//     _stock(
//       id: 3,
//       row: 1,
//       col: 3,
//       code: 'A-03',
//       name: 'Omeprazol 20mg',
//       qty: 12,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 5, 10),
//     ),
//     _stock(
//       id: 4,
//       row: 2,
//       col: 1,
//       code: 'A-04',
//       name: 'Heparin 5000 IU',
//       qty: 3,
//       crit: 5,
//       status: StockStatus.low,
//       expiry: DateTime(2026, 4, 10),
//     ),
//     _stock(
//       id: 5,
//       row: 2,
//       col: 2,
//       code: 'A-05',
//       name: 'Paracetamol 500mg',
//       qty: 30,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 9, 1),
//     ),
//     _stock(
//       id: 6,
//       row: 2,
//       col: 3,
//       code: 'A-06',
//       name: 'Amlodipin 5mg',
//       qty: 20,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 7, 15),
//     ),
//     _stock(
//       id: 7,
//       row: 3,
//       col: 1,
//       code: 'B-01',
//       name: 'Furosemid 40mg',
//       qty: 15,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 6, 30),
//     ),
//     _stock(
//       id: 8,
//       row: 3,
//       col: 2,
//       code: 'B-02',
//       name: 'İnsülin Glarjin 100 IU',
//       qty: 2,
//       crit: 3,
//       status: StockStatus.critical,
//       expiry: DateTime(2026, 3, 29),
//     ),
//     _stock(
//       id: 9,
//       row: 3,
//       col: 3,
//       code: 'B-03',
//       name: 'Warfarin 5mg',
//       qty: 22,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 10, 5),
//     ),
//     _stock(
//       id: 10,
//       row: 4,
//       col: 1,
//       code: 'B-04',
//       name: 'Atorvastatin 20mg',
//       qty: 16,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 8, 20),
//     ),
//     _stock(
//       id: 11,
//       row: 4,
//       col: 2,
//       code: 'B-05',
//       name: 'Ramipril 5mg',
//       qty: 14,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 9, 10),
//     ),
//     _stock(
//       id: 12,
//       row: 4,
//       col: 3,
//       code: 'B-06',
//       name: 'Metoprolol 50mg',
//       qty: 4,
//       crit: 5,
//       status: StockStatus.low,
//       expiry: DateTime(2026, 7, 1),
//     ),
//     _stock(id: 13, row: 5, col: 1, code: 'C-01', name: null, qty: 0, crit: 0, status: StockStatus.empty, expiry: null),
//     _stock(
//       id: 14,
//       row: 5,
//       col: 2,
//       code: 'C-02',
//       name: 'Deksametazon 8mg',
//       qty: 10,
//       crit: 5,
//       status: StockStatus.full,
//       expiry: DateTime(2026, 6, 15),
//     ),
//     _stock(id: 15, row: 5, col: 3, code: 'C-03', name: null, qty: 0, crit: 0, status: StockStatus.empty, expiry: null),
//   ];

//   static CabinStock _stock({
//     required int id,
//     required int row,
//     required int col,
//     required String code,
//     required String? name,
//     required int qty,
//     required int crit,
//     required StockStatus status,
//     required DateTime? expiry,
//   }) => CabinStock(
//     id: id,
//     cabinId: 304,
//     drawerId: id,
//     drawerCode: code,
//     drawerRow: row,
//     drawerColumn: col,
//     medicineId: name != null ? id + 100 : null,
//     medicineName: name,
//     quantity: qty,
//     criticalLevel: crit,
//     stockStatus: status,
//     expiryStatus: ExpiryStatus.fromDate(expiry),
//     expiryDate: expiry,
//     isActive: true,
//   );

//   // ── SKT ───────────────────────────────────────────────────────

//   static SktSummary _mockSkt() {
//     final now = DateTime.now();
//     return SktSummary(
//       expiredStocks: [
//         _stock(
//           id: 20,
//           row: 1,
//           col: 1,
//           code: 'A-12',
//           name: 'Serum Fizyolojik 0.9%',
//           qty: 6,
//           crit: 4,
//           status: StockStatus.full,
//           expiry: now.subtract(const Duration(days: 6)),
//         ),
//       ],
//       expiringStocks: [
//         _stock(
//           id: 21,
//           row: 3,
//           col: 2,
//           code: 'B-02',
//           name: 'İnsülin Glarjin 100 IU',
//           qty: 8,
//           crit: 3,
//           status: StockStatus.critical,
//           expiry: now.add(const Duration(days: 3)),
//         ),
//         _stock(
//           id: 22,
//           row: 3,
//           col: 3,
//           code: 'B-08',
//           name: 'Metronidazol 500mg IV',
//           qty: 12,
//           crit: 5,
//           status: StockStatus.full,
//           expiry: now.add(const Duration(days: 7)),
//         ),
//         _stock(
//           id: 23,
//           row: 4,
//           col: 1,
//           code: 'B-11',
//           name: 'Heparin 5000 IU',
//           qty: 3,
//           crit: 5,
//           status: StockStatus.low,
//           expiry: now.add(const Duration(days: 15)),
//         ),
//         _stock(
//           id: 24,
//           row: 5,
//           col: 2,
//           code: 'C-07',
//           name: 'Amoksisilin 500mg',
//           qty: 24,
//           crit: 5,
//           status: StockStatus.full,
//           expiry: now.add(const Duration(days: 18)),
//         ),
//       ],
//     );
//   }

//   // ── Tedaviler ─────────────────────────────────────────────────

//   static List<TreatmentEntry> _mockTreatments() {
//     final today = DateTime.now();
//     return [
//       TreatmentEntry(
//         id: 1,
//         scheduledAt: DateTime(today.year, today.month, today.day, 7, 0),
//         patientName: 'Selma Ercan',
//         patientId: 'P-0033',
//         patientRoom: 'Oda 301',
//         medicineName: 'Omeprazol 20mg',
//         dose: '1×1 — PO (AC)',
//         drawerCode: 'A-09',
//         priority: TreatmentPriority.routine,
//         status: TreatmentStatus.done,
//       ),
//       TreatmentEntry(
//         id: 2,
//         scheduledAt: DateTime(today.year, today.month, today.day, 8, 0),
//         patientName: 'Fatma Yılmaz',
//         patientId: 'P-0078',
//         patientRoom: 'Oda 305',
//         medicineName: 'Metformin 1000mg',
//         dose: '2×1 — PO',
//         drawerCode: 'A-03',
//         priority: TreatmentPriority.normal,
//         status: TreatmentStatus.done,
//       ),
//       TreatmentEntry(
//         id: 3,
//         scheduledAt: DateTime(today.year, today.month, today.day, 8, 30),
//         patientName: 'Kemal Demir',
//         patientId: 'P-0091',
//         patientRoom: 'Oda 318',
//         medicineName: 'Heparin 5000 IU',
//         dose: 'SC — 12h',
//         drawerCode: 'B-11',
//         priority: TreatmentPriority.urgent,
//         status: TreatmentStatus.pending,
//       ),
//       TreatmentEntry(
//         id: 4,
//         scheduledAt: DateTime(today.year, today.month, today.day, 9, 0),
//         patientName: 'Mehmet Aksoy',
//         patientId: 'P-0042',
//         patientRoom: 'Oda 312',
//         medicineName: 'Amoksisilin 500mg',
//         dose: '3×1 — PO',
//         drawerCode: 'C-07',
//         priority: TreatmentPriority.urgent,
//         status: TreatmentStatus.pending,
//       ),
//       TreatmentEntry(
//         id: 5,
//         scheduledAt: DateTime(today.year, today.month, today.day, 10, 0),
//         patientName: 'Zeynep Balcı',
//         patientId: 'P-0055',
//         patientRoom: 'Oda 309',
//         medicineName: 'Paracetamol 500mg',
//         dose: '4×1 — PO (PRN)',
//         drawerCode: 'A-01',
//         priority: TreatmentPriority.routine,
//         status: TreatmentStatus.pending,
//       ),
//       TreatmentEntry(
//         id: 6,
//         scheduledAt: DateTime(today.year, today.month, today.day, 22, 0),
//         patientName: 'Hasan Korkmaz',
//         patientId: 'P-0112',
//         patientRoom: 'Oda 315',
//         medicineName: 'İnsülin Glarjin 10 IU',
//         dose: 'SC — Gece',
//         drawerCode: 'C-02',
//         priority: TreatmentPriority.normal,
//         status: TreatmentStatus.returned,
//       ),
//     ];
//   }
// }
