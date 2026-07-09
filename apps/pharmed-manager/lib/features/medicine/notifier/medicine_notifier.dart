import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class MedicineNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<Medicine> {
  final GetMedicinesUseCase _getMedicinesUseCase;
  final DeleteMedicineUseCase _deleteMedicineUseCase;

  MedicineNotifier({
    required GetMedicinesUseCase getMedicinesUseCase,
    required DeleteMedicineUseCase deleteMedicineUseCase,
  }) : _getMedicinesUseCase = getMedicinesUseCase,
       _deleteMedicineUseCase = deleteMedicineUseCase;

  OperationKey fetchOp = OperationKey.fetch();
  OperationKey deleteOp = OperationKey.delete();

  bool get isFetching => isLoading(fetchOp);
  bool get isDeleting => isLoading(deleteOp);

  Medicine? _selectedMedicine;
  Medicine? get selectedMedicine => _selectedMedicine;

  bool _isPanelOpen = false;
  bool get isPanelOpen => _isPanelOpen;

  void openPanel({Medicine? medicine}) {
    _selectedMedicine = medicine;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    _isPanelOpen = false;
    _selectedMedicine = null;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getMedicinesUseCase.call(
        PagedQueryParams(skip: skip, take: take, searchQuery: searchQuery, startDate: startDate, endDate: endDate),
      ),
    );
  }

  Future<void> deleteMedicine(
    Medicine medicine, {
    Function(String? msg)? onFailed,
    Function(String? msg)? onSuccess,
  }) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteMedicineUseCase.call(medicine),
      onSuccess: () {
        onSuccess?.call(null);
        fetch();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
