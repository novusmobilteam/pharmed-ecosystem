import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

class WarehouseFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateWarehouseUseCase _createWarehouseUseCase;
  final UpdateWarehouseUseCase _updateWarehouseUseCase;
  Warehouse _warehouse;

  WarehouseFormNotifier({
    required CreateWarehouseUseCase createWarehouseUseCase,
    required UpdateWarehouseUseCase updateWarehouseUseCase,
    Warehouse? warehouse,
  }) : _createWarehouseUseCase = createWarehouseUseCase,
       _updateWarehouseUseCase = updateWarehouseUseCase,
       _warehouse = warehouse ?? Warehouse(isActive: true, type: WarehouseType.drug);

  OperationKey submitOp = OperationKey.submit();

  Warehouse get warehouse => _warehouse;
  bool get isCreate => _warehouse.id == null;

  bool get isSubmitting => isLoading(submitOp);
  String? get statusMessage => message(submitOp);

  void updateCode(int? value) {
    _warehouse = _warehouse.updateCode(value);
    notifyListeners();
  }

  void updateName(String? value) {
    _warehouse = _warehouse.updateName(value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _warehouse = _warehouse.updateStatus(value);
    notifyListeners();
  }

  void updateUser(User? value) {
    _warehouse = _warehouse.copyWith(user: value);
    notifyListeners();
  }

  void updateType(WarehouseType? value) {
    _warehouse = _warehouse.copyWith(type: value);
    notifyListeners();
  }

  Future<void> submit() async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createWarehouseUseCase.call(_warehouse) : _updateWarehouseUseCase.call(_warehouse),
      onSuccess: () {
        if (isCreate) resetForm();
      },
      successMessage: 'Depo başarıyla ${isCreate ? 'oluşturuldu' : 'güncellendi'}',
    );
  }

  void resetForm() {
    _warehouse = Warehouse(isActive: true, type: WarehouseType.drug);
    notifyListeners();
  }
}
