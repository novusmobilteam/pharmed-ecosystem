// [SWREQ-UI-STOCK-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';

class CabinStockNotifier extends ChangeNotifier with ApiRequestMixin {
  CabinStockNotifier({
    required GetBedAssignmentsUseCase getBedAssignments,
    required GetPatientPrescriptionHistoryUseCase getPrescriptionHistory,
  }) : _getBedAssignments = getBedAssignments,
       _getPrescriptionHistory = getPrescriptionHistory;

  final GetBedAssignmentsUseCase _getBedAssignments;
  final GetPatientPrescriptionHistoryUseCase _getPrescriptionHistory;

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

  /// Yalnızca PrescriptionStatus.purchasePending olanlar.
  List<PrescriptionItem> _prescriptionItems = const [];
  List<PrescriptionItem> get prescriptionItems => _prescriptionItems;

  PrescriptionItem? _selectedItem;
  PrescriptionItem? get selectedItem => _selectedItem;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Türetilen ────────────────────────────────────────────────────

  bool get isPrescriptionsLoading => isLoading(prescriptionsOp);
  bool get isPatientSelected => _selectedPatient != null;

  /// RxDrugPanel.isBusy — bu ekranda kayıt işlemi yok
  bool get isBusy => false;

  // ── Init ─────────────────────────────────────────────────────────

  Future<void> init(int cabinId) async {
    _cabinId = cabinId;

    await execute(
      initOp,
      operation: () => _getBedAssignments.call(cabinId),
      onData: (assignments) async {
        _hospitalizations = _toHospitalizations(assignments);
        notifyListeners();
        if (_hospitalizations.isEmpty) return;
        await onPatientTap(_hospitalizations.first);
      },
      onFailed: (e) {
        _hospitalizations = const [];
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<void> onPatientTap(Hospitalization hospitalization) async {
    final patientId = hospitalization.patient?.id;
    if (patientId == null) return;

    if (_selectedPatient?.patient?.id == patientId) {
      _selectedPatient = null;
      _prescriptionItems = const [];
      _selectedItem = null;
      notifyListeners();
      return;
    }

    _selectedPatient = hospitalization;
    _prescriptionItems = const [];
    _selectedItem = null;
    notifyListeners();

    await execute(
      prescriptionsOp,
      operation: () => _getPrescriptionHistory.call(patientId),
      onData: (items) {
        // Yalnızca stokta olan (purchasePending) ilaçları göster
        _prescriptionItems = _filterStockItems(items);
        notifyListeners();
      },
      onFailed: (e) {
        _prescriptionItems = const [];
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  void onDrugTap(PrescriptionItem item) {
    if (_selectedPatient == null) return;

    // Toggle
    if (_selectedItem?.id == item.id) {
      _selectedItem = null;
      notifyListeners();
      return;
    }

    _selectedItem = item;
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _search = value;
    notifyListeners();
  }

  void dismissError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// BedAssignment listesinden null olmayan Hospitalization'ları çıkarır.
  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }

  /// Yalnızca stokta bulunan (purchasePending) kalemleri döndürür.
  List<PrescriptionItem> _filterStockItems(List<PrescriptionItem> items) {
    return items.where((i) => i.status == PrescriptionMovementType.purchasePending).toList();
  }
}
