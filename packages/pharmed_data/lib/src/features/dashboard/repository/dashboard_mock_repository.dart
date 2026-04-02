// [SWREQ-DATA-DASH-007] [IEC 62304 §5.5]
// Mock flavor için dashboard repository'si.
// API'ye çıkılmaz, sabit veriler döner.
// Read metodları her zaman RepoSuccess döndürür.
// Sınıf: Class A

import 'package:pharmed_core/pharmed_core.dart';

class MockDashboardRepository implements IDashboardRepository {
  static const _delay = Duration(milliseconds: 500);
  static final _now = DateTime.now();

  // ── Mock Veri ─────────────────────────────────────────────────

  static final List<CabinStock> _expiringMaterials = [
    CabinStock(
      id: 1,
      cabinId: 1,
      quantity: 3,
      miadDate: _now.add(const Duration(days: 3)),
      medicine: Drug(id: 1, name: 'İnsülin Glarjin'),
    ),
    CabinStock(
      id: 2,
      cabinId: 1,
      quantity: 8,
      miadDate: _now.add(const Duration(days: 7)),
      medicine: Drug(id: 2, name: 'Metronidazol 500mg'),
    ),
    CabinStock(
      id: 3,
      cabinId: 1,
      quantity: 2,
      miadDate: _now.subtract(const Duration(days: 1)),
      medicine: Drug(id: 3, name: 'Serum Fizyolojik'),
    ),
  ];

  static final List<CabinStock> _criticalStocks = [
    CabinStock(id: 4, cabinId: 1, quantity: 1, medicine: Drug(id: 4, name: 'Amoksisilin 500mg')),
    CabinStock(id: 5, cabinId: 1, quantity: 0, medicine: Drug(id: 5, name: 'Parasetamol 500mg')),
  ];

  static final List<PrescriptionItem> _unreadQrCodes = [
    PrescriptionItem(
      id: 1,
      patientName: 'Mehmet Aksoy',
      protocolNo: 'P-0042',
      medicine: Drug(id: 1, name: 'İnsülin Glarjin'),
    ),
    PrescriptionItem(
      id: 2,
      patientName: 'Fatma Yılmaz',
      protocolNo: 'P-0078',
      medicine: Drug(id: 2, name: 'Metronidazol 500mg'),
    ),
  ];

  static final List<Prescription> _unappliedPrescriptions = [
    Prescription(
      id: 1,
      code: 1001,
      name: 'Mehmet Aksoy',
      prescriptionDate: _now.subtract(const Duration(hours: 2)),
      remainingCount: 3,
    ),
    Prescription(
      id: 2,
      code: 1002,
      name: 'Fatma Yılmaz',
      prescriptionDate: _now.subtract(const Duration(hours: 5)),
      remainingCount: 1,
    ),
  ];

  static final List<Refund> _refunds = [
    Refund(
      id: 1,
      quantity: 2,
      medicine: Drug(id: 1, name: 'İnsülin Glarjin'),
      receiveDate: _now.subtract(const Duration(hours: 1)),
    ),
  ];

  static final List<CabinStock> _generalStocks = [
    CabinStock(id: 6, cabinId: 1, quantity: 24, medicine: Drug(id: 1, name: 'İnsülin Glarjin')),
    CabinStock(id: 7, cabinId: 1, quantity: 12, medicine: Drug(id: 2, name: 'Metronidazol 500mg')),
    CabinStock(id: 8, cabinId: 1, quantity: 0, medicine: Drug(id: 5, name: 'Parasetamol 500mg')),
  ];

  static final List<PrescriptionItem> _upcomingTreatments = [
    PrescriptionItem(
      id: 3,
      patientName: 'Kemal Demir',
      protocolNo: 'P-0091',
      time: _now.add(const Duration(minutes: 30)),
      medicine: Drug(id: 4, name: 'Amoksisilin 500mg'),
    ),
    PrescriptionItem(
      id: 4,
      patientName: 'Selma Ercan',
      protocolNo: 'P-0033',
      time: _now.add(const Duration(hours: 1)),
      medicine: Drug(id: 2, name: 'Metronidazol 500mg'),
    ),
    PrescriptionItem(
      id: 5,
      patientName: 'Hasan Korkmaz',
      protocolNo: 'P-0112',
      time: _now.add(const Duration(hours: 2)),
      medicine: Drug(id: 1, name: 'İnsülin Glarjin'),
    ),
  ];

  // ── Repository metodları ───────────────────────────────────────

  @override
  void clearCache() {} // Mock'ta cache yok, no-op

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_unreadQrCodes));
  }

  @override
  Future<RepoResult<List<CabinStock>>> getExpiringMaterials({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_expiringMaterials));
  }

  @override
  Future<RepoResult<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_criticalStocks));
  }

  @override
  Future<RepoResult<List<Prescription>>> getUnappliedPrescriptions({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_unappliedPrescriptions));
  }

  @override
  Future<RepoResult<List<Refund>>> getRefunds({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_refunds));
  }

  @override
  Future<RepoResult<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_generalStocks));
  }

  @override
  Future<RepoResult<List<PrescriptionItem>>> getUpcomingTreatments({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_upcomingTreatments));
  }

  @override
  Future<RepoResult<List<MenuItem>>> getMenuItems({int? userId}) async {
    await Future.delayed(_delay);
    return RepoSuccess([]);
  }
}
