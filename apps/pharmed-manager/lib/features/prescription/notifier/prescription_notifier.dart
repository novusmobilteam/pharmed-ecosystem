import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

// [SWREQ-MGR-RX-001] [IEC 62304 §5.5]
// Reçete listesi + panel koordinasyon notifier'ı.
// Sınıf: Class B

class PrescriptionNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Hospitalization> {
  final GetActiveHospitalizationsUseCase _getActiveHospitalizationsUseCase;
  final GetHospitalizationsUseCase _getHospitalizationsUseCase;

  PrescriptionNotifier({
    required GetActiveHospitalizationsUseCase getActiveHospitalizationsUseCase,
    required GetHospitalizationsUseCase getHospitalizationsUseCase,
  }) : _getActiveHospitalizationsUseCase = getActiveHospitalizationsUseCase,
       _getHospitalizationsUseCase = getHospitalizationsUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  bool get isFetching => isLoading(fetchOp);

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  bool _showDischarged = false; //  taburcu toggle'ı
  bool get showDischarged => _showDischarged;

  /// Seçili hastanın reçete geçmişini gösteren detay panelini açar.
  void openPanel(Hospitalization hosp) {
    _selectedHospitalization = hosp;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedHospitalization = null;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    if (_showDischarged) {
      await fetchPagedData(
        fetchMethod: (skip, take) => _getHospitalizationsUseCase.call(
          PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
        ),
      );
    } else {
      await fetchPagedData(
        fetchMethod: (skip, take) => _getActiveHospitalizationsUseCase.call(
          PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
        ),
      );
    }
  }

  void toggleDischarged() {
    _showDischarged = !_showDischarged;
    resetFilters(notify: false);
    notifyListeners();
    fetch();
  }
}
