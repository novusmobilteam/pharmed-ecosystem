import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class UnitFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateUnitUseCase _createUnitUseCase;
  final UpdateUnitUseCase _updateUnitUseCase;

  UnitFormNotifier({
    required CreateUnitUseCase createUnitUseCase,
    required UpdateUnitUseCase updateUnitUseCase,
    Unit? unit,
  }) : _createUnitUseCase = createUnitUseCase,
       _updateUnitUseCase = updateUnitUseCase,
       _unit = unit ?? Unit(status: Status.active);

  OperationKey submitOp = OperationKey.submit();

  Unit _unit;
  Unit get unit => _unit;

  bool get isCreate => _unit.id == null;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createUnitUseCase.call(_unit) : _updateUnitUseCase.call(_unit),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateName(String? value) {
    _unit = _unit.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _unit = _unit.copyWith(status: value ?? Status.active);
    notifyListeners();
  }
}
