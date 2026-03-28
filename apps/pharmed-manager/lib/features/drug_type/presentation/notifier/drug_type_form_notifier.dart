import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/drug_type.dart';
import '../../domain/usecase/create_drug_type_usecase.dart';
import '../../domain/usecase/update_drug_type_usecase.dart';

class DrugTypeFormNotifier extends ChangeNotifier with ApiRequestMixin, SearchMixin<DrugType> {
  final CreateDrugTypeUseCase _createDrugTypeUseCase;
  final UpdateDrugTypeUseCase _updateDrugTypeUseCase;

  DrugTypeFormNotifier({
    required CreateDrugTypeUseCase createDrugTypeUseCase,
    required UpdateDrugTypeUseCase updateDrugTypeUseCase,
    DrugType? drugType,
  }) : _createDrugTypeUseCase = createDrugTypeUseCase,
       _updateDrugTypeUseCase = updateDrugTypeUseCase,
       _drugType = drugType ?? DrugType(isActive: true);

  DrugType _drugType;
  DrugType get drugType => _drugType;

  OperationKey submitOp = OperationKey.submit();

  bool get isCreate => _drugType.id == null;

  Future<void> submit({Function(String? msg)? onFailed, Function(String? msg)? onSuccess}) async {
    await executeVoid(
      submitOp,
      operation: () => isCreate ? _createDrugTypeUseCase.call(_drugType) : _updateDrugTypeUseCase.call(_drugType),
      onFailed: (error) => onFailed?.call(error.message),
      onSuccess: () => onSuccess?.call('İşleminiz başarıyla tamamlandı.'),
    );
  }

  void updateName(String? value) {
    _drugType = _drugType.copyWith(name: value);
    notifyListeners();
  }

  void updateStatus(Status? value) {
    _drugType = _drugType.copyWith(isActive: value?.isActive);
    notifyListeners();
  }
}
