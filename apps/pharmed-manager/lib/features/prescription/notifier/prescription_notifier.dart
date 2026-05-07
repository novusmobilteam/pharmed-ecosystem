import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

// lib/features/prescription/presentation/notifier/prescription_notifier.dart
//
// [SWREQ-MGR-RX-001] [IEC 62304 §5.5]
// Reçete listesi + panel koordinasyon notifier'ı.
// Sınıf: Class B

enum PrescriptionPanelType { form, detail }

class PrescriptionNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Hospitalization>, DateFilterMixin<Hospitalization> {
  final GetHospitalizationsWithPrescriptionUseCase _getHospitalizationsWithPrescriptionUseCase;

  PrescriptionNotifier({required GetHospitalizationsWithPrescriptionUseCase getHospitalizationsWithPrescriptionUseCase})
    : _getHospitalizationsWithPrescriptionUseCase = getHospitalizationsWithPrescriptionUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  bool get isFetching => isLoading(fetchOp);

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  PrescriptionPanelType _panelType = PrescriptionPanelType.form;
  PrescriptionPanelType get panelType => _panelType;

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  List<Hospitalization> get dateFilteredItems => applyDateFilter(filteredItems);

  /// Yeni reçete oluşturma veya düzenleme panelini açar.
  void openFormPanel({Hospitalization? hosp}) {
    _selectedHospitalization = hosp;
    _panelType = PrescriptionPanelType.form;
    _isPanelOpen = true;
    notifyListeners();
  }

  /// Seçili hastanın reçete geçmişini gösteren detay panelini açar.
  void openDetailPanel(Hospitalization hosp) {
    _selectedHospitalization = hosp;
    _panelType = PrescriptionPanelType.detail;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedHospitalization = null;
    notifyListeners();
  }

  Future<void> getHospitalizations() async {
    await execute(
      fetchOp,
      operation: () => _getHospitalizationsWithPrescriptionUseCase.call(),
      onData: (data) {
        allItems = data;
        notifyListeners();
      },
    );
  }

  @override
  DateTime? getDateField(Hospitalization item) => item.admissionDate;
}
