import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

enum HospitalizationPanelMode {
  none,
  newPatient,
  editPatient,
  newHospitalization,
  newHospitalizationWithPatient,
  editHospitalization,
}

class HospitalizationNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Hospitalization> {
  final GetActiveHospitalizationsUseCase _getActiveHospitalizationsUseCase;
  final GetHospitalizationsUseCase _getHospitalizationsUseCase;

  HospitalizationNotifier({
    required GetActiveHospitalizationsUseCase getActiveHospitalizationsUseCase,
    required GetHospitalizationsUseCase getHospitalizationsUseCase,
  }) : _getActiveHospitalizationsUseCase = getActiveHospitalizationsUseCase,
       _getHospitalizationsUseCase = getHospitalizationsUseCase;

  HospitalizationPanelMode _panelMode = HospitalizationPanelMode.none;
  HospitalizationPanelMode get panelMode => _panelMode;

  bool get isPanelOpen => _panelMode != HospitalizationPanelMode.none;

  OperationKey fetchOp = OperationKey.fetch();
  bool get isFetching => isLoading(fetchOp);

  Patient? _selectedPatient;
  Patient? get patient => _selectedPatient;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  bool get hasSelection => _selectedHospitalization != null;

  bool _showDischarged = false; //  taburcu toggle'ı
  bool get showDischarged => _showDischarged;

  void selectHospitalization(Hospitalization? hospitalization) {
    _selectedHospitalization = hospitalization;
    _selectedPatient = hospitalization?.patient;
    notifyListeners();
  }

  void openPanel(HospitalizationPanelMode mode) {
    _panelMode = mode;
    switch (mode) {
      case HospitalizationPanelMode.newPatient:
      case HospitalizationPanelMode.newHospitalization:
        _selectedHospitalization = null;
        _selectedPatient = null;
      case HospitalizationPanelMode.newHospitalizationWithPatient:
        _selectedPatient = _selectedHospitalization?.patient;
        _selectedHospitalization = null;
      case HospitalizationPanelMode.editPatient:
      case HospitalizationPanelMode.editHospitalization:
        break;
      case HospitalizationPanelMode.none:
        break;
    }
    notifyListeners();
  }

  void closePanel() {
    _panelMode = HospitalizationPanelMode.none;
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
