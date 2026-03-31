import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class DrugClassFormNotifier extends ChangeNotifier with ApiRequestMixin {
  final CreateDrugClassUseCase _createDrugClassUseCase;
  final UpdateDrugClassUseCase _updateDrugClassUseCase;

  DrugClassFormNotifier({
    required CreateDrugClassUseCase createDrugClassUseCase,
    required UpdateDrugClassUseCase updateDrugClassUseCase,
    DrugClass? drugClass,
  }) : _createDrugClassUseCase = createDrugClassUseCase,
       _updateDrugClassUseCase = updateDrugClassUseCase,
       _drugClass = drugClass ?? DrugClass(isActive: true);

  OperationKey submitOp = OperationKey.submit();
  bool get isSubmitting => isLoading(submitOp);

  DrugClass _drugClass;
  DrugClass get drugClass => _drugClass;

  bool get isCreate => _drugClass.id == null;

  // Functions
  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createDrugClassUseCase.call(_drugClass) : _updateDrugClassUseCase.call(_drugClass),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı'),
    );
  }

  void updateName(String? value) {
    _drugClass = _drugClass.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _drugClass = _drugClass.copyWith(isActive: value?.isActive);
    notifyListeners();
  }
}
