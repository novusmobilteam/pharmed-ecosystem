import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class CustomWithdrawNotifier extends ChangeNotifier with ApiRequestMixin {
  Hospitalization? _hospitalization;
  final GetPatientMedicinesUseCase _getPatientMedicinesUseCase;
  final WithdrawPatientMedicineUseCase _withdrawPatientMedicineUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey submitOp = OperationKey.submit();

  bool get isFetching => isLoading(fetchOp);
  bool get isEmpty => _items.isEmpty;

  List<WithdrawItem> _items = [];
  List<WithdrawItem> get items => _items;

  WithdrawItem? _selectedItem;
  WithdrawItem? get selectedItem => _selectedItem;

  CustomWithdrawNotifier({
    required GetPatientMedicinesUseCase getPatientMedicinesUseCase,
    required WithdrawPatientMedicineUseCase withdrawPatientMedicineUseCase,
    required Hospitalization hospitalization,
  }) : _getPatientMedicinesUseCase = getPatientMedicinesUseCase,
       _withdrawPatientMedicineUseCase = withdrawPatientMedicineUseCase {
    _hospitalization = hospitalization;
  }

  void getItems() async {
    await execute(
      fetchOp,
      operation: () => _getPatientMedicinesUseCase.call(_hospitalization?.id ?? 0),
      onData: (data) {
        _items = data;
        notifyListeners();
      },
    );
  }

  void submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    final id = _selectedItem?.id ?? 0;
    await executeVoid(
      submitOp,
      operation: () => _withdrawPatientMedicineUseCase.call(id),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('Hasta ilacı alma işlemi başarılı.'),
    );

    getItems();
  }

  void selectItem(WithdrawItem item) {
    _selectedItem = item;
    notifyListeners();
  }
}
