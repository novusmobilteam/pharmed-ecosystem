// lib/features/unapplied_prescription_screen/unapplied_prescription_notifier.dart
//
// [SWREQ-UI-UNAPP-NOTIFIER-001]
// Sınıf : Class A
//
// PrescriptionNotifier ile aynı API çağrıları — fark:
//   onPatientTap içinde API'den gelen tüm items'a
//   PrescriptionMovementType.purchasePending filtresi uygulanır.

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UnappliedPrescriptionNotifier extends ChangeNotifier with ApiRequestMixin {
  UnappliedPrescriptionNotifier({
    required GetBedAssignmentsUseCase getBedAssignments,
    required GetActiveHospitalizationsUseCase getHospitalizations,
    required GetPatientPrescriptionHistoryUseCase getPrescriptionHistory,
    // GEÇİCİ — DeviceMode henüz Riverpod'dan taşınmadı.
    required Future<CabinType?> Function() getDeviceMode,
  }) : _getBedAssignments = getBedAssignments,
       _getHospitalizations = getHospitalizations,
       _getPrescriptionHistory = getPrescriptionHistory,
       _getDeviceMode = getDeviceMode;

  final GetBedAssignmentsUseCase _getBedAssignments;
  final GetActiveHospitalizationsUseCase _getHospitalizations;
  final GetPatientPrescriptionHistoryUseCase _getPrescriptionHistory;
  final Future<CabinType?> Function() _getDeviceMode;

  final OperationKey initOp = OperationKey.custom('init');
  final OperationKey prescriptionsOp = OperationKey.custom('load-prescriptions');

  // ── State ────────────────────────────────────────────────────────

  int? _cabinId;
  int? get cabinId => _cabinId;

  List<Hospitalization> _hospitalizations = const [];
  List<Hospitalization> get hospitalizations => _hospitalizations;

  String _search = '';
  String get search => _search;

  Hospitalization? _selectedPatient;
  Hospitalization? get selectedPatient => _selectedPatient;

  /// Yalnızca PrescriptionMovementType.purchasePending olanlar.
  List<PrescriptionItem> _prescriptionItems = const [];
  List<PrescriptionItem> get prescriptionItems => _prescriptionItems;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isInitialized => _cabinId != null;
  bool get isInitialLoading => isLoading(initOp) && !isInitialized;
  bool get isPrescriptionsLoading => isLoading(prescriptionsOp);
  bool get isPatientSelected => _selectedPatient != null;

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(int cabinId) async {
    await execute(
      initOp,
      operation: () async {
        final cabinType = await _getDeviceMode();
        final isMobile = cabinType == CabinType.mobile;

        return isMobile
            ? _fromBedAssignments(await _getBedAssignments.call(cabinId))
            : _fromApiResponse(await _getHospitalizations.call(const PagedQueryParams()));
      },
      onData: (hospitalizations) async {
        _cabinId = cabinId;
        _hospitalizations = hospitalizations;
        _selectedPatient = null;
        _prescriptionItems = const [];
        notifyListeners();

        if (hospitalizations.isEmpty) return;
        await onPatientTap(hospitalizations.first);
      },
      onFailed: (e) {
        _cabinId = cabinId;
        _hospitalizations = const [];
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null || !isInitialized) return;

    // Toggle — aynı hasta tekrar seçilirse seçim kaldırılır
    if (_selectedPatient?.patient?.id == patientId) {
      _selectedPatient = null;
      _prescriptionItems = const [];
      notifyListeners();
      return;
    }

    _selectedPatient = hospitalization;
    _prescriptionItems = const [];
    notifyListeners();

    await execute(
      prescriptionsOp,
      operation: () => _getPrescriptionHistory.call(patientId),
      onData: (items) {
        _prescriptionItems = items.where((item) => item.status == PrescriptionMovementType.purchasePending).toList();
        notifyListeners();
      },
      onFailed: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  void onSearchChanged(String value) {
    if (!isInitialized) return;
    _search = value;
    notifyListeners();
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Mobil akış — BedAssignment listesini Hospitalization'a indirger.
  Result<List<Hospitalization>> _fromBedAssignments(Result<List<BedAssignment>> result) {
    return result.when(ok: (assignments) => Result.ok(_toHospitalizations(assignments)), error: (e) => Result.error(e));
  }

  /// Master/diğer cihazlar akışı — ApiResponse sarmalını burada çözüyoruz.
  Result<List<Hospitalization>> _fromApiResponse(Result<ApiResponse<List<Hospitalization>>> result) {
    return result.when(ok: (response) => Result.ok(response.data ?? const []), error: (e) => Result.error(e));
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
