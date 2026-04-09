import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

class MedicineNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<Medicine> {
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

  List<Medicine> get medicines => filteredItems;

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

  Future<void> getMedicines() async {
    await execute(
      fetchOp,
      operation: () => _getMedicinesUseCase.call(GetMedicinesParams()),
      onData: (response) {
        if (response.data != null) {
          allItems = response.data!;
        }
      },
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
        onSuccess?.call('İşleminiz başarıyla tamamlandı');
        getMedicines();
      },
      onFailed: (error) => onFailed?.call(error.message),
    );
  }
}
