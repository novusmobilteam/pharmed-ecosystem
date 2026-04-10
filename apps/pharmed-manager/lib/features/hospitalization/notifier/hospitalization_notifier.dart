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

class HospitalizationNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Hospitalization>, DateFilterMixin<Hospitalization> {
  final IHospitalizationRepository _hospitalizationRepository;

  HospitalizationNotifier({required IHospitalizationRepository hospitalizationRepository})
    : _hospitalizationRepository = hospitalizationRepository {
    // Varsayılan tarih aralığı: son 4 gün
    setStartDate(DateTime.now().subtract(const Duration(days: 4)));
    setEndDate(DateTime.now());
  }

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

  /// Filtrelenmiş yatış listesi.
  /// Önce arama filtresini (SearchMixin default), sonra tarih filtresini uygular.
  @override
  List<Hospitalization> get filteredItems {
    // SearchMixin'in default araması searchQuery varsa çalışır
    if (searchQuery.isNotEmpty) {
      return applyDateFilter(super.filteredItems);
    }
    return applyDateFilter(allItems);
  }

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

  /// Yatan hasta listesini API'den çeker.
  Future<void> getHospitalizations() async {
    _selectedHospitalization = null;
    await execute(
      fetchOp,
      operation: () => _hospitalizationRepository.getHospitalizations(),
      onData: (response) => allItems = response.data ?? [],
    );
  }

  /// Tarih alanını belirler (DateFilterMixin için gerekli).
  /// Yatış tarihi (admissionDate) üzerinden filtreleme yapar.
  @override
  DateTime? getDateField(Hospitalization item) => item.admissionDate;
}
