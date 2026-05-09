import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class MyPatientsNotifier extends ChangeNotifier with SearchMixin<MyPatient>, ApiRequestMixin {
  final GetMyPatientsUseCase _getMyPatientsUseCase;
  final RemovePatientsUseCase _removePatientUseCase;

  MyPatientsNotifier({
    required GetMyPatientsUseCase getMyPatientsUseCase,
    required RemovePatientsUseCase removePatientUseCase,
  }) : _getMyPatientsUseCase = getMyPatientsUseCase,
       _removePatientUseCase = removePatientUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey removeOp = OperationKey.delete();

  List<MyPatient> _selectedItems = [];
  List<MyPatient> get selectedItems => _selectedItems;

  bool get isFetching => isLoading(fetchOp);

  Future<void> fetchMyPatients() async {
    await execute(fetchOp, operation: () => _getMyPatientsUseCase.call(), onData: (data) => allItems = data);
  }

  Future<void> removePatients({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final ids = _selectedItems.map((s) => s.id ?? 0).toList();
    await executeVoid(
      removeOp,
      operation: () => _removePatientUseCase.call(ids),
      onSuccess: () {
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        _selectedItems.clear();
        fetchMyPatients();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  void selectItem(MyPatient patient) {
    if (_selectedItems.contains(patient)) {
      _selectedItems.remove(patient);
    } else {
      _selectedItems.add(patient);
    }
    notifyListeners();
  }
}
