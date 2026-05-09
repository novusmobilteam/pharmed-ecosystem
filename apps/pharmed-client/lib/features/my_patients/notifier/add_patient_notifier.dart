import 'package:flutter/material.dart';

import 'package:pharmed_manager/core/core.dart';

class AddPatientNotifier extends ChangeNotifier with SearchMixin<Hospitalization>, ApiRequestMixin {
  final GetHospitalizationsUseCase _getHospitalizationsUseCase;
  final AddPatientUseCase _addPatientUseCase;
  final List<Hospitalization> initiallySelected;

  AddPatientNotifier({
    required GetHospitalizationsUseCase getHospitalizationsUseCase,
    required AddPatientUseCase addPatientUseCase,
    required int userId,
    this.initiallySelected = const [],
  }) : _getHospitalizationsUseCase = getHospitalizationsUseCase,
       _addPatientUseCase = addPatientUseCase,
       _userId = userId {
    _selectedItemIds.addAll(initiallySelected.map((i) => i.patient?.id ?? 0));
  }

  final int _userId;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isFetching => isLoading(fetchOp);

  // Data
  List<Hospitalization> _selectedItems = [];

  Set<int> _selectedItemIds = {};
  Set<int> get selectedItemIds => _selectedItemIds;

  // Functions
  Future<void> fetchHospitalizations() async {
    await execute(
      fetchOp,
      operation: () => _getHospitalizationsUseCase.call(GetHospitalizationsParams()),
      onData: (response) => allItems = response.data ?? [],
      loadingMessage: 'Hastalar yükleniyor...',
    );
  }

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final data = _selectedItems.map((s) => AddPatientParams(userId: _userId, hospitalizationId: s.id ?? 0)).toList();
    await executeVoid(
      submitOp,
      operation: () => _addPatientUseCase.call(data),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void selectPatient(Hospitalization data) {
    final patientId = data.patient?.id ?? 0;
    if (_selectedItemIds.contains(patientId)) {
      _selectedItems.remove(data);
      _selectedItemIds.remove(patientId);
    } else {
      _selectedItems.add(data);
      _selectedItemIds.add(patientId);
    }

    notifyListeners();
  }
}
