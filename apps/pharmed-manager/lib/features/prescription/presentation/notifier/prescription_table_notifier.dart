import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../../../hospitalization/domain/usecase/get_hospitalizations_with_prescription_usecase.dart';

class PrescriptionTableNotifier extends ChangeNotifier
    with ApiRequestMixin, SearchMixin<Hospitalization>, DateFilterMixin<Hospitalization> {
  final GetHospitalizationsWithPrescriptionUseCase _getHospitalizationsWithPrescriptionUseCase;

  PrescriptionTableNotifier({
    required GetHospitalizationsWithPrescriptionUseCase getHospitalizationsWithPrescriptionUseCase,
  }) : _getHospitalizationsWithPrescriptionUseCase = getHospitalizationsWithPrescriptionUseCase;

  OperationKey fetchOp = OperationKey.fetch();

  bool get isFetching => isLoading(fetchOp);

  Hospitalization? _selectedHospitalization;
  Hospitalization? get selectedHospitalization => _selectedHospitalization;

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
