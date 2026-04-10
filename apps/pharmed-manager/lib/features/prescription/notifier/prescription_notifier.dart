import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class PrescriptionNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Hospitalization>, DateFilterMixin<Hospitalization> {
  final GetHospitalizationsWithPrescriptionUseCase _getHospitalizationsWithPrescriptionUseCase;

  PrescriptionNotifier({required GetHospitalizationsWithPrescriptionUseCase getHospitalizationsWithPrescriptionUseCase})
    : _getHospitalizationsWithPrescriptionUseCase = getHospitalizationsWithPrescriptionUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  void openPanel({Hospitalization? hosp}) {
    _selectedHospitalization = hosp;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedHospitalization = null;
    notifyListeners();
  }

  List<Hospitalization> get dateFilteredItems {
    return applyDateFilter(filteredItems);
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

  void selectHospitalization(Hospitalization hosp) {
    _selectedHospitalization = hosp;
    notifyListeners();
  }

  @override
  DateTime? getDateField(Hospitalization item) => item.admissionDate;
}
